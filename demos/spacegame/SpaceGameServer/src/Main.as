package
{
	import be.devine.spacegame.SpaceGame;
	import be.devine.spacegame.inputSources.keyboard.KeyboardInputSource;
	import be.happybanana.libraries.project.as3web.view.BasicSprite;
	
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.Font;
	
	[SWF(backgroundColor="#000000")]
	public class Main extends Sprite
	{
		
		private var app:BasicSprite;
		
		public function Main()
		{
			init();
		}
		
		private function init(event:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			if(stage != null)
			{
				if(this.parent is Stage)
				{
					stage.align = StageAlign.TOP_LEFT;
					stage.scaleMode = StageScaleMode.NO_SCALE;
					
					KeyboardInputSource.getInstance().init(stage);
					
					if(NativeWindow.isSupported)
					{
						stage.nativeWindow.visible = true;
						stage.nativeWindow.width = 1024;
						stage.nativeWindow.height = 768;
						stage.nativeWindow.x = 0;
						stage.nativeWindow.y = 0;
					}
					
					startApplication();
					
					stage.addEventListener(Event.RESIZE, resizeHandler, false, 0, true);
					layout();
				}
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			}
		}
		
		private function startApplication():void
		{
			app = new SpaceGame();
			addChild(app);
		}
		
		private function resizeHandler(event:Event):void
		{
			layout();
		}
		
		private function layout():void
		{
			app.setSize(1024, 768);
			app.x = Math.round((stage.stageWidth - app.width) * .5);
		}
	}
}