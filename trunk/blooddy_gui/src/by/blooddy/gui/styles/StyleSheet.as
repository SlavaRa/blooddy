////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.styles {

	import by.blooddy.core.parsers.TokenScanner;
	import by.blooddy.core.parsers.Token;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 10, 2010 12:17:10 PM
	 */
	public class StyleSheet {
		
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
			var cssScanner:CSSScanner = new CSSScanner();
			cssScanner.writeSource( css );
			var tokenScanner:TokenScanner = new TokenScanner( cssScanner );
			var tok:Token;
			while ( tok = tokenScanner.readToken() ) {
				trace( tok );
			}
		}

	}
	
}