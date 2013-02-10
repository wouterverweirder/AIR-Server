package be.devine.spacegame.background
{
	import be.happybanana.libraries.project.as3web.view.BasicSprite;
	
	import flash.display.Bitmap;
	
	public class Ballon extends BasicSprite
	{
		
		private var bmp:Bitmap;
		
		public function Ballon()
		{
			bmp = new Library.Ballon();
			bmp.smoothing = true;
			addChild(bmp);
		}
	}
}