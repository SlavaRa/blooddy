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
		private static const _LI:QName = new QName( ns_rdf, 'li' );
		
		/**
		 * @private
		 */
		private static const _CONSTRUCTOR:QName = new QName( ns_as3, 'constructor' );

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
		private const _parameters:Vector.<ParameterInfo> = new Vector.<ParameterInfo>();
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function getParameters():Vector.<ParameterInfo> {
			return this._parameters.slice();
		}
		
		public override function toXML():XML {
			var xml:XML = super.toXML();
			xml.setName( _CONSTRUCTOR );
			xml.@ns_rdf::parseType = 'Resource';
			var seq:XML = <Seq />;
			var x:XML;
			var l:uint = this._parameters.length;
			for ( var i:uint = 0; i<l; i++ ) {
				x = this._parameters[ 0 ].toXML();
				x.setName( _LI );
				seq.appendChild( x );
			}
			if ( seq.hasComplexContent() ) {
				seq.setNamespace( ns_rdf );
				x = <parameters />;
				x.setNamespace( ns_as3 );
				x.appendChild( seq );
				xml.appendChild( x );
			}
			return xml;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		$protected_info override function parseXML(xml:XML):void {
			super.parseXML( xml );
			var list:XMLList = xml.parameter;
			var p:ParameterInfo;
			for each ( xml in list ) {
				p = new ParameterInfo();
				p.parseXML( xml );
				this._parameters.push( p );
			}
		}
		
	}
	
}