////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.meta {

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="property", name="_parent" )]
	[Exclude( kind="property", name="_name" )]
	[Exclude( kind="property", name="_metadata" )]
	[Exclude( kind="property", name="_metadata_local" )]

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

		use namespace $protected_info;
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _DESCRIPTION:QName = new QName( ns_rdf, 'Description' );

		/**
		 * @private
		 */
		private static const _EMPTY_METADATA:XMLList = new XMLList();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		protected static function parseName(x:XML):QName {
			return new QName( x.@uri.toString(), x.@name.toString() );
		}

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
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		$protected_info var _parent:DefinitionInfo;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$protected_info var _name:QName;

		public function get name():QName {
			return this._name;
		}

		/**
		 * @private
		 */
		$protected_info var _metadata:XMLList;

		/**
		 * @private
		 */
		$protected_info var _metadata_local:XMLList;
		
		public function getMetadata(all:Boolean=true):XMLList {
			if ( all ) {
				return this._metadata.copy();
			} else {
				return this._metadata_local.copy();
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function toXML():XML {
			var xml:XML = super.toXML();
			xml.setName( _DESCRIPTION );
			var x:XML;
			// title
			x = <title />;
			x.setNamespace( ns_dc );
			x.appendChild( this._name.toString() );
			xml.appendChild( x );
			// metadata
			if ( this._metadata_local.length() > 0 ) {
				x = <metadata />;
				x.setNamespace( ns_as3 );
				x.@ns_rdf::parseType = 'Literal';
				x.setChildren( this._metadata_local );
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
			var n:String;
			var meta:XMLList = xml.metadata.(
				n = @name,
				n != '__go_to_definition_help'      &&
				n != '__go_to_ctor_definition_help'
			); // исключаев дебаг мету
			if ( this._parent ) {
				
				if ( meta.length() <= 0 ) {
					
					this._metadata_local =	_EMPTY_METADATA;
					this._metadata =		this._parent._metadata;
					
				} else {

					this._metadata_local =	meta.copy();
					if ( this._parent._metadata.length() <= 0 ) {
						this._metadata = this._metadata_local;
					} else {
						this._metadata = meta.copy() + this._parent._metadata;
					}
					
				}

			} else {

				this._metadata_local =
				this._metadata = ( meta.length() <= 0 ? _EMPTY_METADATA : meta.copy() );

			}
		}

	}
	
}