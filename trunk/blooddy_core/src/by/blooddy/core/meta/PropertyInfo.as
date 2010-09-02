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
	 * @created					06.03.2010 2:11:47
	 */
	public final class PropertyInfo extends MemberInfo {
		
		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------
		
		use namespace $protected_info;
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const ACCESS_READ:uint =			1;

		public static const ACCESS_WRITE:uint =			2;
		
		public static const ACCESS_READ_WRITE:uint =	ACCESS_READ | ACCESS_WRITE;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function PropertyInfo() {
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public function get parent():PropertyInfo {
			return this._parent as PropertyInfo;
		}

		/**
		 * @private
		 */
		private var _access:uint;

		public function get access():uint {
			return this._access;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function toXML():XML {
			var xml:XML = super.toXML();
			var x:XML;
			// type
			x = <type>property</type>;
			x.setNamespace( ns_dc );
			xml.appendChild( x );
			// type
			x = <type />;
			x.setNamespace( ns_as3 );
			x.@ns_rdf::resource = '#' + encodeURI( this._type.toString() );
			xml.appendChild( x );
			// access
			var access:String = '';
			if ( this._access & ACCESS_READ )	access += 'read';
			if ( this._access & ACCESS_WRITE )	access += 'write';
			if ( ( this._access & ACCESS_READ_WRITE ) != ACCESS_READ_WRITE ) access += 'only';
			if ( access ) {
				x = <access />;
				x.setNamespace( ns_as3 );
				//x.@ns_rdf::datatype = 'http://www.w3.org/2001/XMLSchema#string';
				x.appendChild( access );
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
			if ( this._parent ) { // нефига парсить лишний раз
				this._type = ( this._parent as PropertyInfo )._type;
			} else {
				this._type = parseType( xml.@type.toString() );
			}
			switch ( xml.name().toString() ) {
				case 'accessor':
					switch ( xml.@access.toString() ) {
						case 'readonly':	this._access = ACCESS_READ; break;
						case 'readwrite':	this._access = ACCESS_READ_WRITE; break;
						case 'writeonly':	this._access = ACCESS_WRITE; break;
					}
					break;
				case 'variable':
					this._access = ACCESS_READ_WRITE;
					break;
				case 'constant':
					this._access = ACCESS_READ;
					break;
			}
		}

	}
	
}