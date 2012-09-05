package be.aboutme.airserver.endpoints.udp
{
	import be.aboutme.airserver.endpoints.IClientHandler;
	import be.aboutme.airserver.endpoints.IEndPoint;
	import be.aboutme.airserver.events.EndPointEvent;
	import be.aboutme.airserver.messages.serialization.IMessageSerializer;
	
	import flash.events.DatagramSocketDataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.DatagramSocket;
	
	public class UDPEndPoint extends EventDispatcher implements IEndPoint
	{
		
		protected var port:uint;
		protected var messageSerializer:IMessageSerializer;
		protected var timeout:uint;
		
		protected var datagramSocket:DatagramSocket;
		
		private var clientHandlers:Vector.<UDPClientHandler>;
		private var clientHandlersById:Object;
		
		public function UDPEndPoint(port:uint, messageSerializer:IMessageSerializer, timeout:uint = 0)
		{
			this.port = port;
			this.messageSerializer = messageSerializer;
			this.timeout = timeout;
			clientHandlers = new Vector.<UDPClientHandler>();
			clientHandlersById = {};
		}
		
		public function open():void
		{
			clientHandlers = new Vector.<UDPClientHandler>();
			//listen
			datagramSocket = new DatagramSocket();
			datagramSocket.addEventListener(DatagramSocketDataEvent.DATA, dataHandler, false, 0, true);
			datagramSocket.bind(port);
			datagramSocket.receive();
			trace("bound datagram socket to port: " + port);
		}
		
		public function close():void
		{
			//close all socket clienthandlers
			for each(var clientHandler:IClientHandler in clientHandlers)
			{
				clientHandler.close();
			}
			//reset vector
			clientHandlers = new Vector.<UDPClientHandler>();
			clientHandlersById = {};
			if(datagramSocket != null)
			{
				datagramSocket.close();
			}
		}
		
		protected function dataHandler(event:DatagramSocketDataEvent):void
		{
			//we don't really have "connections" to a client, check the src info
			//and designate it to the correct handler
			var clientHandler:UDPClientHandler = clientHandlersById[event.srcAddress + event.srcPort];
			if(clientHandler == null)
			{
				clientHandler = new UDPClientHandler(event.srcAddress, event.srcPort, messageSerializer, timeout);
				
				clientHandler.addEventListener(Event.CLOSE, clientHandlerCloseHandler, false, 0, true);
				
				clientHandlersById[event.srcAddress + event.srcPort] = clientHandler;
				clientHandlers.push(clientHandler);
				//dispatch added event
				var e:EndPointEvent = new EndPointEvent(EndPointEvent.CLIENT_HANDLER_ADDED);
				e.clientHandler = clientHandler;
				dispatchEvent(e);
			}
			//let this client handler handle it
			clientHandler.handleData(event.data);
		}
		
		private function clientHandlerCloseHandler(event:Event):void
		{
			trace("UDPEndPoint: clientHandlerCloseHandler");
			var clientHandler:UDPClientHandler = event.target as UDPClientHandler;
			//remove event listener
			clientHandler.removeEventListener(Event.CLOSE, clientHandlerCloseHandler);
			//remove it from the vector
			var index:int = clientHandlers.indexOf(clientHandler);
			if(index > -1) clientHandlers.splice(index, 1);
			//remove it from the object
			delete clientHandlersById[clientHandler.srcAddress + clientHandler.srcPort];
		}
	}
}