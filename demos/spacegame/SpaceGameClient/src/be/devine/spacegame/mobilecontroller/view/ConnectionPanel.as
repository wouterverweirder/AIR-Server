package be.devine.spacegame.mobilecontroller.view
{
	import be.devine.spacegame.mobilecontroller.model.ApplicationModel;
	import be.aboutme.ioslib.components.Button;
	import be.aboutme.ioslib.components.TextInput;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class ConnectionPanel extends Sprite
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
		private var _height:Number = 0;
		
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
		
		public function get hostName():String
		{
			return hostNameInput.text;
		}
		
		public function get port():uint
		{
			return uint(portInput.text);
		}
		
		private var hostNameInput:TextInput;
		private var portInput:TextInput;
		private var connectButton:Button;
		
		private var applicationModel:ApplicationModel;
		
		public function ConnectionPanel()
		{
			applicationModel = ApplicationModel.getInstance();
			
			hostNameInput = new TextInput();
			hostNameInput.x = 5;
			hostNameInput.y = 5;
			hostNameInput.label = "Hostname";
			hostNameInput.text = applicationModel.getSetting("hostname", "127.0.0.1");
			addChild(hostNameInput);
			
			portInput= new TextInput();
			portInput.x = hostNameInput.x;
			portInput.y = hostNameInput.y + hostNameInput.height + 5;
			portInput.label = "Port";
			portInput.text = applicationModel.getSetting("port", "1234");
			addChild(portInput);
			
			connectButton = new Button();
			connectButton.addEventListener(MouseEvent.CLICK, connectClickHandler);
			connectButton.label = "Connect";
			connectButton.x = portInput.x;
			connectButton.y = portInput.y + portInput.height + 10;
			addChild(connectButton);
			
			var maxLabelWidth:uint = 0;
			maxLabelWidth = Math.max(hostNameInput.measuredLabelWidth, portInput.measuredLabelWidth);
			hostNameInput.labelWidth = portInput.labelWidth = maxLabelWidth;
			
			_height = connectButton.y + connectButton.height;
			widthChanged = heightChanged = true;
			layout();
		}
		
		private function connectClickHandler(event:Event):void
		{
			applicationModel.saveSetting("hostname", hostNameInput.text, true);
			applicationModel.saveSetting("port", portInput.text, true);
			dispatchEvent(new Event(Event.CONNECT));
		}
		
		private function layout():void
		{
			if(widthChanged)
			{
				widthChanged = false;
				hostNameInput.width = _width;
				portInput.width = _width;
				connectButton.width = _width;
			}
			if(heightChanged)
			{
				heightChanged = false;
			}
		}
	}
}