package be.aboutme.airserver.messages.serialization
{
	import be.aboutme.airserver.messages.Message;
	
	public class NativeObjectSerializer implements IMessageSerializer
	{
		public function NativeObjectSerializer()
		{
		}
		
		public function serialize(message:Message):*
		{
			return message;
		}
		
		public function deserialize(serialized:*):Vector.<Message>
		{
			var messages:Vector.<Message> = new Vector.<Message>(1, true);
			if(serialized is Message)
			{
				messages[0] = serialized;
			}
			else
			{
				var message:Message = new Message();
				if(serialized.hasOwnProperty("senderId")) message.senderId = serialized.senderId;
				if(serialized.hasOwnProperty("command")) message.command = serialized.command;
				if(serialized.hasOwnProperty("data")) message.data = serialized.data;
				else message.data = serialized;
				messages[0] = message;
			}
			
			return messages;
		}
	}
}