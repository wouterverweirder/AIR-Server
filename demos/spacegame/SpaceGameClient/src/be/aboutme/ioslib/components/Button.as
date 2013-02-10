package be.aboutme.ioslib.components
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class Button extends Sprite
	{
		
		private var widthChanged:Boolean;
		private var _width:Number = 290;
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function set width(value:Number):void
		{
			if(_width != value)
			{
				_width = value;
				widthChanged = true;
				layout();
			}
		}
		
		private var heightChanged:Boolean;
		private var _height:Number = 46;
		
		override public function get height():Number
		{
			return _height;
		}
		
		override public function set height(value:Number):void
		{
			if(_height != value)
			{
				_height = value;
				heightChanged = true;
				layout();
			}
		}
		
		private var labelChanged:Boolean;
		private var _label:String;
		
		public function get label():String
		{
			return _label;
		}
		
		public function set label(value:String):void
		{
			if(_label != value)
			{
				_label = value;
				labelChanged = true;
				display();
			}
		}
		
		private var background:Sprite;
		private var labelField:TextField;
		
		public function Button()
		{
			mouseChildren = false;
			
			background = new Sprite();
			addChild(background);
			
			labelField = new TextField();
			labelField.filters = [new BevelFilter(1, 90, 0xFFFFFF, 0, 0x000000, 0.56, 0, 0, 1.4, 1, "outer")];
			labelField.selectable = false;
			labelField.defaultTextFormat = new TextFormat("Helvetica", 21, 0xFFFFFF, true);
			labelField.autoSize = TextFieldAutoSize.LEFT;
			labelField.multiline = labelField.wordWrap = false;
			
			widthChanged = heightChanged = true;
			layout();
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			background.alpha = 0.5;
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			background.alpha = 1;
		}
		
		private function display():void
		{
			if(labelChanged)
			{
				labelChanged = false;
				if(_label != null && _label.length > 0)
				{
					labelField.text = _label;
					addChild(labelField);
				}
				else
				{
					labelField.text = "";
					removeChild(labelField);
				}
				labelField.x = (_width - labelField.width) * .5;
				labelField.y = (_height - labelField.height) * .5;
			}
		}
		
		private function drawBackground():void
		{
			while(background.numChildren > 0)
			{
				background.removeChildAt(0);
			}
			
			var bg1:Sprite = new Sprite();
			bg1.filters = [new BevelFilter(1, 90, 0xFFFFFF, 0.66, 0x000000, 0.26, 2, 2)];
			var bgm1:Matrix = new Matrix();
			bgm1.createGradientBox(_width, _height, Math.PI * .5);
			bg1.graphics.lineStyle(1, 0x2c2c2c, 0.9, true);
			bg1.graphics.beginGradientFill(GradientType.LINEAR, [0x009c0c, 0x009e10, 0x2caa37, 0x86c28c], [1, 1, 1, 1], [0, 127, 128, 255], bgm1);
			bg1.graphics.drawRoundRect(0, 0, _width, _height, 20);
			bg1.graphics.endFill();
			background.addChild(bg1);
			
			
		}
		
		private function layout():void
		{
			if(widthChanged || heightChanged)
			{
				drawBackground();
			}
			if(widthChanged)
			{
				widthChanged = false;
				labelField.x = (_width - labelField.width) * .5;
			}
			if(heightChanged)
			{
				heightChanged = false;
				labelField.y = (_height - labelField.height) * .5;
			}
		}
	}
}