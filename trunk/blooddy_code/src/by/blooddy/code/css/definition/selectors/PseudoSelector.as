////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css.definition.selectors {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					14.03.2010 17:36:46
	 */
	public class PseudoSelector extends AttributeSelector {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function PseudoSelector(value:String, selector:AttributeSelector=null) {
			super( value, selector );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/*
		 *       __
		 * AABBBBCC
		 */
		public override function getSpecificity():uint {
			if ( this.selector ) {
				return this.selector.getSpecificity() + 1;
			}
			return 0x00000001;
		}

		public override function toString():String {
			return ':' + this.value + ( this.selector || '' );
		}

	}
	
}