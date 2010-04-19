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
	public class AttributeSelector {
		
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

	}

}