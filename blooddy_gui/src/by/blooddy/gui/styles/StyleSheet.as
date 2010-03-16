////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.styles {

	import by.blooddy.core.errors.ParserError;
	
	import flash.events.EventDispatcher;
	import by.blooddy.code.css.CSSParser;
	
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
		private static const _cssParser:CSSParser = new CSSParser();

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
			_cssParser.parse( css );
		}

	}
	
}



