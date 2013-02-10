package be.devine.spacegame.background
{
	import be.happybanana.libraries.project.as3web.view.BasicSprite;
	
	import flash.display.Bitmap;
	
	public class Bird extends BasicSprite
	{
		private var bmp:Bitmap;
		
		public function Bird()
		{
			bmp = new Library.Bird();
			bmp.smoothing = true;
			addChild(bmp);
		}
	}
}