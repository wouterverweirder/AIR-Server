package be.aboutme.airserver.endpoints.socket.handlers
{
	import be.aboutme.airserver.messages.serialization.IMessageSerializer;
	
	import flash.net.Socket;

	public class SocketClientHandlerFactory
	{
		
		protected var messageSerializer:IMessageSerializer;
		protected var crossDomainPolicyXML:XML;
		
		public function SocketClientHandlerFactory(messageSerializer:IMessageSerializer, crossDomainPolicyXML:XML = null)
		{
			this.messageSerializer = messageSerializer;
			this.crossDomainPolicyXML = crossDomainPolicyXML;
		}
		
		public function createHandler(socket:Socket):SocketClientHandler
		{
			return new SocketClientHandler(socket, messageSerializer, crossDomainPolicyXML);
		}
	}
}