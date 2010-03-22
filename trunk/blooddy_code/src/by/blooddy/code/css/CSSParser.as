////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css {

	import by.blooddy.code.Token;
	import by.blooddy.code.css.selectors.AttributeSelector;
	import by.blooddy.code.css.selectors.ClassSelector;
	import by.blooddy.code.css.selectors.IDSelector;
	import by.blooddy.code.css.selectors.PseudoSelector;
	import by.blooddy.code.css.selectors.TypeSelector;
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
			while ( true ) {
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
									this.readSemicolon();
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
							var c:AttributeSelector = this.readSelector();
							trace( c );
							break;
						
						default:
							throw new ParserError();
							
					}
					
				//} catch ( e:Error ) {
				//	trace( e.getStackTrace() );
				//}
			}
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
		private function readSemicolon():void {
			this.readFixToken( CSSToken.SEMI_COLON );
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
		private function readSelector():AttributeSelector {
			var child:AttributeSelector;
			var tok:uint = this._scanner.readToken();
			switch ( tok ) {
				case CSSToken.IDENTIFIER:
					child = new TypeSelector( this._scanner.tokenText );
					child.selector = this.readSelectorAfterIdentifier( child );
					break;
				case CSSToken.HASH:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					child = new IDSelector( this._scanner.tokenText );
					child.selector = this.readSelectorAfterID( child );
					break;
				case CSSToken.DOT:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					child = new ClassSelector( this._scanner.tokenText );
					child.selector = this.readSelectorAfterID( child );
					break;
				case CSSToken.COLON:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					child = new PseudoSelector( this._scanner.tokenText );
					child.selector = this.readSelectorAfterPseudo( child );
					break;
			}
			if ( child ) return child;
			throw new ParserError();
		}

		/**
		 * @private
		 */
		private function readSelectorAfterIdentifier(parent:AttributeSelector):AttributeSelector {
			var child:AttributeSelector;
			var tok:uint = this._scanner.readToken();
			switch ( tok ) {
				case CSSToken.HASH:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					child = new IDSelector( this._scanner.tokenText );
					child.selector = parent;
					return this.readSelectorAfterID( child );
				case CSSToken.DOT:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					child = new ClassSelector( this._scanner.tokenText );
					child.selector = parent;
					return this.readSelectorAfterID( child );
				case CSSToken.COLON:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					child = new PseudoSelector( this._scanner.tokenText );
					child.selector = parent;
					return this.readSelectorAfterPseudo( child );
				case CSSToken.WHITESPACE:
				case CSSToken.BLOCK_COMMENT:
					this._scanner.retreat();
					switch ( tok ) {
						case CSSToken.RIGHT_ANGLE:
						case CSSToken.COMMA:
						case CSSToken.LEFT_BRACE:
							return parent;
					}
					return this.readSelector();
				case CSSToken.COMMA:
				case CSSToken.RIGHT_ANGLE:
					return parent;
			}
			throw new ParserError();
		}

		/**
		 * @private
		 */
		private function readSelectorAfterID(parent:AttributeSelector):AttributeSelector {
			var child:AttributeSelector;
			var tok:uint = this._scanner.readToken();
			switch ( tok ) {
				case CSSToken.DOT:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					child = new ClassSelector( this._scanner.tokenText );
					child.selector = parent;
					return this.readSelectorAfterID( child );
				case CSSToken.COLON:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					child = new PseudoSelector( this._scanner.tokenText );
					child.selector = parent;
					return this.readSelectorAfterPseudo( child );
				case CSSToken.WHITESPACE:
				case CSSToken.BLOCK_COMMENT:
					this._scanner.retreat();
					switch ( tok ) {
						case CSSToken.RIGHT_ANGLE:
						case CSSToken.COMMA:
						case CSSToken.LEFT_BRACE:
							return parent;
					}
					return this.readSelector();
				case CSSToken.COMMA:
				case CSSToken.RIGHT_ANGLE:
					return parent;
			}
			throw new ParserError();
		}
		
		/**
		 * @private
		 */
		private function readSelectorAfterPseudo(parent:AttributeSelector):AttributeSelector {
			var child:AttributeSelector;
			var tok:uint = this._scanner.readToken();
			switch ( tok ) {
				case CSSToken.WHITESPACE:
				case CSSToken.BLOCK_COMMENT:
					this._scanner.retreat();
					switch ( tok ) {
						case CSSToken.RIGHT_ANGLE:
						case CSSToken.COMMA:
						case CSSToken.LEFT_BRACE:
							return parent;
					}
					return this.readSelector();
				case CSSToken.COMMA:
				case CSSToken.RIGHT_ANGLE:
					return parent;
			}
			throw new ParserError();
		}
		
	}

}