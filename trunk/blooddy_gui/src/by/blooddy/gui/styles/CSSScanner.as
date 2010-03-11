////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.styles {

	import by.blooddy.core.errors.ParserError;
	import by.blooddy.core.parsers.IScanner;
	import by.blooddy.core.parsers.TokenContext;
	import by.blooddy.core.utils.Char;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.03.2010 23:35:53
	 */
	public class CSSScanner implements IScanner {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function CSSScanner() {
			super();
			this._tokenContext.addToken( CSSToken.EOF, String.fromCharCode( 0 ) );
			this._tokenContext.addToken( CSSToken.COLON, ':' );
			this._tokenContext.addToken( CSSToken.LEFT_BRACE, '{' );
			this._tokenContext.addToken( CSSToken.RIGHT_BRACE, '}' );
			this._tokenContext.addToken( CSSToken.LEFT_PAREN, '{' );
			this._tokenContext.addToken( CSSToken.RIGHT_PAREN, '}' );
			this._tokenContext.addToken( CSSToken.HASH, '#' );
			this._tokenContext.addToken( CSSToken.DOT, '.' );
			this._tokenContext.addToken( CSSToken.COMMA, ',' );
			this._tokenContext.addToken( CSSToken.DASH, '-' );
			this._tokenContext.addToken( CSSToken.AT, '@' );
			this._tokenContext.addToken( CSSToken.SEMI_COLON, ';' );
			this._tokenContext.addToken( CSSToken.IDENTIFIER, '' );
			this._tokenContext.addToken( CSSToken.STRING_LITERAL, '' );
			this._tokenContext.addToken( CSSToken.BLOCK_COMMENT, '' );
			this._tokenContext.addToken( CSSToken.LINE_COMMENT, '' );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _source:String;

		/**
		 * @private
		 */
		private var _position:uint;
		
		/**
		 * @private
		 */
		private var _line:uint;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _tokenContext:TokenContext = new TokenContext();

		public function get tokenContext():TokenContext {
			return this._tokenContext;
		}

		/**
		 * @private
		 */
		private var _lastToken:int;

		public function get lastToken():uint {
			return this._lastToken;
		}

		/**
		 * @private
		 */
		private var _lastPosition:int;

		public function get lastPosition():uint {
			return this._lastPosition;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function writeSource(source:String):void {
			this._lastPosition = 0;
			this._lastToken = CSSToken.EOF;
			this._source = source;
		}

		public function readToken():uint {
			var c:uint;
			var t:String;
			while ( ( c = this.readCharCode() ) != Char.EOS ) {

				this._lastPosition = this._position - 1;

				switch ( c ) {

					// white space
					case Char.SPACE:
					case Char.TAB:
					case Char.VERTICAL_TAB:
					case Char.LS:
					case Char.PS:
					case Char.BACKSPACE:
					case Char.FORM_FEED:
						break;

					case Char.CARRIAGE_RETURN:
						if ( this.readCharCode() != Char.NEWLINE ) {
							this._position--;
						}
						this._line++;
						break;
					case Char.NEWLINE:
						this._line++;
						break;

					case Char.COLON:		return this.makeToken( CSSToken.COLON );
					case Char.LEFT_BRACE:	return this.makeToken( CSSToken.LEFT_BRACE );
					case Char.RIGHT_BRACE:	return this.makeToken( CSSToken.RIGHT_BRACE );
					case Char.LEFT_PAREN:	return this.makeToken( CSSToken.LEFT_PAREN );
					case Char.RIGHT_PAREN:	return this.makeToken( CSSToken.RIGHT_PAREN );
					case Char.HASH:			return this.makeToken( CSSToken.HASH );
					case Char.DOT:			return this.makeToken( CSSToken.DOT );
					case Char.COMMA:		return this.makeToken( CSSToken.COMMA );
					case Char.DASH:			return this.makeToken( CSSToken.DASH );
					case Char.AT:			return this.makeToken( CSSToken.AT );
					case Char.SEMI_COLON:	return this.makeToken( CSSToken.SEMI_COLON );

					case Char.SINGLE_QUOTE:
					case Char.DOUBLE_QUOTE:
						this._position--;
						t = this.readString();
						if ( t != null ) return this.makeToken( CSSToken.STRING_LITERAL, t );
						throw new ParserError();

					case Char.SLASH:
						switch ( this.readCharCode() ) {
							case Char.ASTERISK:
								this._position -= 2;
								t = this.readBlockComment();
								if ( t != null ) return this.makeToken( CSSToken.BLOCK_COMMENT, t );
								throw new ParserError();
							case Char.SLASH:
								return this.makeToken( CSSToken.LINE_COMMENT, this.readLine() );
						}
						throw new ParserError();

					default:
						this._position--;
						if (
							( c >= Char.a && c <= Char.z ) ||
							( c >= Char.A && c <= Char.Z ) ||
							c == Char.DOLLAR ||
							c == Char.UNDER_SCORE ||
							c > 0x7f
						) {
							return this.makeToken( CSSToken.IDENTIFIER, this.readIdentifier() );
						}
						throw new ParserError();

				}
				
			}
			return CSSToken.EOF;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function readCharCode():uint {
			return this._source.charCodeAt( this._position++ );
		}

		/**
		 * @private
		 */
		private function readChar():String {
			return this._source.charAt( this._position++ );
		}
		
		/**
		 * @private
		 */
		private function makeToken(kind:uint, text:String=null):uint {
			if ( text == null ) {
				this._lastToken = kind;
			} else {
				this._lastToken = this._tokenContext.addToken( kind, text );
			}
			return this._lastToken;
		}

		/**
		 * @private
		 */
		private function readString():String {
			var pos:uint = this._position;
			var to:uint = this.readCharCode();
			if ( to != Char.SINGLE_QUOTE && to != Char.DOUBLE_QUOTE ) throw new ParserError();
			var p:uint = pos + 1;
			var result:String = '';
			var c:uint, t:String;
			while ( ( c = this.readCharCode() ) != to ) {
				switch ( c ) {
					case Char.BACK_SLASH:
						result += this._source.substring( p, this._position - 1 );
						switch ( c = this.readCharCode() ) {
							case Char.n:	result += '\n';	break;
							case Char.r:	result += '\r';	break;
							case Char.t:	result += '\t';	break;
							case Char.v:	result += '\v';	break;
							case Char.f:	result += '\f';	break;
							case Char.b:	result += '\b';	break;
							case Char.x:
								t = this.readFixedHex( 2 );
								if ( t )	result += String.fromCharCode( parseInt( t, 16 ) );
								else		result += 'x';
								break;
							case Char.u:
								t = this.readFixedHex( 4 );
								if ( t )	result += String.fromCharCode( parseInt( t, 16 ) );
								else		result += 'u';
								break;
							default:
								result += this.readChar();
								break;
						}
						p = this._position;
						break;
					case Char.EOS:
					case Char.CARRIAGE_RETURN:
					case Char.NEWLINE:
						this._position = pos; // откатываемся
						return null;
				}
			}
			return result + this._source.substring( p, this._position - 1 );
		}

		/**
		 * @private
		 */
		private function readIdentifier():String {
			var pos:uint = this._position;
			var c:uint = this.readCharCode();
			if ( 
				( c < Char.a || c > Char.z ) &&
				( c < Char.A || c > Char.Z ) &&
				c != Char.DOLLAR &&
				c != Char.UNDER_SCORE &&
				c <= 0x7f
			) {
				this._position--;
				return null;
			}
			do {
				c = this.readCharCode();
			} while (
				( c >= Char.a && c <= Char.z ) ||
				( c >= Char.A && c <= Char.Z ) ||
				( c >= Char.ZERO && c <= Char.NINE ) ||
				c == Char.DOLLAR ||
				c == Char.UNDER_SCORE ||
				c > 0x7f
			);
			this._position--;
			return this._source.substring( pos, this._position );
		}

		/**
		 * @private
		 */
		private function readFixedHex(length:uint=0):String {
			var c:uint;
			for ( var i:uint = 0; i<length; i++ ) {
				c = this.readCharCode();
				if (
					( c < Char.ZERO || c > Char.NINE ) &&
					( c < Char.a || c > Char.f ) &&
					( c < Char.A || c > Char.F )
				) {
					this._position -= i;
					return null;
				}
			}
			return this._source.substring( this._position - i, this._position );
		}

		/**
		 * @private
		 */
		private function readLineTo(to:uint):String {
			var pos:uint = this._position;
			var c:uint;
			do {
				c = this.readCharCode();
				if ( c == Char.NEWLINE || c == Char.CARRIAGE_RETURN || c == Char.EOS ) {
					this._position = pos;
					return null;
				}
			} while ( c != to );
			this._position--;
			return this._source.substring( pos, this._position );
		}
		
		/**
		 * @private
		 */
		private function readLine():String {
			var pos:uint = this._position;
			var c:uint;
			do {
				c = this.readCharCode();
			} while ( c != Char.NEWLINE && c != Char.CARRIAGE_RETURN && c != Char.EOS );
			this._position--;
			return this._source.substring( pos, this._position );
		}

		/**
		 * @private
		 */
		private function readBlockComment():String {
			var pos:uint = this._position;
			if (
				this.readCharCode() != Char.SLASH ||
				this.readCharCode() != Char.ASTERISK
			) {
				this._position = pos;
				return null;
			}
			do {
				switch ( this.readCharCode() ) {
					case Char.ASTERISK:
						if ( this.readCharCode() == Char.SLASH ) {
							return this._source.substring( pos + 2, this._position - 2 );
						} else {
							this._position--;
						}
						break;
					case Char.CARRIAGE_RETURN:
						if ( this.readCharCode() != Char.NEWLINE ) {
							this._position--;
						}
						this._line++;
						break;
					case Char.NEWLINE:
						this._line++;
						break;
					case Char.EOS:
						this._position = pos;
						return null;
				}
			} while ( true );
			this._position = pos;
			return null;
		}
		
	}

}