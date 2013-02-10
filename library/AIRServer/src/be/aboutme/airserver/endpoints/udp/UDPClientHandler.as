package be.aboutme.airserver.endpoints.udp
{
	import be.aboutme.airserver.endpoints.IClientHandler;
	import be.aboutme.airserver.events.MessagesAvailableEvent;
	import be.aboutme.airserver.messages.Message;
	import be.aboutme.airserver.messages.serialization.IMessageSerializer;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.DatagramSocket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	public class UDPClientHandler extends EventDispatcher implements IClientHandler
	{
		
		private var _srcAddress:String;
		
		public function get srcAddress():String
		{
			return _srcAddress;
		}
		
		private var _srcPort:uint;
		
		public function get srcPort():uint
		{
			return _srcPort;
		}
		
		private var messageSerializer:IMessageSerializer;
		
		private var readQueue:Vector.<Message>;
		
		private var closed:Boolean;
		private var clientDatagramSocket:DatagramSocket;
		private var clientListeningAddress:String;
		private var clientListeningPort:uint;
		
		/**
		 * timeout in milliseconds
		 * client is "disconnected" when there is no activity in this timeframe
		 */ 
		private var timeout:uint;
		
		private var timeoutTimer:Timer;
		
		public function UDPClientHandler(srcAddress:String, srcPort:uint, messageSerializer:IMessageSerializer, timeout:uint = 0)
		{
			this._srcAddress = clientListeningAddress = srcAddress;
			this._srcPort = clientListeningPort = srcPort;
			this.messageSerializer = messageSerializer;
			this.timeout = timeout;
			
			readQueue = new Vector.<Message>();
			clientDatagramSocket = new DatagramSocket();
			
			if(timeout > 0)
			{
				timeoutTimer = new Timer(timeout);
				timeoutTimer.addEventListener(TimerEvent.TIMER, timeoutTimerHandler, false, 0, true);
				timeoutTimer.start();
			}
		}
		
		protected function timeoutTimerHandler(event:TimerEvent):void
		{
			close();
		}
		
		public function handleData(data:ByteArray):void
		{
			if(timeoutTimer != null)
			{
				timeoutTimer.reset();
				timeoutTimer.start();
			}
			var input:Object;
			while(data.bytesAvailable > 0)
			{
				try
				{
					input = data.readObject();
				}
				catch(error:Error)
				{
					data.position = 0;
					input = data.readUTFBytes(data.bytesAvailable);
				}
				//add decoded messages to read queue
				var deserialized:Vector.<Message> = messageSerializer.deserialize(input);
				for each(var message:Message in deserialized)
				{
					//check command for ADDR / PORT
					switch(message.command)
					{
						case "ADDR":
							clientListeningAddress = message.data;
							break;
						case "PORT":
							clientListeningPort = message.data;
							break;
					}
					readQueue.push(message);
				}
			}
			if(readQueue.length > 0)
			{
				dispatchEvent(new MessagesAvailableEvent(MessagesAvailableEvent.MESSAGES_AVAILABLE));
			}
		}
		
		public function close():void
		{
			if(!closed)
			{
				closed = true;
				//stop timer?
				if(timeoutTimer != null)
				{
					timeoutTimer.stop();
					timeoutTimer.removeEventListener(TimerEvent.TIMER, timeoutTimerHandler);
				}
				//dispatch close event
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
		
		public function get messagesAvailable():Boolean
		{
			return (readQueue.length > 0);
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
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(messageSerializer.serialize(messageToWrite));
			clientDatagramSocket.send(bytes, 0, 0, clientListeningAddress, clientListeningPort);
		}
	}
}