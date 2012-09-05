package be.aboutme.airserver.events
{
	import be.aboutme.airserver.endpoints.IClientHandler;
	
	import flash.events.Event;
	
	public class EndPointEvent extends Event
	{
		
		public static const CLIENT_HANDLER_ADDED:String = "clientHandlerAdded";
		
		public var clientHandler:IClientHandler;
		
		public function EndPointEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var e:EndPointEvent = new EndPointEvent(type, bubbles, cancelable);
			e.clientHandler = clientHandler;
			return e;
		}
	}
}