////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css.definition {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					18.04.2010 18:39:09
	 */
	public class CSSMedia {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function CSSMedia(name:String=null) {
			super();
			this._name = name;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _name:String;

		public function get name():String {
			return this._name;
		}

		public const rules:Vector.<CSSRule> = new Vector.<CSSRule>();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function toString():String {
			var h:Boolean = ( this.name && this.name != 'screen' );
			return ( h ? '@media ' + this.name + '{' : '' ) + this.rules.join( '' ) + ( h ? '}' : '' );
		}

	}

}