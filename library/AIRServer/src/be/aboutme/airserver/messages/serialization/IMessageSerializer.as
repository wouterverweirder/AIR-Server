package be.aboutme.airserver.messages.serialization
{
	import be.aboutme.airserver.messages.Message;

	public interface IMessageSerializer
	{
		function serialize(message:Message):*;
		function deserialize(serialized:*):Vector.<Message>;
	}
}