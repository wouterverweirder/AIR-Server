package be.aboutme.airserver.endpoints.socket.handlers.websocket
{
	import be.aboutme.airserver.endpoints.socket.handlers.SocketClientHandler;
	import be.aboutme.airserver.endpoints.socket.handlers.SocketClientHandlerFactory;
	import be.aboutme.airserver.messages.serialization.IMessageSerializer;
	import be.aboutme.airserver.messages.serialization.JSONSerializer;
	
	import flash.net.Socket;
	
	public class WebSocketClientHandlerFactory extends SocketClientHandlerFactory
	{
		
		public function WebSocketClientHandlerFactory(messageSerializer:IMessageSerializer = null, crossDomainPolicyXML:XML = null)
		{
			if(messageSerializer == null)
			{
				messageSerializer = new JSONSerializer();
			}
			super(messageSerializer, crossDomainPolicyXML);
		}
		
		override public function createHandler(socket:Socket):SocketClientHandler
		{
			return new WebSocketClientHandler(socket, messageSerializer, crossDomainPolicyXML);
		}
	}
}