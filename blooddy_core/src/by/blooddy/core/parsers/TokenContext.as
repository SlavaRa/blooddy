////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2008 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.parsers {

	/**
	 * @author			BlooDHounD
	 * @version			1.0
	 * @langversion		3.0
	 * @playerversion	9.0
	 */
	public final class TokenContext {

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
		private const _list:Vector.<Token> = new Vector.<Token>();

		/**
		 * @private
		 */
		private const _hash:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function hasToken(kind:int, text:String):Boolean {
			return ( this.getTokenID( kind, text ) > 0 );
		}

		public function addToken(kind:int, text:String):int {
			var id:int = this.getTokenID( kind, text );
			if ( !id ) {
				var tok:Token = new Token( kind, text );
				id = this._list.push( tok ) - 1;
				this._hash[ tok.getHash() ] = id;
			}
			return id;
		}

		public function getToken(id:int):Token {
			return this._list[ id ] as Token;
		}

		public function getTokenID(kind:int, text:String):int {
			return this._hash[ Token.getHash( kind, text ) ];
		}

	}

}