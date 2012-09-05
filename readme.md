# AIR Server

AIR Server is a library to create socket servers in Adobe AIR for desktop applications. Some of the features are:

* 	Multiple clients
* 	Listen on multiple ports
* 	Regular text-sockets
* 	Websockets
* 	UDP traffic
* 	P2P traffic
* 	AMF Encoding over sockets
* 	Multi-part image data

##example code

	var server:AIRServer = new AIRServer();
	
	server.addEndPoint(
		new SocketEndPoint(
			1234,
			new AMFSocketClientHandlerFactory()
		)
	);
	
	server.addEventListener(AIRServerEvent.CLIENT_ADDED,
		clientAddedHandler);
				server.addEventListener(AIRServerEvent.CLIENT_REMOVED,
		clientRemovedHandler);
				server.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,
		messageReceivedHandler);
		
	function clientAddedHandler(event:AIRServerEvent):void
	{
		trace("Client added: " + event.client.id + "\n");
	}
			
	function clientRemovedHandler(event:AIRServerEvent):void
	{
		trace("Client removed: " + event.client.id + "\n");
	}
	
	function messageReceivedHandler(event:MessageReceivedEvent):void
	{
		trace("<client" + event.message.senderId + "> " + 
				event.message.data + "\n");
	}