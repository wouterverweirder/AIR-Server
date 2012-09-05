package be.aboutme.airserver.events
{
	import flash.events.Event;
	
	public class MessagesAvailableEvent extends Event
	{
		
		public static const MESSAGES_AVAILABLE:String = "messagesAvailable";
		
		public function MessagesAvailableEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}