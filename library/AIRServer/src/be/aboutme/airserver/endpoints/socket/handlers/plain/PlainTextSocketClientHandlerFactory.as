package be.aboutme.airserver.endpoints.socket.handlers.plain
{
	import be.aboutme.airserver.endpoints.socket.handlers.SocketClientHandler;
	import be.aboutme.airserver.endpoints.socket.handlers.SocketClientHandlerFactory;
	import be.aboutme.airserver.messages.serialization.IMessageSerializer;
	import be.aboutme.airserver.messages.serialization.PlainTextSerializer;
	
	import flash.net.Socket;
	
	public class PlainTextSocketClientHandlerFactory extends SocketClientHandlerFactory
	{
		
		public function PlainTextSocketClientHandlerFactory(messageSerializer:IMessageSerializer = null, crossDomainPolicyXML:XML = null)
		{
			if(messageSerializer == null)
			{
				messageSerializer = new PlainTextSerializer();
			}
			super(messageSerializer, crossDomainPolicyXML);
		}
		
		override public function createHandler(socket:Socket):SocketClientHandler
		{
			return new PlainTextSocketClientHandler(socket, messageSerializer, crossDomainPolicyXML);
		}
	}
}