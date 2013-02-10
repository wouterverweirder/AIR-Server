package be.devine.spacegame.inputSources.keyboard
{
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	
	public class KeyboardInputSource extends EventDispatcher
	{
		
		private static var instance:KeyboardInputSource;
		
		public static function getInstance():KeyboardInputSource
		{
			if(instance == null)
			{
				instance = new KeyboardInputSource(new Enforcer());
			}
			return instance;
		}
		
		private var initialized:Boolean;
		
		private var keysDown:Array;
		
		public function KeyboardInputSource(enforcer:Enforcer)
		{
			if(enforcer == null)
			{
				throw new Error("KeyboardInputSource is a Singleton and cannot be instantiated");
			}
			keysDown = [];
		}
		
		public function init(stage:Stage):void
		{
			if(!initialized)
			{
				initialized = true;
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
				stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			}
		}
		
		private function keyDownHandler(event:KeyboardEvent):void
		{
			if(keysDown.indexOf(event.keyCode) == -1)
			{
				keysDown.push(event.keyCode);
			}
			dispatchEvent(event);
		}
		
		private function keyUpHandler(event:KeyboardEvent):void
		{
			var index:int = keysDown.indexOf(event.keyCode);
			if(index > -1)
			{
				keysDown.splice(index, 1);
			}
			dispatchEvent(event);
		}
		
		public function isDown(keyCode:uint):Boolean
		{
			return (keysDown.indexOf(keyCode) > -1);
		}
	}
}
internal class Enforcer{};