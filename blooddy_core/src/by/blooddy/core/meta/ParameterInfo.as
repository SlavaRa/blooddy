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
	 * @created					06.03.2010 13:08:12
	 */
	public class ParameterInfo extends AbstractInfo implements ITypedInfo {
		
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
		public function ParameterInfo() {
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
		private var _type:QName;

		public function get type():QName {
			return this._type;
		}

		/**
		 * @private
		 */
		private var _optional:Boolean;
		
		public function get optional():Boolean {
			return this._optional;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function toXML():XML {
			var xml:XML = super.toXML();
			xml.@ns_rdf::parseType = 'Resource';
			var x:XML;
			// type
			x = <type />;
			x.setNamespace( ns_as3 );
			x.@ns_rdf::resource = typeURI( this._type );
			xml.appendChild( x );
			// optional
			x = <optional>{this._optional}</optional>;
			x.setNamespace( ns_as3 );
			//x.@ns_rdf::datatype = 'http://www.w3.org/2001/XMLSchema#boolean';
			xml.appendChild( x );
			return xml;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		$protected_inf override function parseXML(xml:XML):void {
			this._type = parseType( xml.@type.toString() );
			this._optional = parseBoolean( xml.@optional.toString() );
		}
		
	}
	
}