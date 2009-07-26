package by.blooddy.core.net {

	public class LoaderPriority {
		
		public static const HIGHEST:int =					int.MAX_VALUE;
		
		public static const PRELOADER:int =					int.MAX_VALUE -1;

		public static const GUI_XML:int =					PRELOADER - 1;

		public static const GUI_CSS:int =					GUI_XML - 1;
		
		public static const GUI_GRAPHICS:int =				GUI_CSS - 1;

		public static const GUI_SOUND:int =				PRELOADING + 1;
		
		public static const PRELOADING:int = int.MIN_VALUE;

	}

}