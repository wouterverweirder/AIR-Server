package be.aboutme.airserver.endpoints.cocoonP2P
{
	import be.aboutme.airserver.endpoints.IClientHandler;
	import be.aboutme.airserver.endpoints.IEndPoint;
	import be.aboutme.airserver.events.EndPointEvent;
	
	import com.projectcocoon.p2p.events.ClientEvent;
	import com.projectcocoon.p2p.events.MessageEvent;
	import com.projectcocoon.p2p.managers.GroupManager;
	import com.projectcocoon.p2p.util.ClassRegistry;
	
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	
	public class CocoonP2PEndPoint extends EventDispatcher implements IEndPoint
	{
		
		private var multicastAddress:String;
		private var groupName:String;
		
		private var netConnection:NetConnection;
		
		private var groupManager:GroupManager;
		private var group:NetGroup;
		
		private var clientHandlersByPeerID:Object;
		
		public function CocoonP2PEndPoint(groupName:String = "be.aboutme.airserver.endpoints.p2p.P2PEndPoint", multicastAddress:String = "225.225.0.1:30303")
		{
			this.groupName = groupName;
			this.multicastAddress = multicastAddress;
			clientHandlersByPeerID = {};
			//register classes for serialization
			ClassRegistry.registerClasses();
		}
		
		public function open():void
		{
			netConnection = new NetConnection();
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
			netConnection.connect("rtmfp:");
		}
		
		public function close():void
		{
			if(netConnection != null)
			{
				netConnection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				if(netConnection.connected)
				{
					netConnection.close();
				}
				netConnection = null;
			}
		}
		
		private function netStatusHandler(event:NetStatusEvent):void
		{
			switch(event.info.code)
			{
				case "NetConnection.Connect.Success":
					netConnectionSuccessHandler(event);
					break;
				default:
					//trace("unknown netstatus: " + event.info.code);
					break;
			}
		}
		
		private function netConnectionSuccessHandler(event:NetStatusEvent):void
		{
			trace("created netgroup: " + groupName);
			groupManager = new GroupManager(netConnection, multicastAddress);
			groupManager.addEventListener(MessageEvent.DATA_RECEIVED, onDataReceived, false, 0, true);
			groupManager.addEventListener(ClientEvent.CLIENT_ADDED, onClientAdded, false, 0, true);
			groupManager.addEventListener(ClientEvent.CLIENT_REMOVED, onClientRemoved, false, 0, true);
			group = groupManager.createNetGroup(groupName);
		}
		
		private function onDataReceived(event:MessageEvent):void
		{
			//pass the message to the right clienthandler
			var sendingClientHandler:CocoonP2PClientHandler = clientHandlersByPeerID[event.message.client.peerID];
			if(sendingClientHandler != null)
			{
				sendingClientHandler.handleCocoonP2PMessage(event.message);
			}
			else
			{
				trace("unhandled message: " + event.message);
			}
		}
		
		private function onClientAdded(event:ClientEvent):void
		{
			//announce ourselves (as the server)
			groupManager.getLocalClient(group).clientName = "AIRServer";
			groupManager.announceToGroup(group);
			if(event.client.isLocal)
			{
				return;
			}
			//create the clienthandler
			var clientHandler:IClientHandler = new CocoonP2PClientHandler(group, event.client, groupManager);
			clientHandlersByPeerID[event.client.peerID] = clientHandler;
			//dispatch added event
			var e:EndPointEvent = new EndPointEvent(EndPointEvent.CLIENT_HANDLER_ADDED);
			e.clientHandler = clientHandler;
			dispatchEvent(e);
		}
		
		private function onClientRemoved(event:ClientEvent):void
		{
			var clientHandler:IClientHandler = clientHandlersByPeerID[event.client.peerID];
			if(clientHandler != null)
			{
				clientHandler.close();
				delete clientHandlersByPeerID[event.client.peerID];
			}
		}
	}
}