////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.styles {

	import by.blooddy.core.errors.ParserError;
	import by.blooddy.core.parsers.Token;
	import by.blooddy.core.parsers.TokenScanner;
	
	import flash.events.EventDispatcher;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 10, 2010 12:17:10 PM
	 */
	public class StyleSheet extends EventDispatcher {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _cssScanner:CSSScanner = new CSSScanner();

		/**
		 * @private
		 */
		private static const _tokenScanner:TokenScanner = new TokenScanner( _cssScanner );
		
		//--------------------------------------------------------------------------
		//
		//  Private static methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function readToken():Token {
			var tok:Token;
			do {
				tok = _tokenScanner.readToken();
			} while (
				tok.kind == CSSToken.LINE_COMMENT ||
				tok.kind == CSSToken.BLOCK_COMMENT
			);
			return tok;
		}

		/**
		 * @private
		 */
		private static function readFixToken(kind:uint):Token {
			var tok:Token = readToken();
			if ( tok.kind != kind ) throw new ParserError();
			return tok;
		}

		/**
		 * @private
		 */
		private static function readURL():String {
			var tok:Token = readFixToken( CSSToken.IDENTIFIER );
			if ( tok.text != 'url' ) throw new ParserError();
			readFixToken( CSSToken.LEFT_PAREN );
			tok = readFixToken( CSSToken.STRING_LITERAL );
			readFixToken( CSSToken.RIGHT_PAREN );
			return tok.text;
		}

		/**
		 * @private
		 */
		private static function readSelector():void {
			var tok:Token = readToken();
//			case CSSToken.HASH:
//			case CSSToken.DOT:
//			case CSSToken.IDENTIFIER:
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function StyleSheet() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function parseCSS(css:String):void {
			_cssScanner.writeSource( css );
			_tokenScanner.reset();
			var tok:Token;
			while ( true ) {
				try { // top-level обработка
 
					tok = readToken();
					switch ( tok.kind ) {

						case CSSToken.AT: // потенциальный импорт
							tok = readFixToken( CSSToken.IDENTIFIER );
							switch ( tok.text ) {
								case 'import':
									tok = readToken();
									if ( tok.kind == CSSToken.STRING_LITERAL ) {
										break;
									} else if ( tok.kind == CSSToken.IDENTIFIER && tok.text == 'url' ) {
										_tokenScanner.numToken--;
										readURL();
									} else {
										throw new ParserError();
									}
									break;
								case 'media':
									// TODO:

									
									
								default:
									throw new ParserError();
							}
							break;
						
						// начало селектора
						case CSSToken.HASH:
						case CSSToken.DOT:
						case CSSToken.IDENTIFIER:
							_tokenScanner.numToken--;
							readSelector();
							break;

						default:
							throw new ParserError();

					}
					
				} catch ( e:Error ) {
				}
			}
		}

	}
	
}



