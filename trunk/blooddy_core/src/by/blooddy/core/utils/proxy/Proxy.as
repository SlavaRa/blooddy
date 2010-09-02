////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.proxy {

	import by.blooddy.core.utils.ClassUtils;
	
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	use namespace flash_proxy;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					proxy, object
	 */
	public dynamic class Proxy extends flash.utils.Proxy {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _HASH:Dictionary = new Dictionary( true );

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function getPrototypeByProperty(c:Class, name:String):Object {
			if ( !c || !c.prototype ) return null;
			var hash:Object = _HASH[ c ];
			if ( !hash ) _HASH[ c ] = hash = new Object();
			if ( name in hash ) {
				return hash[ name ];
			} else {
				if ( name in c.prototype ) return c.prototype;
				return ( hash[ name ] = getPrototypeByProperty( ClassUtils.getSuperclass( c ), name ) ); // save
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function Proxy() {
			super();
			this._constructor = ClassUtils.getClass( this );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _constructor:Class;

		//--------------------------------------------------------------------------
		//
		//  Overriden flash_proxy methods: flash.utils.Proxy
		//
		//--------------------------------------------------------------------------

		flash_proxy override function hasProperty(name:*):Boolean {
			if ( name && ( name is QName && !( name as QName ).uri ) || name is String ) {
				switch ( name.toString() ) {
					case 'constructor':
					case 'toString':
					case 'hasOwnProperty':
					case 'valueOf':
					case 'toLocaleString':
					case 'propertyIsEnumerable':
					case 'setPropertyIsEnumerable':
					case 'isPrototypeOf':
						return true;
				}
				return Boolean( getPrototypeByProperty( this._constructor, name ) );
			}
			return false;
		}
		
		flash_proxy override function getProperty(name:*):* {
			if ( name && ( name is QName && !( name as QName ).uri ) || name is String ) {
				if ( name == 'constructor' ) return this._constructor;
				var prototype:Object = getPrototypeByProperty( this._constructor, name );
				if ( prototype ) return prototype[ name ];
			}
			return super.flash_proxy::getProperty( name );
		}

		flash_proxy override function callProperty(name:*, ...rest):* {
			if ( name && ( name is QName && !( name as QName ).uri ) || name is String ) {
				var prototype:Object = getPrototypeByProperty( this._constructor, name );
				if ( prototype ) {
					return prototype[ name ].apply( this, rest );
				}
			}
			rest.unshift( name );
			return super.flash_proxy::callProperty.apply( this, rest );
		}

		//--------------------------------------------------------------------------
		//
		//  Prototype methods
		//
		//--------------------------------------------------------------------------

		prototype.toLocaleString = function():String {
			return Object.prototype.toLocaleString.call( this );
		}

		prototype.toString = function():String {
			return this.toLocaleString();
		}

		prototype.valueOf = function():Object {
			return this;
		}

		_dontEnumPrototype( prototype );
//		prototype.setPropertyIsEnumerable( 'toLocaleString', false );
//		prototype.setPropertyIsEnumerable( 'toString', false );
//		prototype.setPropertyIsEnumerable( 'valueOf', false );

	}

}