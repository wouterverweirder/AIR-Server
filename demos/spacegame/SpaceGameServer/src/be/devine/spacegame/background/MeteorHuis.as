package be.devine.spacegame.background
{
	import be.happybanana.libraries.project.as3web.view.BasicSprite;
	
	import flash.display.Bitmap;
	
	public class MeteorHuis extends BasicSprite
	{
		
		private var bmp:Bitmap;
		
		public function MeteorHuis()
		{
			bmp = new Library.Meteor1();
			bmp.smoothing = true;
			addChild(bmp);
		}
	}
}