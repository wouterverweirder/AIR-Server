package be.aboutme.airserver.util
{
	public class IDGenerator
	{
		private static var counter:uint;
		
		public static function getUniqueId():uint
		{
			return counter++;
		}
	}
}