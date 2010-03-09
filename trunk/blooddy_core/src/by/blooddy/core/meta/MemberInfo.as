////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.meta {

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="property", name="_owner" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					06.03.2010 2:08:41
	 */
	public class MemberInfo extends DefinitionInfo implements ITypedInfo {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected_info;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function MemberInfo() {
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
		protected var _type:QName;
		
		/**
		 * @inheritDoc
		 */
		public function get type():QName {
			return this._type;
		}

		$protected_info var _owner:TypeInfo;
		
		public function get owner():TypeInfo {
			return this._owner;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function toXML():XML {
			var xml:XML = super.toXML();
			// about
			xml.@ns_rdf::about = '#' + encodeURI( this._owner._name + '-' + this._name );
			// define
			var x:XML = <isDefinedBy />;
			x.setNamespace( ns_rdfs );
			x.@ns_rdf::resource = '#' + encodeURI( this._owner._name.toString() );
			xml.appendChild( x );
			return xml;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected_info override function parseXML(xml:XML):void {
			super.parseXML( xml );
			this._name = getName( xml );
		}

	}
	
}