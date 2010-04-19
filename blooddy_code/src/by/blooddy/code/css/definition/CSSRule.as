////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css.definition {

	import by.blooddy.code.css.definition.selectors.CSSSelector;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					18.04.2010 6:03:15
	 */
	public class CSSRule {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function CSSRule(selector:CSSSelector, declarations:Vector.<CSSDeclaration>) {
			super();
			this.selector = selector;
			this.declarations = declarations;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var selector:CSSSelector;

		public var declarations:Vector.<CSSDeclaration>;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function toString():String {
			return this.selector + '{' + this.declarations.join( ';' ) + '}';
		}

	}
	
}