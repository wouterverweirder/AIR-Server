package be.devine.spacegame.controller
{
	import be.devine.spacegame.SpaceShip;
	
	import flash.events.EventDispatcher;

	public class SpaceShipController extends EventDispatcher
	{
		
		public static const STATE_WAITING_FOR_CONNECTIONS:String = "waitingForConnections";
		public static const STATE_CALIBRATE:String = "calibrate";
		public static const STATE_COUNTING_DOWN:String = "countingDown";
		public static const STATE_PLAYING:String = "playing";
		public static const STATE_WIN:String = "win";
		public static const STATE_LOSE:String = "lose";
		
		public static const CALIBRATED:String = "calibrated";
		public static const DISCONNECTED:String = "disconnected";
		
		public var spaceShip:SpaceShip;
		public var playerName:String;
		
		public var calibrated:Boolean;
		public var isWinner:Boolean;
		
		protected var _state:String;

		public function get state():String
		{
			return _state;
		}

		public function set state(value:String):void
		{
			if(value != _state)
			{
				_state = value;
				stateChanged();
			}
		}
		
		public var shootingEnabled:Boolean = true;
		public var steeringEnabled:Boolean = true;
		public var engineEnabled:Boolean = true;
		
		public function SpaceShipController()
		{
		}
		
		public function destroy():void
		{
		}
		
		protected function stateChanged():void
		{
		}
		
	}
}