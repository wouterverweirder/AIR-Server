package be.aboutme.airserver.endpoints.socket.handlers.amf
{
	import be.aboutme.airserver.endpoints.socket.handlers.SocketClientHandler;
	import be.aboutme.airserver.endpoints.socket.handlers.SocketClientHandlerFactory;
	import be.aboutme.airserver.messages.serialization.IMessageSerializer;
	import be.aboutme.airserver.messages.serialization.NativeObjectSerializer;
	
	import flash.net.Socket;
	
	public class AMFSocketClientHandlerFactory extends SocketClientHandlerFactory
	{
		public function AMFSocketClientHandlerFactory(messageSerializer:IMessageSerializer = null, crossDomainPolicyXML:XML = null)
		{
			if(messageSerializer == null)
			{
				messageSerializer = new NativeObjectSerializer();
			}
			super(messageSerializer, crossDomainPolicyXML);
		}
		
		override public function createHandler(socket:Socket):SocketClientHandler
		{
			return new AMFSocketClientHandler(socket, messageSerializer, crossDomainPolicyXML);
		}
	}
}