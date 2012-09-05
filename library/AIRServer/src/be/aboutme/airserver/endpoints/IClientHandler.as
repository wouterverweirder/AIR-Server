package be.aboutme.airserver.endpoints
{
	import be.aboutme.airserver.messages.Message;
	
	import flash.events.IEventDispatcher;

	public interface IClientHandler extends IEventDispatcher
	{
		function close():void;
		function get messagesAvailable():Boolean;
		function readMessage():Message;
		function writeMessage(messageToWrite:Message):void;
	}
}