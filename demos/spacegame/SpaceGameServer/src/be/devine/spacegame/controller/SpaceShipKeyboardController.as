package be.devine.spacegame.controller
{
	import be.devine.spacegame.inputSources.keyboard.KeyboardInputSource;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class SpaceShipKeyboardController extends SpaceShipController
	{
		
		private var keyboardInputSource:KeyboardInputSource;
		
		public function SpaceShipKeyboardController()
		{
			keyboardInputSource = KeyboardInputSource.getInstance();
			
			keyboardInputSource.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys, false, 0, true);
			keyboardInputSource.addEventListener(KeyboardEvent.KEY_UP, handleKeys, false, 0, true);
		}
		
		private function handleKeys(event:Event):void
		{
			if(keyboardInputSource.isDown(Keyboard.SHIFT))
			{
				calibrated = true;
				dispatchEvent(new Event(CALIBRATED));
			}
			if(spaceShip != null)
			{
				if(steeringEnabled)
				{
					if(keyboardInputSource.isDown(Keyboard.LEFT)) spaceShip.steering += -5;
					else if(keyboardInputSource.isDown(Keyboard.RIGHT)) spaceShip.steering += 5;
					//else spaceShip.steering = 0;
				}
				else
				{
					//spaceShip.steering = 0;
				}
				if(engineEnabled)
				{
					if(keyboardInputSource.isDown(Keyboard.UP)) spaceShip.engine = 1;
					else if(keyboardInputSource.isDown(Keyboard.DOWN)) spaceShip.engine = -1;
					else spaceShip.engine = 0;
				}
				else
				{
					spaceShip.engine = 0;
				}
				if(shootingEnabled)
				{
					if(keyboardInputSource.isDown(Keyboard.SPACE)) spaceShip.shoot();
				}
			}
		}
	}
}