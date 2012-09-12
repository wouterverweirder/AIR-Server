package be.aboutme.airserver.messages.serialization
{
	import be.aboutme.airserver.messages.Message;
	
	public class PlainTextSerializer implements IMessageSerializer
	{
		protected var messageDelimiter:String;
		
		public function PlainTextSerializer(messageDelimiter:String = "\n")
		{
			this.messageDelimiter = messageDelimiter;
		}
		
		public function serialize(message:Message):*
		{
			return message.data + messageDelimiter;
		}
		
		public function deserialize(serialized:*):Vector.<Message>
		{
			var split:Array = serialized.split(messageDelimiter);
			var messages:Vector.<Message> = new Vector.<Message>();
			for each(var input:String in split)
			{
				if(input.length > 0)
				{
					var message:Message = new Message();
					message.data = input;
					messages.push(message);
				}
			}
			return messages;
		}
	}
}