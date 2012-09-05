package be.aboutme.airserver
{
	import be.aboutme.airserver.endpoints.IClientHandler;
	import be.aboutme.airserver.events.MessageReceivedEvent;
	import be.aboutme.airserver.events.MessagesAvailableEvent;
	import be.aboutme.airserver.messages.Message;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

	[Event(name="messageReceived", type="be.aboutme.airserver.events.MessageReceivedEvent")]
	[Event(name="close", type="flash.events.Event")]
	public class Client extends EventDispatcher
	{
		
		private var _id:uint;
		
		public function get id():uint
		{
			return _id;
		}
		
		private var closed:Boolean;
		private var clientHandler:IClientHandler;
		
		public function Client(id:uint, clientHandler:IClientHandler)
		{
			this._id = id;
			this.clientHandler = clientHandler;
			
			clientHandler.addEventListener(Event.CLOSE, closeHandler, false, 0, true);
			clientHandler.addEventListener(MessagesAvailableEvent.MESSAGES_AVAILABLE, messagesAvailableHandler, false, 0, true);
		}
		
		private function messagesAvailableHandler(event:MessagesAvailableEvent):void
		{
			while(clientHandler.messagesAvailable)
			{
				var message:Message = clientHandler.readMessage();
				if(message != null)
				{
					message.senderId = this.id;
					dispatchEvent(new MessageReceivedEvent(MessageReceivedEvent.MESSAGE_RECEIVED, message));
				}
			}
		}
		
		public function sendMessage(message:Message):void
		{
			clientHandler.writeMessage(message);
		}
		
		public function close():void
		{
			if(!closed)
			{
				closed = true;
				
				clientHandler.removeEventListener(Event.CLOSE, closeHandler);
				clientHandler.removeEventListener(MessagesAvailableEvent.MESSAGES_AVAILABLE, messagesAvailableHandler);
				clientHandler.close();
				
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
		
		private function closeHandler(event:Event):void
		{
			close();
		}
		
		override public function toString():String
		{
			return "[Client, " + clientHandler + "]";
		}
	}
}