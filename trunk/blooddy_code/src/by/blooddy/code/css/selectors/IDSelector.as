////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css.selectors {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					14.03.2010 17:18:03
	 */
	public class IDSelector extends AttributeSelector {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function IDSelector(id:String, selector:AttributeSelector=null) {
			super( id, selector );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function toString():String {
			if ( this.selector is TagSelector ) {
				return ( this.selector.value || '' ) + ( this.value ? '#' + this.value : '' ) + ( this.selector.selector || '' );
			} else {
				return ( this.value ? '#' + this.value : '' ) + ( this.selector || '' );
			}
		}

	}
	
}