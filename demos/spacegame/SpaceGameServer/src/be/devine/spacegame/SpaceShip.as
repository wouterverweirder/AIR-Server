package be.devine.spacegame
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class SpaceShip extends Sprite
	{
		public static const SHOOT:String = "shoot";
		public static const EXPLODED_CHANGED:String = "explodedChanged";
		
		public static const RAD:Number = Math.PI / 180;
		public static const HALF_PI:Number = Math.PI / 2;
		
		public var steering:Number = 0;
		public var engine:Number = 0;
		
		public var speed:Number = 0;
		private var steeringSpeed:Number = 0;
		
		private var wolk:WolkGroot;
		
		private var _rotation:Number = 0;

		override public function get rotation():Number
		{
			return _rotation;
		}

		override public function set rotation(value:Number):void
		{
			_rotation = value;
			super.rotation = _rotation;
		}

		public var calculatedRotation:Number = 0;
		public var calculatedX:Number = 0;
		public var calculatedY:Number = 0;
		
		public var color:String;
		
		public var ontstopper:Bitmap;
		private var vliegtuig:Bitmap;
		private var motor:Sprite;
		private var vlam:BasicMotorVlam;
		
		private var shootDelay:uint = 1000;

		private var reloadTimer:Timer;
		
		private var _loaded:Boolean;
		
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		public function set loaded(value:Boolean):void
		{
			if(_loaded != value)
			{
				_loaded = value;
				ontstopper.visible = _loaded;
			}
		}
		
		private var _exploded:Boolean;

		public function get exploded():Boolean
		{
			return _exploded;
		}

		public function set exploded(value:Boolean):void
		{
			if(_exploded != value)
			{
				_exploded = value;
				//visualize explosion
				wolk.visible = _exploded;
				ontstopper.visible = vliegtuig.visible = motor.visible = !wolk.visible;
				if(_exploded)
				{
					wolk.gotoAndPlay(1);
				}
				//dispatch event
				dispatchEvent(new Event(EXPLODED_CHANGED));
			}
		}

		
		public function SpaceShip(color:String)
		{
			this.color = color;
			
			motor = new Sprite();
			
			vlam = new BasicMotorVlam();
			vlam.x = -24;
			vlam.y = 3;
			vlam.visible = false;
			motor.addChild(vlam);
			
			var motorBitmap:Bitmap;
			if(color == "green")
			{
				ontstopper = new Library.OntstopperGreen();
				vliegtuig = new Library.VliegtuigGreen();
				motorBitmap = new Library.MotorGreen();
			}
			else
			{
				ontstopper = new Library.OntstopperRed();
				vliegtuig = new Library.VliegtuigRed();
				motorBitmap = new Library.MotorRed();
			}
			
			motorBitmap.x = motorBitmap.width * -.5;
			motorBitmap.y = motorBitmap.height * -.5;
			motor.addChild(motorBitmap);
			
			ontstopper.smoothing = vliegtuig.smoothing = motorBitmap.smoothing = true;
			
			wolk = new WolkGroot();
			wolk.visible = false;
			wolk.stop();
			wolk.addEventListener(Event.COMPLETE, wolkCompleteHandler);
			
			addChild(ontstopper);
			addChild(vliegtuig);
			addChild(motor);
			addChild(wolk);
			
			vliegtuig.x = Math.round(vliegtuig.width * -.5);
			vliegtuig.y = Math.round(vliegtuig.height * -.5) - 15;
			
			ontstopper.x = vliegtuig.x + 72;
			ontstopper.y = vliegtuig.y;
			motor.x = vliegtuig.x - motorBitmap.x + 12;
			motor.y = vliegtuig.y - motorBitmap.y + 46;
			wolk.x = wolk.y = -15;

			reloadTimer = new Timer(shootDelay, 1);
			reloadTimer.addEventListener(TimerEvent.TIMER, reloadTimerHandler, false, 0, true);
			loaded = true;
		}
		
		public function shoot():void
		{
			if(loaded)
			{
				loaded = false;
				reloadTimer.reset();
				reloadTimer.start();
				dispatchEvent(new Event(SHOOT));
			}
		}
		
		public function explode():void
		{
			this.exploded = true;
		}
		
		private function wolkCompleteHandler(event:Event):void
		{
			this.exploded = false;
		}
		
		private function reloadTimerHandler(event:TimerEvent):void
		{
			reloadTimer.stop();
			loaded = true;
		}
		
		public function calculateNewCoords():void
		{
			this.speed += engine;
			this.speed *= 0.95;
			
			this.calculatedRotation = rotation + (steering - rotation) * .1;
			this.calculatedX = this.x + Math.sin(calculatedRotation * RAD + HALF_PI) * speed;
			this.calculatedY = this.y + Math.cos(calculatedRotation * RAD + HALF_PI) * speed * -1;
		}
		
		public function applyNewCoords():void
		{
			var motorRotation:Number = -(steering - rotation);
			motorRotation = Math.min(20, Math.max(-20, motorRotation));
			this.motor.rotation = motorRotation;
			this.rotation = this.calculatedRotation;
			this.x = this.calculatedX;
			this.y = this.calculatedY;
			
			vlam.visible = (engine > 0.3 || (Math.abs(motorRotation) > 10) && engine >= 0);
		}
	}
}