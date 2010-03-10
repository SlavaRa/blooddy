////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2008 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.parsers {

	import by.blooddy.core.utils.IHashable;

	/**
	 * @author			BlooDHounD
	 * @version			1.0
	 * @langversion		3.0
	 * @playerversion	9.0
	 */
	public class Token implements IHashable {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @param	kind	
		 * @param	text	
		 * 
		 * @return	
		 */
		public static function getHash(kind:uint, text:String):String {
			return String.fromCharCode( kind >>> 16 ) + String.fromCharCode( kind & 0xFFFF ) + text;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	kind	
		 * @param	text	
		 */
		public function Token(kind:uint, text:String) {
			super();
			this._kind = kind;
			this._text = text;
			this._hash = Token.getHash( kind, text );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _hash:String;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  kind
		//----------------------------------

		/**
		 * @private
		 */
		private var _kind:uint;

		public function get kind():uint {
			return this._kind;
		}

		//----------------------------------
		//  text
		//----------------------------------

		/**
		 * @private
		 */
		private var _text:String;

		public function get text():String {
			return this._text;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function getHash():String {
			return this._hash;
		}

		/**
		 * @private
		 */
		public function toString():String {
			return '{ kind=' + this._kind + ', text="' + this._text+ '" }';
		}

	}

}