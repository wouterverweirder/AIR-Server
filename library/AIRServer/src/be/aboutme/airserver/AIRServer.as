package be.aboutme.airserver
{
	import be.aboutme.airserver.endpoints.IEndPoint;
	import be.aboutme.airserver.events.AIRServerEvent;
	import be.aboutme.airserver.events.EndPointEvent;
	import be.aboutme.airserver.events.MessageReceivedEvent;
	import be.aboutme.airserver.messages.Message;
	import be.aboutme.airserver.util.IDGenerator;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="clientAdded", type="be.aboutme.airserver.events.AIRServerEvent")]
	[Event(name="clientRemoved", type="be.aboutme.airserver.events.AIRServerEvent")]
	[Event(name="messageReceived", type="be.aboutme.airserver.events.MessageReceivedEvent")]
	/**
	 * The AIRServer class provides an easy way to create a server application in Adobe AIR.
	 * 
	 * <p>Simply create an instance of this class, add endpoints & start the server. Events are
	 * triggered when users connect, send messages and disconnect from the server</p>
	 * 
	 * <p><code>var airServer:AIRServer = new AIRServer();<br />
	 * airServer.addEndPoint(new SocketEndPoint(1234, new AMFSocketClientHandlerFactory()));<br />
	 * airServer.addEndPoint(new SocketEndPoint(1235, new WebSocketClientHandlerFactory()));<br />
	 * airServer.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceivedHandler);<br />
	 * airServer.addEventListener(AIRServerEvent.CLIENT_ADDED, clientAddedHandler);<br />
	 * airServer.addEventListener(AIRServerEvent.CLIENT_REMOVED, clientRemovedHandler);<br />
	 * airServer.start();</code></p>
	 */ 
	public class AIRServer extends EventDispatcher
	{
		
		private var started:Boolean;
		
		private var endPoints:Vector.<IEndPoint>;
		private var _clients:Vector.<Client>;
		
		public function get clients():Vector.<Client>
		{
			return _clients.concat();
		}
		
		private var clientsMap:Object;
		
		public function AIRServer()
		{
			_clients = new Vector.<Client>();
			endPoints = new Vector.<IEndPoint>();
			clientsMap = {};
		}
		
		/**
		 * Adds an endpoint to the server. An endpoint provides a way to connect
		 * to the server.
		 * 
		 * <p><code>airServer.addEndPoint(<br />
		 * &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;new SocketEndPoint(1234, new AMFSocketClientHandlerFactory())<br />
		 * );</code></p>
		 */ 
		public function addEndPoint(endPointToAdd:IEndPoint):void
		{
			if(endPoints.indexOf(endPointToAdd) == -1)
			{
				endPoints.push(endPointToAdd);
			}
		}
		
		/**
		 * Starts the server: this will start all added endpoints and listen for
		 * connections / data on those endpoints.
		 */ 
		public function start():void
		{
			//open all endpoints
			for each(var endPoint:IEndPoint in endPoints)
			{
				//add event listeners to the endpoint
				endPoint.addEventListener(EndPointEvent.CLIENT_HANDLER_ADDED, clientHandlerAddedHandler, false, 0, true);
				//open it
				endPoint.open();
			}
			started = true;
		}
		
		/**
		 * Stops the server: this will stop all endpoints, meaning all the
		 * connected clients will be disconnected from the server.
		 */ 
		public function stop():void
		{
			//close all endpoints
			for each(var endPoint:IEndPoint in endPoints)
			{
				//close the endpoint
				endPoint.close();
				//remove event listeners from the endpoint
				endPoint.removeEventListener(EndPointEvent.CLIENT_HANDLER_ADDED, clientHandlerAddedHandler);
			}
			started = false;
		}
		
		/**
		 * Send a message to all the connected clients.
		 */ 
		public function sendMessageToAllClients(message:Message):void
		{
			for each(var client:Client in _clients)
			{
				client.sendMessage(message);
			}
		}
		
		private function clientHandlerAddedHandler(event:EndPointEvent):void
		{
			//trace("AIRSERVER: Client Handler Added Handler");
			var client:Client = new Client(IDGenerator.getUniqueId(), event.clientHandler);
			_clients.push(client);
			clientsMap[client.id] = client;
			//add events to client
			client.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceivedHandler, false, 0, true);
			client.addEventListener(Event.CLOSE, clientCloseHandler, false, 0, true);
			//dispatch added event
			var e:AIRServerEvent = new AIRServerEvent(AIRServerEvent.CLIENT_ADDED);
			e.client = client;
			dispatchEvent(e);
		}
		
		private function clientCloseHandler(event:Event):void
		{
			//trace("AIRSERVER: Client Close Handler");
			var client:Client = event.target as Client;
			var index:int = _clients.indexOf(client);
			if(index > -1) _clients.splice(index, 1);
			delete clientsMap[client.id];
			//remove event listeners
			client.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceivedHandler);
			client.removeEventListener(Event.CLOSE, clientCloseHandler);
			//dispatch removed event
			var e:AIRServerEvent = new AIRServerEvent(AIRServerEvent.CLIENT_REMOVED);
			e.client = client;
			dispatchEvent(e);
		}
		
		/**
		 * Get a client, specified by it's client id
		 */ 
		public function getClientById(clientId:uint):Client
		{
			return clientsMap[clientId];
		}
		
		private function messageReceivedHandler(event:MessageReceivedEvent):void
		{
			dispatchEvent(event.clone());
		}
	}
}