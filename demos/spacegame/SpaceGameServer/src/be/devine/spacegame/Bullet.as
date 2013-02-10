package be.devine.spacegame
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	public class Bullet extends Sprite
	{
		
		public static const RAD:Number = Math.PI / 180;
		public static const HALF_PI:Number = Math.PI / 2;
		
		public var spaceShip:SpaceShip;
		
		public var speed:Number = 0;
		
		private var ontstopper:Bitmap;
		
		public function Bullet(spaceShip:SpaceShip)
		{
			this.spaceShip = spaceShip;
			
			if(spaceShip.color == "green")
			{
				ontstopper = new Library.OntstopperGreen();
			}
			else
			{
				ontstopper = new Library.OntstopperRed();
			}
			
			ontstopper.smoothing = true;
			ontstopper.x = spaceShip.ontstopper.x;
			ontstopper.y = spaceShip.ontstopper.y;
			addChild(ontstopper);
		}
		
		public function update():void
		{
			this.x += Math.sin((this.rotation - 4) * RAD + HALF_PI) * speed;
			this.y += Math.cos((this.rotation - 4) * RAD + HALF_PI) * speed * -1;
		}
	}
}