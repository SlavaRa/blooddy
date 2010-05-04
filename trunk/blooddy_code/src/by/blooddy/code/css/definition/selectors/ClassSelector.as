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
	 * @created					14.03.2010 17:30:21
	 */
	public class ClassSelector extends AttributeSelector {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function ClassSelector(styleClass:String, selector:AttributeSelector=null) {
			super( styleClass, selector );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/*
		 *   ____
		 * AABBBBCC
		 */
		public override function getSpecificity():uint {
			if ( this.selector ) {
				var result:uint = this.selector.getSpecificity();
				var v:uint = ( ( result & 0x00FFFF00 ) >> 8 ) + 1;
				return ( result & 0xFF0000FF ) | ( v << 8 );
			}
			return 0x00000100;
		}

		public override function toString():String {
			return '.' + this.value + ( this.selector || '' );
		}

	}
	
}