package be.devine.spacegame.mobilecontroller.view
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	public class CalibrationRadar extends Sprite
	{
		public static const CALIBRATED:String = "calibrated";
		
		private var _player:String;

		public function get player():String
		{
			return _player;
		}

		public function set player(value:String):void
		{
			if(_player != value)
			{
				_player = value;
				playerField.text = _player;
			}
		}

		private var isOKTime:uint;
		private var _isOK:Boolean;

		public function get isOK():Boolean
		{
			return _isOK;
		}

		public function set isOK(value:Boolean):void
		{
			if(_isOK != value)
			{
				_isOK = value;
				displayOKStatus();
				if(_isOK)
				{
					isOKTime = getTimer();
				}
			}
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if(visible)
			{
				addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
			}
			else
			{
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}

		public var targetAngle:Number = 0;
		private var _angle:Number = 0;

		public function get angle():Number
		{
			return _angle;
		}

		public function set angle(value:Number):void
		{
			_angle = value;
			schijfContainer.rotation = _angle;
			if(Math.abs(schijfContainer.rotation) < 10)
			{
				schijfContainer.rotation = 0;
				isOK = true;
			}
			else
			{
				isOK = false;
			}
		}

		
		private var horizonRed:Bitmap;
		private var horizonGreen:Bitmap;
		private var schijf:Bitmap;
		private var linesRed:Bitmap;
		private var linesGreen:Bitmap;
		private var playerField:TextField;
		
		private var schijfContainer:Sprite;
		
		public function CalibrationRadar()
		{
			super();
			mouseEnabled = mouseChildren = false;
			
			horizonGreen = new Library.CalibrateHorizonGreen();
			horizonGreen.x = Math.round(horizonGreen.width * -.5);
			addChild(horizonGreen);
			
			horizonRed = new Library.CalibrateHorizonRed();
			horizonRed.x = Math.round(horizonRed.width * -.5);
			addChild(horizonRed);
			
			schijfContainer = new Sprite();
			schijfContainer.y = 10;
			addChild(schijfContainer);
			
			schijf = new Library.CalibrateSchijf();
			schijf.smoothing = true;
			schijf.x = Math.round(schijf.width * -.5);
			schijf.y = Math.round(schijf.height * -.5);
			schijfContainer.addChild(schijf);
			
			linesGreen = new Library.CalibrateLinesGreen();
			linesGreen.smoothing = true;
			linesGreen.x = Math.round(linesGreen.width * -.5);
			linesGreen.y = -8;
			schijfContainer.addChild(linesGreen);
			
			linesRed = new Library.CalibrateLinesRed();
			linesRed.smoothing = true;
			linesRed.x = Math.round(linesRed.width * -.5);
			linesRed.y = -8;
			schijfContainer.addChild(linesRed);
			
			playerField = new TextField();
			playerField.embedFonts = true;
			playerField.selectable = false;
			playerField.defaultTextFormat = new TextFormat("Silom", 25, 0xc3bdba, null, null, null, null, null, "center");
			playerField.width = horizonGreen.width;
			playerField.x = Math.round(playerField.width * -.5);
			playerField.y = -48;
			schijfContainer.addChild(playerField);
			
			displayOKStatus();
			schijfContainer.cacheAsBitmap = true;
			schijfContainer.cacheAsBitmapMatrix = new Matrix();
		}
		
		private function enterFrameHandler(event:Event):void
		{
			angle += (targetAngle - angle) * .3;
			if(_isOK && (getTimer() - isOKTime) > 1000)
			{
				dispatchEvent(new Event(CALIBRATED));
			}
		}
		
		private function displayOKStatus():void
		{
			horizonGreen.visible = _isOK;
			horizonRed.visible = !_isOK;
			linesGreen.visible = _isOK;
			linesRed.visible = !_isOK;
		}
	}
}