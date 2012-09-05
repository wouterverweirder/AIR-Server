package be.aboutme.airserver.endpoints.socket.handlers.amf
{
	import be.aboutme.airserver.endpoints.socket.handlers.SocketClientHandler;
	import be.aboutme.airserver.messages.Message;
	import be.aboutme.airserver.messages.serialization.IMessageSerializer;
	
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class AMFSocketClientHandler extends SocketClientHandler
	{
		
		public function AMFSocketClientHandler(socket:Socket, messageSerializer:IMessageSerializer, crossDomainPolicyXML:XML = null)
		{
			super(socket, messageSerializer, crossDomainPolicyXML);
		}
		
		override protected function queueMessagesFromSocketBytes():Boolean
		{
			var readSuccess:Boolean = true;
			var input:Object;
			while(readSuccess && socketBytes.bytesAvailable > 0)
			{
				try
				{
					input = socketBytes.readObject();
					//add decoded messages to read queue
					var deserialized:Vector.<Message> = messageSerializer.deserialize(input);
					for each(var message:Message in deserialized)
					{
						readQueue.push(message);
					}
				}
				catch(error:Error)
				{
					readSuccess = false;
					socketBytes.position = socketBytes.length;
				}
			}
			return readSuccess;
		}
		
		override public function writeMessage(messageToWrite:Message):void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(messageSerializer.serialize(messageToWrite));
			writeSocketBytes(bytes);
		}
	}
}