////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.net {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.02.2010 1:02:32
	 */
	public final class Location {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _R_URL:RegExp = /^((\w+):\/\/([\w\.]+)(:(\d+))?(\/[^?#]*)?|([^?#]*))?(\?[^#]*)?(#.*)?$/;
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function isLocation(url:String, strict:Boolean=false):Boolean {
			if ( strict ) {
				var arr:Array = url.match( _R_URL );
				return ( arr && arr[ 1 ] );
			}
			return _R_URL.test( url );
		}
			
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function Location(url:String) {
			super();
			var arr:Array = url.match( _R_URL );
			if ( !arr ) throw new URIError();
			this.protocol =	arr[ 2 ];
			this.host =		arr[ 3 ];
			this.port =		arr[ 5 ];
			this.path =		arr[ 6 ] || arr[ 7 ];
			this.search =	arr[ 8 ];
			this.hash =		arr[ 9 ];
		}

		public var protocol:String;

		public var host:String;

		public var port:int;

		public function get hostname():String {
			return ( this.host ? this.host + ( this.port > 0 && this.port != 80 ? ':' + this.port : '' ) : '' );
		}

		public var path:String;

		public var search:String;

		public var hash:String;

		public function toString():String {
			return ( this.host ? ( this.protocol ? this.protocol + '://' : '' ) + this.hostname : '' ) + ( this.path ? ( this.path.charAt( 0 ) == '/' ? '' : '/' ) + this.path : '' ) + ( this.search || '' ) + ( this.hash || '' ); 
		}

	}

}