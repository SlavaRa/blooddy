////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.net {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.02.2010 0:00:41
	 */
	public final class URLUtils {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _BACKWARD:RegExp = /^(\.\.\/+)+/g;

		/**
		 * @private
		 */
		private static const _BACKWARDS:RegExp = /\.\.\/+/g;
		
		/**
		 * @private
		 */
		private static const _FORWARD:RegExp = /[^\/]\/+$/g;
		
		/**
		 * @private
		 */
		private static const _FORWARDS:RegExp = /(\/+[^\/])+\/*$/g;
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function getAbsoluteURL(relativeRoot:String, relativeURL:String):String {
			var urlLoc:Location = new Location( relativeURL );
			if ( urlLoc.host ) return relativeURL;
			var loc:Location = new Location( relativeRoot );
			if ( loc.search || loc.hash ) throw new URIError();
			if ( urlLoc.path.charAt( 0 ) == '/' ) { // урыл просится начинаться с рута
				loc.path = urlLoc.path;
			} else {
				loc.path += ( loc.path.charAt( loc.path.length - 1 ) == '/' ? '' : '/' ) + urlLoc.path;
			}
			loc.search = urlLoc.search;
			loc.hash = urlLoc.hash;
			return loc.toString();
		}

	}
	
}