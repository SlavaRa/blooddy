////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.styles {

	import by.blooddy.core.parsers.IScanner;
	import by.blooddy.core.parsers.TokenContext;

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

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _tokenContext:TokenContext;

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
			this._source = source;
		}

		public function readToken():int {
			return 0;
		}

	}

}