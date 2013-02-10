package be.devine.spacegame.controller
{
	import be.aboutme.airserver.Client;
	import be.aboutme.airserver.events.MessageReceivedEvent;
	import be.aboutme.airserver.messages.Message;
	
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public class SpaceShipSocketController extends SpaceShipController
	{
		
		private var _client:Client;
		
		public function get client():Client
		{
			return _client;
		}
		
		public function SpaceShipSocketController(client:Client)
		{
			super();
			this._client = client;
			
			this._client.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceivedHandler, false, 0, true);
			this._client.addEventListener(Event.CLOSE, closeHandler, false, 0, true);
		}
		
		override public function destroy():void
		{
			super.destroy();
			this._client.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceivedHandler);
			this._client.removeEventListener(Event.CLOSE, closeHandler);
			this._client = null;
		}
		
		private function messageReceivedHandler(event:MessageReceivedEvent):void
		{
			trace("Message Received: " + event.message.command.toUpperCase() + " " + getTimer());
			switch(event.message.command.toUpperCase())
			{
				case "CALIBRATED":
					calibrated = true;
					dispatchEvent(new Event(CALIBRATED));
					break;
				case "ACCELEROMETER":
					//x, y, z
					spaceShip.engine = 0.4;
					var rot:Number = event.message.data.x;
					if(!isNaN(rot) && rot > -1 && rot < 1)
					{
						spaceShip.steering = rot * -180;
					}
					break;
				case "SHOOT":
					spaceShip.shoot();
					break;
			}
		}
		
		private function closeHandler(event:Event):void
		{
			dispatchEvent(new Event(DISCONNECTED));
		}
		
		override protected function stateChanged():void
		{
			super.stateChanged();
			var message:Message = new Message();
			message.data = {player: playerName, color: spaceShip.color};
			switch(_state)
			{
				case STATE_WAITING_FOR_CONNECTIONS:
					message.command = "WAITING_FOR_CONNECTIONS";
					break;
				case STATE_CALIBRATE:
					message.command = "CALIBRATE";
					break;
				case STATE_COUNTING_DOWN:
					message.command = "COUNTING_DOWN";
					break;
				case STATE_PLAYING:
					message.command = "PLAYING";
					break;
				case STATE_WIN:
					message.command = "WIN";
					break;
				case STATE_LOSE:
					message.command = "LOSE";
					break;
			}
			_client.sendMessage(message);
		}
	}
}