package be.aboutme.airserver.endpoints.socket.handlers.plain
{
	import be.aboutme.airserver.endpoints.socket.handlers.SocketClientHandler;
	import be.aboutme.airserver.messages.Message;
	import be.aboutme.airserver.messages.serialization.IMessageSerializer;
	
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class PlainTextSocketClientHandler extends SocketClientHandler
	{
		
		public function PlainTextSocketClientHandler(socket:Socket, messageSerializer:IMessageSerializer, crossDomainPolicyXML:XML = null)
		{
			super(socket, messageSerializer, crossDomainPolicyXML);
		}
		
		override protected function queueMessagesFromSocketBytes():Boolean
		{
			if(socketBytes.bytesAvailable > 0)
			{
				//add decoded messages to read queue
				var deserialized:Vector.<Message> = messageSerializer.deserialize(socketBytes.readUTFBytes(socketBytes.bytesAvailable));
				for each(var message:Message in deserialized)
				{
					readQueue.push(message);
				}
			}
			return true;
		}
		
		override public function writeMessage(messageToWrite:Message):void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(messageSerializer.serialize(messageToWrite));
			writeSocketBytes(bytes);
		}
	}
}