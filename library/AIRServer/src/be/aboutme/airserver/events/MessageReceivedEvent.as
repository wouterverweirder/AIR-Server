package be.aboutme.airserver.events
{
	import be.aboutme.airserver.messages.Message;
	
	import flash.events.Event;
	
	public class MessageReceivedEvent extends Event
	{
		
		public static const MESSAGE_RECEIVED:String = "messageReceived";
		
		public var message:Message;
		
		public function MessageReceivedEvent(type:String, message:Message, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.message = message;
		}
		
		override public function clone():Event
		{
			return new MessageReceivedEvent(type, message, bubbles, cancelable);
		}
	}
}