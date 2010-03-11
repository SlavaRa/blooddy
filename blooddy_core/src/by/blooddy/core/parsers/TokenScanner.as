////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2008 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.parsers {

	import flash.events.EventDispatcher;

	/**
	 * @author			BlooDHounD
	 * @version			1.0
	 * @langversion		3.0
	 * @playerversion	9.0
	 */
	public class TokenScanner extends EventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function TokenScanner(scanner:IScanner) {
			super();
			this._scanner = scanner;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _scanner:IScanner;

		/**
		 * @private
		 */
		private const _buffer:Vector.<TokenAsset> = new Vector.<TokenAsset>();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _numToken:uint = 0;

		public function get numToken():uint {
			return this._numToken;
		}

		/**
		 * @private
		 */
		public function set numToken(value:uint):void {
			if ( this._numToken == value ) return;
			this._numToken = value;
			while ( this._numToken > this._buffer.length ) {
				var id:uint = this._scanner.readToken();
				this._buffer.push(
					new TokenAsset(
						id,
						this._scanner.tokenContext.getToken( id ),
						this._scanner.lastPosition
					)
				);
			}
		}

		public function get currentToken():Token {
			return this._buffer[ this._numToken - 1 ].token;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function readToken():Token {
			this.numToken++;
			return this.currentToken;
		}

//		public function match(kind:int, strict:Boolean=false):Boolean {
//			if ( this.getCurrentTokenKind() != kind ) {
//				if ( strict ) {
//					throw "нефига не то, что ожидается";
//				} else {
//					return false;
//				}
//			}
//			this.numToken++;
//			return true;
//		}

	}

}

import by.blooddy.core.parsers.Token;

/**
 * @private
 */
internal final class TokenAsset {

	public function TokenAsset(id:int, token:Token, pos:uint) {
		super();
		this.id = id;
		this.token = token;
		this.pos = pos;
	}

	public var id:int;

	public var token:Token;

	public var pos:int;

}