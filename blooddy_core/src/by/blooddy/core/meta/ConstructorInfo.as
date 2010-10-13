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
	 * @created					06.03.2010 13:55:02
	 */
	public final class ConstructorInfo extends AbstractInfo implements IFunctionInfo {
		
		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------
		
		use namespace $protected_info;
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _EMPTY_PARAMETERS:Vector.<ParameterInfo> = new Vector.<ParameterInfo>( 0, true );
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function ConstructorInfo() {
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _parameters:Vector.<ParameterInfo>;
		
		/**
		 * @private
		 */
		private var _parameters_required:Vector.<ParameterInfo>;
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function getParameters(required:Boolean=false):Vector.<ParameterInfo> {
			if ( required ) {
				return this._parameters_required.slice();
			} else {
				return this._parameters.slice();
			}
		}
		
		public override function toXML(local:Boolean=false):XML {
			var xml:XML = <constructor />;
			var i:uint, l:uint = this._parameters.length;
			for ( i=0; i<l; ++i ) {
				xml.appendChild( this._parameters[ i ].toXML( local ) );
			}
			return xml;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		$protected_info override function parseXML(xml:XML):void {
			var list:XMLList = xml.parameter;
			if ( list.length() <= 0 ) {
				this._parameters = _EMPTY_PARAMETERS;
				this._parameters_required = _EMPTY_PARAMETERS;
			} else {
				this._parameters = new Vector.<ParameterInfo>();
				this._parameters_required = new Vector.<ParameterInfo>();
				var p:ParameterInfo;
				for each ( xml in list ) {
					p = new ParameterInfo();
					p.parseXML( xml );
					this._parameters.push( p );
					if ( !p.optional ) {
						this._parameters_required.push( p );
					}
				}
			}
		}
		
	}
	
}