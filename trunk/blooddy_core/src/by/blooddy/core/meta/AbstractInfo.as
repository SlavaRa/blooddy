////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.meta {

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="namespace", name="$protected_info" )]

	[Exclude( kind="method", name="parseXML" )]

	[ExcludeClass]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					06.03.2010 13:18:17
	 */
	public class AbstractInfo {
		
		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------
		
		protected namespace $protected_info;
		
		use namespace $protected_info;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function AbstractInfo() {
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function toXML():XML {
			return new XML();
		}

		public function toString():String {
			return this.toXML().toXMLString();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		$protected_info function parseXML(xml:XML):void {
		}
		
	}
	
}