package be.happybanana.libraries.project.as3web.view
{
	import flash.display.Sprite;
	
	
	public class BasicSprite extends Sprite
	{
		
		protected var objectWidthChanged:Boolean = true;
		protected var _objectWidth:Number = 0;
		
		public function get objectWidth():Number
		{
			return _objectWidth;
		}
		
		public function set objectWidth(value:Number):void
		{
			setSize(value, _objectHeight);
		}
		
		protected var objectHeightChanged:Boolean = true;
		protected var _objectHeight:Number = 0;
		
		public function get objectHeight():Number
		{
			return _objectHeight;
		}
		
		public function set objectHeight(value:Number):void
		{
			setSize(_objectWidth, value);
		}
		
		public function BasicSprite()
		{
		}
		
		/**
		 * This function updates the dimensions of the Sprite,
		 * and calls the layout function when the dimensions are updated
		 */ 
		public final function setSize(width:Number, height:Number):void
		{
			if(_objectWidth != width)
			{
				_objectWidth = width;
				objectWidthChanged = true;
			}
			if(_objectHeight != height)
			{
				_objectHeight = height;
				objectHeightChanged = true;
			}
			if(objectWidthChanged || objectHeightChanged)
			{
				layout();
				objectWidthChanged = objectHeightChanged = false;
			}
		}
		
		public function layout():void
		{
		}
	}
}