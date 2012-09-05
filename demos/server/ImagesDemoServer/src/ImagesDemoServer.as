package
{
	import be.aboutme.airserver.AIRServer;
	import be.aboutme.airserver.endpoints.socket.SocketEndPoint;
	import be.aboutme.airserver.endpoints.socket.handlers.amf.AMFSocketClientHandlerFactory;
	import be.aboutme.airserver.events.MessageReceivedEvent;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.utils.ByteArray;
	
	public class ImagesDemoServer extends Sprite
	{
		
		private var server:AIRServer;
		private var ldr:Loader;
		
		public function ImagesDemoServer()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.nativeWindow.visible = true;
			
			ldr = new Loader();
			addChild(ldr);
			
			server = new AIRServer();
			server.addEndPoint(new SocketEndPoint(1234, new AMFSocketClientHandlerFactory()));
			server.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceivedHandler, false, 0, true);
			server.start();
		}
		
		protected function messageReceivedHandler(event:MessageReceivedEvent):void
		{
			switch(event.message.command)
			{
				case "IMAGE":
					var jpgBytes:ByteArray = event.message.data;
					ldr.loadBytes(jpgBytes);
					break;
			}
		}
	}
}