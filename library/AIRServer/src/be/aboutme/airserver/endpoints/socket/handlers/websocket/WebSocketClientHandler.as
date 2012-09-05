/*

The implementation for the websocket version 8 spec is based on the implementation
in the Bauglir Internet Library. See the disclaimer below:

BEGIN DISCLAIMER

/=============================================================================|
| Project : Bauglir Internet Library                                           |
|==============================================================================|
| Content: Generic connection and server                                       |
|==============================================================================|
| Copyright (c)2011, Bronislav Klucka                                          |
| All rights reserved.                                                         |
| Source code is licenced under original 4-clause BSD licence:                 |
| http://licence.bauglir.com/bsd4.php                                          |
|                                                                              |
|                                                                              |
| Project download homepage:                                                   |
|   http://code.google.com/p/bauglir-websocket/                                |
| Project homepage:                                                            |
|   http://www.webnt.eu/index.php                                              |
| WebSocket version 8 spec.:                                                   |
|   http://tools.ietf.org/html/draft-ietf-hybi-thewebsocketprotocol-10         |
|                                                                              |
|                                                                              |
|=============================================================================

END DISCLAIMER

*/

package be.aboutme.airserver.endpoints.socket.handlers.websocket
{
	import be.aboutme.airserver.endpoints.socket.handlers.SocketClientHandler;
	import be.aboutme.airserver.events.MessagesAvailableEvent;
	import be.aboutme.airserver.messages.Message;
	import be.aboutme.airserver.messages.serialization.IMessageSerializer;
	
	import by.blooddy.crypto.Base64;
	import by.blooddy.crypto.MD5;
	import by.blooddy.crypto.SHA1;
	
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class WebSocketClientHandler extends SocketClientHandler
	{
		protected static const PROTOCOL_HYBI_00:uint = 0;
		protected static const PROTOCOL_HYBI_10:uint = 8;
		protected static const PROTOCOL_HYBI_17:uint = 13;
		
		protected static const FRAME_CONTINUATION:uint = 0x00;
		protected static const FRAME_TEXT:uint = 0x01;
		protected static const FRAME_BINARY:uint = 0x02;
		protected static const FRAME_CLOSE:uint = 0x08;
		protected static const FRAME_PING:uint = 0x09;
		protected static const FRAME_PONG:uint = 0x0A;
		
		protected var protocol:uint;
		
		public function WebSocketClientHandler(socket:Socket, messageSerializer:IMessageSerializer, crossDomainPolicyXML:XML = null)
		{
			super(socket, messageSerializer, crossDomainPolicyXML);
		}
		
		override protected function socketDataHandler(event:ProgressEvent):void
		{
			//trace("WebSocketClientHandler::socketDataHandler");
			if(socket.bytesAvailable > 0)
			{
				if(!firstRequestProcessed)
				{
					firstRequestProcessed = true;
					//websockets handshake?
					socket.readBytes(socketBytes, 0);
					var message:String = socketBytes.readUTFBytes(socketBytes.bytesAvailable);
					if(message.indexOf("GET ") == 0)
					{
						var messageLines:Array = message.split("\n");
						var fields:Object = {};
						var requestedURL:String = "";
						for(var i:uint = 0; i < messageLines.length; i++)
						{
							var line:String = messageLines[i];
							if(i == 0)
							{
								var getSplit:Array = line.split(" ");
								if(getSplit.length > 1)
								{
									requestedURL = getSplit[1];
								}
							}
							else
							{
								var index:int = line.indexOf(":");
								if(index > -1)
								{
									var key:String = line.substr(0, index);
									fields[key] = line.substr(index + 1).replace( /^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2" );
								}
							}
						}
						//check the websocket version
						if(fields["Sec-WebSocket-Version"] != null)
						{
							protocol = uint(fields["Sec-WebSocket-Version"]);
						}
						else
						{
							protocol = PROTOCOL_HYBI_00;
						}
						
						switch(protocol)
						{
							case PROTOCOL_HYBI_00:
								sendHybi00Response(fields, requestedURL);
								break;
							case PROTOCOL_HYBI_10:
								sendHybi10Response(fields, requestedURL);
								break;
							case PROTOCOL_HYBI_17:
								sendHybi17Response(fields, requestedURL);
								break;
							default:
								close();
								break;
						}
						return;
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
		
		protected function sendHybi00Response(fields:Object, requestedURL:String):void
		{
			//draft-ietf-hybi-thewebsocketprotocol-00
			//send a response
			var result:* = fields["Sec-WebSocket-Key1"].match(/[0-9]/gi);
			var key1Nr:uint = (result is Array) ? uint(result.join("")) : 1;
			result = fields["Sec-WebSocket-Key1"].match(/ /gi);
			var key1SpaceCount:uint = (result is Array) ? result.length : 1;
			var key1Part:Number = key1Nr / key1SpaceCount;
			
			result = fields["Sec-WebSocket-Key2"].match(/[0-9]/gi);
			var key2Nr:uint = (result is Array) ? uint(result.join("")) : 1;
			result = fields["Sec-WebSocket-Key2"].match(/ /gi);
			var key2SpaceCount:uint = (result is Array) ? result.length : 1;
			var key2Part:Number = key2Nr / key2SpaceCount;
			
			//calculate binary md5 hash
			var bytesToHash:ByteArray = new ByteArray();
			bytesToHash.writeUnsignedInt(key1Part);
			bytesToHash.writeUnsignedInt(key2Part);
			bytesToHash.writeBytes(socketBytes, socketBytes.length - 8);
			
			//hash it
			var hash:String = MD5.hashBytes(bytesToHash);
			
			var response:String = "HTTP/1.1 101 WebSocket Protocol Handshake\r\n" +
				"Upgrade: WebSocket\r\n" +
				"Connection: Upgrade\r\n" +
				"Sec-WebSocket-Origin: " + fields["Origin"] + "\r\n" +
				"Sec-WebSocket-Location: ws://" + fields["Host"] + requestedURL + "\r\n" +
				"\r\n";
			var responseBytes:ByteArray = new ByteArray();
			responseBytes.writeUTFBytes(response);
			
			for(var i:uint = 0; i < hash.length; i += 2)
			{
				responseBytes.writeByte(parseInt(hash.substr(i, 2), 16));
			}
			
			responseBytes.writeByte(0);
			responseBytes.position = 0;
			socket.writeBytes(responseBytes);
			socket.flush();
			socketBytes.clear();
		}
		
		protected function sendHybi10Response(fields:Object, requestedURL:String):void
		{
			//var websocketKey:String = "dGhlIHNhbXBsZSBub25jZQ==";//test
			var websocketKey:String = fields["Sec-WebSocket-Key"];
			
			var guid:String = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
			var hash:String = websocketKey + guid;
			
			hash = SHA1.hash(hash);
			
			var hashBytes:ByteArray = new ByteArray();
			for(var i:uint = 0; i < hash.length; i += 2)
			{
				hashBytes.writeByte(parseInt(hash.substr(i, 2), 16));
			}
			
			hash = Base64.encode(hashBytes);
			
			var response:String = "HTTP/1.1 101 Switching Protocols\r\n" +
				"Upgrade: websocket\r\n" +
				"Connection: Upgrade\r\n" +
				"Sec-WebSocket-Accept: " + hash + "\r\n" +
				"\r\n";
			
			var responseBytes:ByteArray = new ByteArray();
			responseBytes.writeUTFBytes(response);
			responseBytes.position = 0;
			socket.writeBytes(responseBytes);
			socket.flush();
			socketBytes.clear();
		}
		
		protected function sendHybi17Response(fields:Object, requestedURL:String):void
		{
			sendHybi10Response(fields, requestedURL);
		}
		
		override protected function queueMessagesFromSocketBytes():Boolean
		{
			if(socketBytes.bytesAvailable > 0)
			{
				var input:String;
				switch(protocol)
				{
					case PROTOCOL_HYBI_00:
						input = decodeHybi00Input();
						break;
					case PROTOCOL_HYBI_10:
						input = decodeHybi10Input();
						break;
					case PROTOCOL_HYBI_17:
						input = decodeHybi17Input();
						break;
				}
				
				if(input != null)
				{
					//add decoded messages to read queue
					var deserialized:Vector.<Message> = messageSerializer.deserialize(input);
					for each(var message:Message in deserialized)
					{
						readQueue.push(message);
					}
					return true;
				}
			}
			return false;
		}
		
		private function decodeHybi00Input():String
		{
			var messageString:String = "";
			while(socketBytes.bytesAvailable > 0)
			{
				var byte:int = socketBytes.readByte();
				switch(byte)
				{
					case 0:
					case -1:
						break;
					default:
						messageString += String.fromCharCode(byte);
						break;
				}
			}
			return messageString;
		}
		
		private function decodeHybi10Input():String
		{
			var messageString:String = "";
			var bt:int;
			var len:int;
			var mask:Boolean;
			var masks:Array = [0, 0, 0, 0];
			
			if(socketBytes.bytesAvailable > 0)
			{
				bt = socketBytes.readUnsignedByte();
				
				var aReadFinal:Boolean = (bt & 0x80) == 0x80;
				var aRes1:Boolean = (bt & 0x40) == 0x40;
				var aRes2:Boolean = (bt & 0x20) == 0x20;
				var aRes3:Boolean = (bt & 0x10) == 0x10;
				var aReadCode:int = (bt & 0x0f);
				
				//mask & length
				if (socketBytes.bytesAvailable > 0)
				{
					bt = socketBytes.readUnsignedByte();
					mask = (bt & 0x80) == 0x80;
					len = (bt & 0x7F);
					if (len == 126)
					{
						if (socketBytes.bytesAvailable > 0)
						{
							bt = socketBytes.readUnsignedByte();
							len = bt * 0x100;
							if (socketBytes.bytesAvailable > 0)
							{
								bt = socketBytes.readUnsignedByte();
								len = len + bt;
							}
						}
					}
					else if (len == 127)
					{
						if (socketBytes.bytesAvailable > 0)
						{
							bt = socketBytes.readUnsignedByte();
							len = bt * 0x100000000000000;
							bt = socketBytes.readUnsignedByte();
							if (socketBytes.bytesAvailable > 0)
							{
								len = len + bt * 0x1000000000000;
								bt = socketBytes.readUnsignedByte();
							}
							if (socketBytes.bytesAvailable > 0)
							{
								len = len + bt * 0x10000000000;
								bt = socketBytes.readUnsignedByte();
							}
							if (socketBytes.bytesAvailable > 0)
							{
								len = len + bt * 0x100000000;
								bt = socketBytes.readUnsignedByte();
							}
							if (socketBytes.bytesAvailable > 0)
							{
								len = len + bt * 0x1000000;
								bt = socketBytes.readUnsignedByte();
							}
							if (socketBytes.bytesAvailable > 0)
							{
								len = len + bt * 0x10000;
								bt = socketBytes.readUnsignedByte();
							}
							if (socketBytes.bytesAvailable > 0)
							{
								len = len + bt * 0x100;
								bt = socketBytes.readUnsignedByte();
							}
							if (socketBytes.bytesAvailable > 0)
							{
								len = len + bt;
							}
						}
					}
					
					if (!mask)
					{
						socket.close();
						return null;
					}
					
					//read mask
					if (mask)
					{
						if(socketBytes.bytesAvailable > 0) masks[0] = socketBytes.readUnsignedByte();
						if(socketBytes.bytesAvailable > 0) masks[1] = socketBytes.readUnsignedByte();
						if(socketBytes.bytesAvailable > 0) masks[2] = socketBytes.readUnsignedByte();
						if(socketBytes.bytesAvailable > 0) masks[3] = socketBytes.readUnsignedByte();
					}
					
					if (socketBytes.bytesAvailable > 0)
					{
						var byteArray:ByteArray = new ByteArray();
						var j:uint = 0;
						var k:uint = 0;
						var previousLength:uint = 0;
						while(len > 0)
						{
							socketBytes.readBytes(byteArray, j, Math.min(len, uint.MAX_VALUE));
							k = byteArray.length - previousLength;
							j += k;
							len -= k;
							previousLength = byteArray.length;
						}
						if(mask)
						{
							for(var i:uint = 0; i < byteArray.length; i++)
							{
								byteArray[i] = (byteArray[i] ^ masks[i % 4]);
							}
						}
						
						byteArray.position = 0;
						while(byteArray.bytesAvailable > 0)
						{
							var byte:int = byteArray.readUnsignedByte();
							switch(byte)
							{
								default:
									messageString += String.fromCharCode(byte);
									break;
							}
						}
					}
				}
			}
			return messageString;
		}
		
		private function decodeHybi17Input():String
		{
			return decodeHybi10Input();
		}
		
		override public function writeMessage(messageToWrite:Message):void
		{
			var serialized:String = messageSerializer.serialize(messageToWrite);
			var bytes:ByteArray = new ByteArray();
			switch(protocol)
			{
				case PROTOCOL_HYBI_00:
					bytes.writeByte(0);
					bytes.writeUTFBytes(serialized);
					bytes.writeByte(255);
					writeSocketBytes(bytes);
					break;
				case PROTOCOL_HYBI_10:
					bytes.writeUTFBytes(serialized);
					sendHybi10Data(true, false, false, false, FRAME_TEXT, bytes);
					break;
				case PROTOCOL_HYBI_17:
					bytes.writeUTFBytes(serialized);
					sendHybi17Data(true, false, false, false, FRAME_TEXT, bytes);
					break;
			}
		}
		
		/*
		
		*/
		protected function sendHybi10Data(aWriteFinal:Boolean, aRes1:Boolean, aRes2:Boolean, aRes3:Boolean, aWriteCode:int, aStream:ByteArray):Boolean
		{
			var result:Boolean = !closed;// && (aWriteCode == FRAME_CLOSE);
			var bt:int = 0;
			var sendLen:int = 0;
			var i:int;
			var len:int = 0;
			var stream:ByteArray = new ByteArray();
			var bytes:ByteArray;
			var masks:ByteArray = new ByteArray();
			var send:ByteArray = new ByteArray();
			var fMasking:Boolean = false;//do not mask when we are sending data
			//Random rand = new Random();
			if (result)
			{
				try
				{
					//stream = getStream(fClient);
					
					//send basics
					bt = (aWriteFinal ? 1 : 0) * 0x80;
					bt += (aRes1 ? 1 : 0) * 0x40;
					bt += (aRes2 ? 1 : 0) * 0x20;
					bt += (aRes3 ? 1 : 0) * 0x10;
					bt += aWriteCode;
					
					stream.writeByte(bt);
					
					//length & mask
					len = (fMasking ? 1 : 0) * 0x80;
					if (aStream.length < 126) len += aStream.length;
					else if (aStream.length < 65536) len += 126;
					else len += 127;
					stream.writeByte(len);
					
					if (aStream.length >= 126)
					{
						trace("longer stream");
						bytes = new ByteArray();
						if (aStream.length < 65536)
						{
							bytes.writeShort(aStream.length);
						}
						else
						{
							bytes.writeInt(aStream.length);
						}
						//reverse?
						//if (BitConverter.IsLittleEndian) bytes = ReverseBytes(bytes);
						stream.writeBytes(bytes, 0, bytes.length);
					}
					
					//masking
					if (fMasking)
					{
						masks.writeByte(Math.floor(Math.random() * 256));
						masks.writeByte(Math.floor(Math.random() * 256));
						masks.writeByte(Math.floor(Math.random() * 256));
						masks.writeByte(Math.floor(Math.random() * 256));
						stream.writeBytes(masks, 0, masks.length);
					}

					//send data
					aStream.position = 0;
					
					aStream.readBytes(send);
					
					if(fMasking)
					{
						for(i = 0; i < send.length; i++)
						{
							send[i] = (send[i] ^ masks[i % 4]);
						}
					}
					
					stream.writeBytes(send, 0, send.length);
					
					writeSocketBytes(stream);
				}
				catch (e:Error)
				{
					result = false;
				}
			}
			return result;
		}
		
		protected function sendHybi17Data(aWriteFinal:Boolean, aRes1:Boolean, aRes2:Boolean, aRes3:Boolean, aWriteCode:int, aStream:ByteArray):Boolean
		{
			return sendHybi10Data(aWriteFinal, aRes1, aRes2, aRes3, aWriteCode, aStream);
		}
	}
}