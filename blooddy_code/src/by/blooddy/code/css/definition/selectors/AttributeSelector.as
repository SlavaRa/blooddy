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
	 * @created					14.03.2010 17:17:05
	 */
	public class AttributeSelector implements ISelector {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function AttributeSelector(value:String, selector:AttributeSelector=null) {
			super();
			this.value = value;
			this.selector = selector;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var selector:AttributeSelector
		
		public var value:String;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function contains(target:AttributeSelector):Boolean {
			return	( this as Object ).constructor === ( target as Object ).constructor &&
					this.value == target.value && (
						!target.selector ||
						( this.selector && this.selector.contains( target.selector ) )
					);
		}

		public function getSpecificity():uint {
			return ( this.selector ? this.selector.getSpecificity() : 0 );
		}

		public function toString():String {
			return ( this.selector ? this.selector.toString() : '' );
		}

	}

}