package be.aboutme.airserver.endpoints
{
	import flash.events.IEventDispatcher;

	public interface IEndPoint extends IEventDispatcher
	{
		function open():void;
		function close():void;
	}
}