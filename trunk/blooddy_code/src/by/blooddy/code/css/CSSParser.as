////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css {

	import by.blooddy.code.css.selectors.AttributeSelector;
	import by.blooddy.code.css.selectors.CSSDeclaration;
	import by.blooddy.code.css.selectors.CSSSelector;
	import by.blooddy.code.css.selectors.ChildSelector;
	import by.blooddy.code.css.selectors.ClassSelector;
	import by.blooddy.code.css.selectors.DescendantSelector;
	import by.blooddy.code.css.selectors.IDSelector;
	import by.blooddy.code.css.selectors.PseudoSelector;
	import by.blooddy.code.css.selectors.TagSelector;
	import by.blooddy.code.errors.ParserError;
	
	import flash.events.EventDispatcher;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 10, 2010 12:17:10 PM
	 */
	public class CSSParser extends EventDispatcher {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function CSSParser() {
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
		private const _scanner:CSSScanner = new CSSScanner();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function parse(value:String):void {
			this._scanner.writeSource( value );
			var tok:uint;
			do {
				//try { // top-level обработка

					tok = this.readToken();
					switch ( tok ) {

						case CSSToken.AT:
							tok = this.readFixToken( CSSToken.IDENTIFIER, false );
							switch ( this._scanner.tokenText ) {
								case 'import':
									// url
									this.readURL(); // result url
									// media
									tok = this.readToken();
									if ( tok == CSSToken.IDENTIFIER ) {
										this._scanner.tokenText; // result media
									} else {
										this._scanner.retreat();
									}
									this.readFixToken( CSSToken.SEMI_COLON );
									break;
								case 'media':
									tok = this.readFixToken( CSSToken.IDENTIFIER );
									this._scanner.tokenText; // result media
									this.readFixToken( CSSToken.LEFT_BRACE );
									// TODO: read content
									this.readFixToken( CSSToken.RIGHT_BRACE );
								default:
									throw new ParserError();
							}
							break;

						// начало селектора
						case CSSToken.HASH:
						case CSSToken.DOT:
						case CSSToken.IDENTIFIER:
						case CSSToken.COLON:
							this._scanner.retreat();
							var c:Vector.<CSSSelector> = this.readSelectors();
							this.readDeclaration();
							trace( c );
							break;
						
						default:
							throw new ParserError();
							
					}
					
				//} catch ( e:Error ) {
				//	trace( e.getStackTrace() );
				//}
			} while ( tok == CSSToken.EOF );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function readToken(ignoreWhite:Boolean=true, ignoreComments:Boolean=true):uint {
			var tok:uint;
			do {
				tok = this._scanner.readToken();
			} while (
				( ignoreWhite && tok == CSSToken.WHITESPACE ) ||
				( ignoreComments && tok == CSSToken.BLOCK_COMMENT )
			);
			return tok;
		}

		/**
		 * @private
		 */
		private function readFixToken(kind:uint, ignoreWhite:Boolean=true, ignoreComments:Boolean=true):uint {
			var tok:uint = this.readToken( ignoreWhite, ignoreComments );
			if ( tok != kind ) throw new ParserError();
			return tok;
		}

		/**
		 * @private
		 */
		private function readURL():String {
			var result:String;
			var tok:uint = this.readToken();
			if ( tok == CSSToken.STRING_LITERAL ) {
				result = this._scanner.tokenText;
			} else if ( tok == CSSToken.IDENTIFIER && this._scanner.tokenText == 'url' ) {
				this.readFixToken( CSSToken.LEFT_PAREN, true, false );
				tok = this.readToken( true, false );
				if ( tok == CSSToken.STRING_LITERAL ) {
					result = this._scanner.tokenText;
				} else {
					result = '';
					do {
						if ( tok == CSSToken.WHITESPACE || tok == CSSToken.RIGHT_PAREN || tok == CSSToken.EOF ) {
							this._scanner.retreat();
							break;
						}
						switch ( tok ) {
							case CSSToken.STRING_LITERAL:
								throw new ParserError();
							case CSSToken.BLOCK_COMMENT:
								result += '/*' + this._scanner.tokenText + '*/';
								break;
							default:
								result += this._scanner.tokenText;
								break;
						}
						tok = this._scanner.readToken();
					} while ( true );
				}
				this.readFixToken( CSSToken.RIGHT_PAREN, true, false );
			} else {
				throw new ParserError();
			}
			return result;
		}

		/**
		 * @private
		 */
		private function readSelectors():Vector.<CSSSelector> {
			var result:Vector.<CSSSelector> = new Vector.<CSSSelector>();
			var tok:uint;
			do {
				result.push( this.readSelector( new CSSSelector() ) );
			} while ( this.readToken() == CSSToken.COMMA );
			this._scanner.retreat();
			return result;
		}
		
		/**
		 * @private
		 */
		private function readSelector(child:CSSSelector):CSSSelector {
			child.selector = this.readAttributeSelector();
			switch ( this._scanner.readToken() ) {
				case CSSToken.LEFT_BRACE:
				case CSSToken.COMMA:
					this._scanner.retreat();
					return child;
				case CSSToken.RIGHT_ANGLE:
					return this.readSelector( new ChildSelector( child ) );
				case CSSToken.WHITESPACE:
					switch ( this.readToken() ) {
						case CSSToken.LEFT_BRACE:
						case CSSToken.COMMA:
							this._scanner.retreat();
							return child;
						case CSSToken.RIGHT_ANGLE:
							return this.readSelector( new ChildSelector( child ) );
					}
					this._scanner.retreat();
					return this.readSelector( new DescendantSelector( child ) );
			}
			throw new ParserError();
		}

		/**
		 * @private
		 */
		private function readAttributeSelector():AttributeSelector {
			switch ( this.readToken() ) {
				case CSSToken.IDENTIFIER:
					return this.readSelectorAfterTag( new TagSelector( this._scanner.tokenText ) );
				case CSSToken.HASH:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					return new IDSelector( this._scanner.tokenText, this.readSelectorAfterID() );
				case CSSToken.DOT:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					return new ClassSelector( this._scanner.tokenText, this.readSelectorAfterClass() );
				case CSSToken.COLON:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					return new PseudoSelector( this._scanner.tokenText );
			}
			return null;
		}

		/**
		 * @private
		 */
		private function readSelectorAfterTag(tag:TagSelector):AttributeSelector {
			switch ( this._scanner.readToken() ) {
				case CSSToken.HASH:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					var result:IDSelector = new IDSelector( this._scanner.tokenText, tag );
					tag.selector = this.readSelectorAfterID();
					return result;
				case CSSToken.DOT:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					tag.selector = new ClassSelector( this._scanner.tokenText, this.readSelectorAfterClass() );
					break;
				case CSSToken.COLON:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					tag.selector = new PseudoSelector( this._scanner.tokenText );
					break;
				default:
					this._scanner.retreat();
					break;
			}
			return tag;
		}

		/**
		 * @private
		 */
		private function readSelectorAfterID():AttributeSelector {
			switch ( this._scanner.readToken() ) {
				case CSSToken.DOT:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					return new ClassSelector( this._scanner.tokenText, this.readSelectorAfterClass() );
				case CSSToken.COLON:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					return new PseudoSelector( this._scanner.tokenText );
				default:
					this._scanner.retreat();
					break;
			}
			return null;
		}

		/**
		 * @private
		 */
		private function readSelectorAfterClass():AttributeSelector {
			var result:AttributeSelector;
			switch ( this._scanner.readToken() ) {
				case CSSToken.DOT:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					result = new ClassSelector( this._scanner.tokenText );
					result.selector = this.readSelectorAfterClass();
					break;
				case CSSToken.COLON:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					result = new PseudoSelector( this._scanner.tokenText );
					break;
				default:
					this._scanner.retreat();
					break;
			}
			return result;
		}

		/**
		 * @private
		 */
		private function readDeclaration():CSSDeclaration {
			this.readFixToken( CSSToken.LEFT_BRACE );
			var result:CSSDeclaration = new CSSDeclaration();
			var tok:uint;
			while ( true ) {
				tok = this.readToken();
				if ( tok == CSSToken.RIGHT_BRACE ) break;
				this._scanner.retreat();
				this.readDeclarationName();
				this.readFixToken( CSSToken.COLON );
				this.readDeclarationValue();
			}
			return result;
		}

		/**
		 * @private
		 */
		private function readDeclarationName():String {
			var result:String = '';
			var t:String;
			var u:Boolean = false;
			var tok:uint = this.readToken();
			do {
				switch ( tok ) {
					case CSSToken.DASH:
						u = true;
						break;
					case CSSToken.IDENTIFIER:
						t = this._scanner.tokenText.toLowerCase();
						result += ( u ? t.charAt( 0 ).toUpperCase() + t.substr( 1 ) : t );
						break;
					default:
						this._scanner.retreat();
						return result;
				}
			} while ( tok = this._scanner.readToken() );
			return result;
		}
		
		/**
		 * @private
		 */
		private function readDeclarationValue():Array {
			var result:Array = new Array();
			var t:String;
			do {
				switch ( this.readToken() ) {

					case CSSToken.RIGHT_BRACE:
						this._scanner.retreat();
					case CSSToken.SEMI_COLON:
						return result;

					case CSSToken.STRING_LITERAL:
						result.push( this._scanner.tokenText );
						break;
					case CSSToken.IDENTIFIER:
						t = this._scanner.tokenText;
						switch ( t.toLowerCase() ) {
							case 'true':	result.push( true );	break;
							case 'false':	result.push( false );	break;
							default:		result.push( t );		break;
						}
						break;
					case CSSToken.NUMBER_LITERAL:
						var n:Number = parseFloat( this._scanner.tokenText );
						if ( n % 1 == 0 && n > int.MIN_VALUE ) {
							if ( n < int.MAX_VALUE ) {
								result.push( int( n ) );
								break;
							} else if ( n < uint.MAX_VALUE ) {
								result.push( uint( n ) );
								break;
							}
						}
						result.push( n );
						break;
				}
			} while ( true );
			return result;
		}
		
	}

}