package be.aboutme.ioslib.components
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class TextInput extends Sprite
	{
		
		private var widthChanged:Boolean;
		private var _width:Number = 229;

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
		private var _height:Number = 31;

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
		
		private var textChanged:Boolean;
		private var _text:String;

		public function get text():String
		{
			return _text;
		}

		public function set text(value:String):void
		{
			if(_text != value)
			{
				_text = value;
				textChanged = true;
				display();
				dispatchEvent(new Event(Event.CHANGE));
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
		
		private var labelWidthChanged:Boolean;
		private var _labelWidth:Number = 0;

		public function get labelWidth():Number
		{
			return _labelWidth;
		}

		public function set labelWidth(value:Number):void
		{
			if(_labelWidth != value)
			{
				_labelWidth = value;
				labelWidthChanged = true;
				layout();
			}
		}

		
		private var _measuredLabelWidth:Number = 0;
		public function get measuredLabelWidth():Number
		{
			return _measuredLabelWidth;
		}


		private var background:Sprite;
		private var inputField:TextField;
		private var labelField:TextField;
		
		public function TextInput()
		{
			background = new Sprite();
			addChild(background);
			
			inputField = new TextField();
			inputField.addEventListener(Event.CHANGE, inputChangeHandler);
			inputField.type = TextFieldType.INPUT;
			inputField.defaultTextFormat = new TextFormat("Helvetica", 15, 0x222222);
			addChild(inputField);
			
			labelField = new TextField();
			labelField.autoSize = TextFieldAutoSize.LEFT;
			labelField.selectable = false;
			labelField.defaultTextFormat = new TextFormat("Helvetica", 17, 0x000000, true);
			
			widthChanged = heightChanged = true;
			layout();
		}
		
		private function inputChangeHandler(event:Event):void
		{
			_text = inputField.text;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function drawBackground():void
		{
			background.graphics.clear();
			background.graphics.lineStyle(1, 0x000000, 0.7, true);
			background.graphics.beginFill(0xFFFFFF);
			background.graphics.drawRoundRect(0, 0, _width, _height, 8, 8);
			background.graphics.endFill();
		}
		
		private function display():void
		{
			if(labelChanged)
			{
				labelChanged = false;
				if(_label != null && _label.length > 0)
				{
					labelField.text = _label;
					_measuredLabelWidth = labelField.width;
					addChild(labelField);
				}
				else
				{
					labelField.text = "";
					_measuredLabelWidth = 0;
					removeChild(labelField);
				}
			}
			if(textChanged)
			{
				textChanged = false;
				inputField.text = _text;
			}
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
				labelField.x = inputField.x = 5;
				if(_label != null && _label.length > 0)
				{
					inputField.x += Math.max(_measuredLabelWidth, _labelWidth) + 5;
				}
				inputField.width = _width - inputField.x - 5;
			}
			if(labelWidthChanged)
			{
				labelWidthChanged = false;
				inputField.x = 5 + Math.max(_measuredLabelWidth, _labelWidth) + 5;
				inputField.width = _width - inputField.x - 5;
			}
			if(heightChanged)
			{
				heightChanged = false;
				inputField.height = (_height - 10);
				inputField.y = (_height - inputField.height) * .5;
				labelField.y = inputField.y - 1;
			}
		}
	}
}