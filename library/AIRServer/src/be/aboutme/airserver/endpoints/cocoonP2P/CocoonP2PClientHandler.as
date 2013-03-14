package be.aboutme.airserver.endpoints.cocoonP2P
{
	import be.aboutme.airserver.endpoints.IClientHandler;
	import be.aboutme.airserver.events.MessagesAvailableEvent;
	import be.aboutme.airserver.messages.Message;
	
	import com.projectcocoon.p2p.command.CommandType;
	import com.projectcocoon.p2p.managers.GroupManager;
	import com.projectcocoon.p2p.vo.ClientVO;
	import com.projectcocoon.p2p.vo.MessageVO;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.NetGroup;
	
	public class CocoonP2PClientHandler extends EventDispatcher implements IClientHandler
	{
		
		private var _messagesAvailable:Boolean = false;
		
		public function get messagesAvailable():Boolean
		{
			return _messagesAvailable;
		}
		
		private var netGroup:NetGroup;
		private var client:ClientVO;
		private var groupManager:GroupManager;
		
		private var closed:Boolean;
		private var messagesToHandle:Array;
		
		public function CocoonP2PClientHandler(netGroup:NetGroup, client:ClientVO, groupManager:GroupManager)
		{
			this.netGroup = netGroup;
			this.client = client;
			this.groupManager = groupManager;
			messagesToHandle = [];
		}
		
		public function close():void
		{
			if(!closed)
			{
				closed = true;
				//dispatch close event
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
		
		public function handleCocoonP2PMessage(message:MessageVO):void
		{
			//the message is from this client
			switch(message.type)
			{
				case CommandType.SERVICE:
					trace(message.command, message.data, message.type);
					break;
				case CommandType.MESSAGE:
					messagesToHandle.push(message.data);
					_messagesAvailable = true;
					dispatchEvent(new MessagesAvailableEvent(MessagesAvailableEvent.MESSAGES_AVAILABLE));
					break;
			}
		}
		
		public function readMessage():Message
		{
			var message:Message = null;
			if(messagesToHandle.length > 0)
			{
				message = new Message();

				var tmp:Object = messagesToHandle.shift();
				message.command = tmp.command;
				message.data = tmp.data;
				message.senderId = tmp.senderId;
				
				_messagesAvailable = (messagesToHandle.length > 0);
			}
			return message;
		}
		
		public function writeMessage(messageToWrite:Message):void
		{
			groupManager.sendMessageToClient(messageToWrite, netGroup, client);
		}
	}
}
