package be.devine.spacegame.background
{
	import be.happybanana.libraries.project.as3web.view.BasicSprite;
	
	import flash.display.Bitmap;
	
	public class MeteorKoe extends BasicSprite
	{
		
		private var bmp:Bitmap;
		
		public function MeteorKoe()
		{
			bmp = new Library.Meteor2();
			bmp.smoothing = true;
			addChild(bmp);
		}
	}
}