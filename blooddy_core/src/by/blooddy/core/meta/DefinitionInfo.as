////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.meta {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					06.03.2010 0:37:29
	 */
	public class DefinitionInfo extends AbstractInfo {
		
		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected_inf;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function DefinitionInfo() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$protected_inf var _name:QName;

		public function get name():QName {
			return this._name;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function toXML():XML {
			var xml:XML = super.toXML();
			xml.setName( new QName( ns_rdf, 'Description' ) );
			// title
			var dc:XML = <title />;
			dc.setNamespace( ns_dc );
			dc.appendChild( this._name );
			xml.appendChild( dc );
			return xml;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected_inf override function parseXML(xml:XML):void {
			var list:XMLList = xml.metadata;
		}

	}
	
}