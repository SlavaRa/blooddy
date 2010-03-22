////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2008 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code {

	/**
	 * @author			BlooDHounD
	 * @version			1.0
	 * @langversion		3.0
	 * @playerversion	9.0
	 */
	public final class TokenContext {

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @param	kind	
		 * @param	text	
		 * 
		 * @return	
		 */
		public static function getHash(kind:uint, text:String):String {
			return String.fromCharCode( kind >>> 16 ) + String.fromCharCode( kind & 0xFFFF ) + ( text || '\x00' );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function TokenContext() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _hash:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function has(kind:uint, text:String):Boolean {
			return getHash( kind, text ) in this._hash;
		}

		public function add(kind:uint, text:String):void {
			this._hash[ getHash( kind, null ) ] = new Token( kind, text );
		}
		
		public function get(kind:uint, text:String):Token {
			var key:String = getHash( kind, text );
			var tok:Token = this._hash[ key ];
			if ( !tok ) {
				this._hash[ key ] = tok = new Token( kind, text );
			}
			return tok;
		}

	}

}