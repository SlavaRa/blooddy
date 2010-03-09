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
			this._tokenContext = scanner.tokenContext;
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
		private var _tokenContext:TokenContext;

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
			}
		}

		public function getNextToken():int {
			var id:int = this._scanner.readToken();
			this._buffer.push(
				new TokenAsset(
					id,
					0 // TODO: добавить сюда позицию
				)
			);
			return id;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function getCurrentTokenKind():int {
			return this.getCurrentToken().kind;
		}

		public function getCurrentToken():Token {
			var asset:TokenAsset =  this._buffer[ this._numToken - 1 ] as TokenAsset;
			if ( !asset.tok ) {
				asset.tok = this._tokenContext.getToken( asset.id );
			}
			return asset.tok;
		}

		public function getCurrentPosition():uint {
			return ( this._buffer[ this._numToken - 1 ] as TokenAsset ).pos;
		}

		public function readToken():Token {
			this.numToken++;
			return this.getCurrentToken();
		}

		public function retract():void {
			this._numToken--;
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
//
		/**
		 * заменяет токены.
		 * например если надо разрезать *= на * и =
		 */
		public function replaceCurrentToken(...args):Token {
			var pos:uint = this.getCurrentPosition();
			for ( var i:Object in args ) {
				args[ i ] = new TokenAsset(
					args[ i ],
					pos
				);
			}
			args.unshift( this._numToken - 1, 1 );
			this._buffer.splice.apply( this._buffer, args );
			return this.getCurrentToken();
		}

	}

}

import by.blooddy.core.parsers.Token;

/**
 * @private
 */
internal final class TokenAsset {

	public function TokenAsset(id:int, pos:uint) {
		super();
		this.id = id;
		this.pos = pos;
	}

	public var id:int;

	public var tok:Token;

	public var pos:int;

}