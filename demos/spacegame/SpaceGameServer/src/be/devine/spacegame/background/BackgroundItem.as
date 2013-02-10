package be.devine.spacegame.background
{
	import be.happybanana.libraries.project.as3web.view.BasicSprite;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	
	public class BackgroundItem extends BasicSprite
	{
		
		private var counter:uint;
		private var itemList:Vector.<Class>;
		private var asset:DisplayObject;
		
		public function BackgroundItem(itemList:Vector.<Class>)
		{
			this.itemList = itemList;
		}
		
		public function reset():void
		{
			if(asset != null)
			{
				asset.parent.removeChild(asset);
				asset = null;
			}
			TweenLite.killTweensOf(this);
			TweenLite.delayedCall(0, delayedStart);
		}
		
		public function delayedStart():void
		{
			//create the asset
			asset = new itemList[counter % itemList.length]();
			if(asset is Bitmap) (asset as Bitmap).smoothing = true;
			addChild(asset);
			
			var directionX:int = (Math.random() > 0.5) ? 1 : -1;
			var directionY:int = (Math.random() > 0.5) ? 1 : -1;
			
			if(asset is Auto)
			{
				directionX = 1;
			}
			else if(asset is Ballon)
			{
				directionX = 1;
				directionY = -1;
			}
			
			var startX:Number = _objectWidth * .5 * -directionX;
			var startY:Number = _objectHeight * .5 * -directionY * Math.random();
			
			if(asset is Ballon)
			{
				startX += _objectWidth * Math.random();
				startY = _objectHeight * .5;
			}
			
			var targetX:Number = _objectWidth * .5 * directionX;
			var targetY:Number = _objectHeight * .5 * directionY * Math.random();
			
			if(asset is Auto) targetY = startY;
			else if(asset is Ballon)
			{
				targetX = startX;
				targetY = _objectHeight * -.5;
			}
			
			asset.x = startX;
			asset.y = startY;
			//var duration:Number = 20 + Math.random() * 10;
			var duration:Number = 20;
			TweenLite.to(asset, duration, {x: targetX, y: targetY, ease: Linear.easeNone, onComplete: reset});
			counter++;
		}
	}
}