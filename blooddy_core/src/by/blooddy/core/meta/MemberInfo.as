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
			return super.toXML();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected_info override function parseXML(xml:XML):void {
			super.parseXML( xml );
			// нефига парсить лишний раз
			this._name = ( this._parent ? this._parent._name : parseName( xml ) );
		}

	}
	
}