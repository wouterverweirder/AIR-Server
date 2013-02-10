package be.devine.spacegame.mobilecontroller.view
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class SpaceGameButton extends Sprite
	{
		
		private var _label:String;

		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			_label = value;
			labelField.text = value;
		}

		
		private var background:Bitmap;
		private var labelField:TextField;
		
		public function SpaceGameButton()
		{
			mouseChildren = false;
			buttonMode = true;
			
			background = new Library.KnopBackground();
			addChild(background);
			
			labelField = new TextField();
			labelField.embedFonts = true;
			labelField.selectable = false;
			labelField.multiline = false;
			labelField.defaultTextFormat = new TextFormat("Silom", 41, 0xFFFFFF, null, null, null, null, null, "center");
			labelField.width = background.width;
			labelField.y = 21;
			addChild(labelField);
		}
	}
}