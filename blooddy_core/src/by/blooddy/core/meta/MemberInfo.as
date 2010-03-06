////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.meta {

	import flash.errors.IllegalOperationError;

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

		use namespace $protected_inf;

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
		
		public function get type():QName {
			return this._type;
		}

		$protected_inf var _owner:TypeInfo;
		
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
			xml.@ns_rdf::about = typeURI( this._owner._name ) + '#' + this._name;
			return xml;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected_inf override function parseXML(xml:XML):void {
			super.parseXML( xml );
			this._name = new QName( xml.@uri.toString(), xml.@name.toString() );
		}

	}
	
}