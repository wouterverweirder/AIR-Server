package be.devine.spacegame.background
{
	import be.happybanana.libraries.project.as3web.view.BasicSprite;
	
	public class Auto extends BasicSprite
	{
		private var anim:BasicAuto;
		
		public function Auto()
		{
			anim = new BasicAuto();
			addChild(anim);
		}
	}
}