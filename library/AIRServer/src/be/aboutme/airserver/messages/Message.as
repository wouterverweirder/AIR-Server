package be.aboutme.airserver.messages
{

	public class Message
	{
		
		public var senderId:uint;
		public var command:String = "";
		public var data:* = "";
		
		public function Message()
		{
		}
		
		public function toString():String
		{
			return "[Message " + data + "]";
		}
	}
}