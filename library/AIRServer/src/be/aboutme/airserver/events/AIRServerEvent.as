package be.aboutme.airserver.events
{
	import be.aboutme.airserver.Client;
	
	import flash.events.Event;
	
	public class AIRServerEvent extends Event
	{
		
		public static const CLIENT_ADDED:String = "clientAdded";
		public static const CLIENT_REMOVED:String = "clientRemoved";
		
		public var client:Client;
		
		public function AIRServerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}