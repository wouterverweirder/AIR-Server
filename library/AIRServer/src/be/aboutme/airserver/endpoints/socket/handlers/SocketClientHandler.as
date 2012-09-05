package be.aboutme.airserver.endpoints.socket.handlers
{
	import be.aboutme.airserver.endpoints.IClientHandler;
	import be.aboutme.airserver.events.MessagesAvailableEvent;
	import be.aboutme.airserver.messages.Message;
	import be.aboutme.airserver.messages.serialization.IMessageSerializer;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class SocketClientHandler extends EventDispatcher implements IClientHandler
	{
		
		public static const MAX_SOCKET_BYTE_SIZE:uint = 1024 * 1024 * 8;
		
		public function get messagesAvailable():Boolean
		{
			return readQueue.length > 0;
		}
		
		protected var socketBytes:ByteArray;
		protected var readQueue:Vector.<Message>;
		
		protected var closed:Boolean;
		protected var firstRequestProcessed:Boolean;
		protected var socket:Socket;
		
		protected var messageSerializer:IMessageSerializer;
		protected var crossDomainPolicyXML:XML;
		
		public function SocketClientHandler(socket:Socket, messageSerializer:IMessageSerializer, crossDomainPolicyXML:XML = null)
		{
			this.socket = socket;
			this.messageSerializer = messageSerializer;
			this.crossDomainPolicyXML = crossDomainPolicyXML;
			
			if(crossDomainPolicyXML == null)
			{
				crossDomainPolicyXML = new XML("<?xml version=\"1.0\"?>" +
					"<!DOCTYPE cross-domain-policy SYSTEM \"/xml/dtds/cross-domain-policy.dtd\">" +
					"<cross-domain-policy>" +
					"   <allow-access-from domain=\"*\" to-ports=\"*\" />" +
					"</cross-domain-policy>");
			}
			this.crossDomainPolicyXML = crossDomainPolicyXML;
			
			socketBytes = new ByteArray();
			readQueue = new Vector.<Message>();
			
			socket.addEventListener(Event.CLOSE, socketCloseHandler, false, 0, true);
			socket.addEventListener(IOErrorEvent.IO_ERROR, socketIOErrorHandler, false, 0, true);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler, false, 0, true);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
		}
		
		public function close():void
		{
			if(!closed)
			{
				closed = true;
				if(socket.connected)
				{
					trace("SocketClientHandler: close socket");
					socket.close();
				}
				//dispatch close event
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
		
		public function readMessage():Message
		{
			var message:Message = null;
			if(readQueue.length > 0)
			{
				message = readQueue.shift();
			}
			return message;
		}
		
		public function writeMessage(messageToWrite:Message):void
		{
			//override this method in the inheriting classes
		}
		
		protected function socketCloseHandler(event:Event):void
		{
			close();
		}
		
		protected function socketIOErrorHandler(event:IOErrorEvent):void
		{
		}
		
		protected function socketDataHandler(event:ProgressEvent):void
		{
			trace("SocketClientHandler::socketDataHandler");
			if(socket.bytesAvailable > 0)
			{
				//this might be a policy file request, so check this here
				if(!firstRequestProcessed)
				{
					firstRequestProcessed = true;
					//process each byte, and send a cross domain reply, before the NULL byte
					while(socket.bytesAvailable > 0)
					{
						var byte:int = socket.readByte();
						socketBytes.writeByte(byte);
						if(byte == 62)
						{
							//policy file request?
							socketBytes.position = 0;
							var msg:String = socketBytes.readUTFBytes(socketBytes.length);
							try
							{
								var msgXML:XML = new XML(msg);
								if(msgXML.name() == "policy-file-request")
								{
									//send a crossdomain reply
									var crossDomainReply:ByteArray = new ByteArray();
									crossDomainReply.writeUTFBytes(crossDomainPolicyXML.toXMLString());
									crossDomainReply.writeByte(0);
									socket.writeBytes(crossDomainReply);
									socket.flush();
									//stop right here
									socketBytes.clear();
									return;
								}
							}
							catch(e:Error)
							{
							}
						}
					}
				}
				else
				{
					socket.readBytes(socketBytes, socketBytes.position);
				}
				socketBytes.position = 0;
				if(queueMessagesFromSocketBytes())
				{
					socketBytes.clear();
				}
				else
				{
					//prevent overflow
					if(socketBytes.length > MAX_SOCKET_BYTE_SIZE)
					{
						socketBytes.clear();
					}
				}
				if(readQueue.length > 0)
				{
					dispatchEvent(new MessagesAvailableEvent(MessagesAvailableEvent.MESSAGES_AVAILABLE));
				}
			}
		}
		
		protected function queueMessagesFromSocketBytes():Boolean
		{
			return false;
		}
		
		protected function writeSocketBytes(bytes:ByteArray):void
		{
			socket.writeBytes(bytes);
			socket.flush();
		}
		
		protected function securityErrorHandler(event:SecurityErrorEvent):void
		{
		}
		
		override public function toString():String
		{
			return "[SocketClientHandler local=" + socket.localAddress + ":" + socket.localPort + ", remote=" + socket.remoteAddress + ":" + socket.remotePort;
		}
	}
}