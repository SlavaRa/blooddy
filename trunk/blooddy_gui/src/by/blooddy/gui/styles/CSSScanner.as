////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.styles {

	import by.blooddy.core.parsers.IScanner;
	import by.blooddy.core.parsers.TokenContext;
	import by.blooddy.core.utils.Char;
	import by.blooddy.core.errors.ParserError;

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
			this._tokenContext.addToken( CSSToken.IMPORT, '@import' );
			this._tokenContext.addToken( CSSToken.COLON, ':' );
			this._tokenContext.addToken( CSSToken.LEFT_BRACE, '{' );
			this._tokenContext.addToken( CSSToken.RIGHT_BRACE, '}' );
			this._tokenContext.addToken( CSSToken.HASH, '#' );
			this._tokenContext.addToken( CSSToken.DOT, '.' );
			this._tokenContext.addToken( CSSToken.COMMA, ',' );
			this._tokenContext.addToken( CSSToken.SEMI_COLON, ';' );
			this._tokenContext.addToken( CSSToken.IDENTIFIER, '' );
			this._tokenContext.addToken( CSSToken.STRING_LITERAL, '' );
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

		public function get lastToken():int {
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

		public function readToken():int {
			var c:uint;
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
					case Char.HASH:			return this.makeToken( CSSToken.HASH );
					case Char.DOT:			return this.makeToken( CSSToken.DOT );
					case Char.COMMA:		return this.makeToken( CSSToken.COMMA );
					case Char.SEMI_COLON:	return this.makeToken( CSSToken.SEMI_COLON );

					case Char.AT:
						if (
							this.readCharCode() == Char.i &&
							this.readCharCode() == Char.m &&
							this.readCharCode() == Char.p &&
							this.readCharCode() == Char.o &&
							this.readCharCode() == Char.r &&
							this.readCharCode() == Char.t
						) {
							return this.makeToken( CSSToken.IMPORT );
						}
						throw new ParserError();

					case Char.SINGLE_QUOTE:
					case Char.DOUBLE_QUOTE:
						this._position--;
						return this.makeToken( CSSToken.STRING_LITERAL, this.readString() );
						
					//default:
						

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
			var to:String = this.readChar();
			if ( to != '\'' && to != '\"' ) throw new ParserError();
			var result:String = '';
			var c:String;
			while ( ( c = this.readChar() ) != to ) {
				switch( c ) {
					case '\\':
						switch ( c = this.readChar() ) {
							case 'n':	c = '\n';	break;
							case 'r':	c = '\r';	break;
							case 't':	c = '\t';	break;
							case 'v':	c = '\v';	break;
							case 'f':	c = '\f';	break;
							case 'b':	c = '\b';	break;
							case 'x':
								c = this.readFixedHex( 2 );
								if ( c )	c = String.fromCharCode( parseInt( c, 16 ) );
								else		c = 'x';
								break;
							case 'u':
								c = this.readFixedHex( 4 );
								if ( c )	c = String.fromCharCode( parseInt( c, 16 ) );
								else		c = 'u';
								break;
							default:
								c = this.readChar();
								break;
						}
						break;
					case '\x00':
					case '\r':
					case '\n':
						this._position = pos; // откатываемся
						throw new ParserError();
				}
				result += c;
			}
			return result;
		}

		/**
		 * @private
		 */
		private function readFixedHex(length:uint=0):String {
			var result:String = '';
			var c:String;
			for ( var i:uint = 0; i<length; i++ ) {
				c = this.readChar();
				if (
					( c < '0' || c > '9' ) &&
					( c < 'a' || c > 'f' ) &&
					( c < 'A' || c > 'F' )
				) {
					this._position -= i;
					return null;
				}
				result += c;
			}
			return result;
		}

	}

}