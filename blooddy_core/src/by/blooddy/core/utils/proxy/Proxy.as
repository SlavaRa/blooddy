////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.proxy {

	import by.blooddy.core.meta.TypeInfo;
	import by.blooddy.core.utils.ClassUtils;
	
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
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function Proxy() {
			super();
			var c:Class;
			this._constructor = c = ClassUtils.getClass( this );
			if ( c && c.prototype ) {
				this._prototype = c.prototype;
			} else {
				c = ClassUtils.getSuperclass( this );
				if ( c && c.prototype ) {
					this._prototype = c.prototype;
				} else {
					this._prototype = prototype;
				}
			}
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

		/**
		 * @private
		 */
		private var _prototype:Object;
		
		//--------------------------------------------------------------------------
		//
		//  Overriden flash_proxy methods: flash.utils.Proxy
		//
		//--------------------------------------------------------------------------

		flash_proxy override function hasProperty(name:*):Boolean {
			return	name in this._prototype ||
					TypeInfo.getInfo( this ).hasMember( name ) || // из-за бага приходится проводить полную проверку
					super.hasProperty( name );
		}
		
		flash_proxy override function getProperty(name:*):* {
			if ( name in this._prototype ) {
				if ( name == 'constructor' ) return this._constructor;
				return this._prototype[ name ];
			}
			return super.getProperty( name );
		}

		flash_proxy override function callProperty(name:*, ...rest):* {
			if ( name in this._prototype ) {
				return this._prototype[ name ].apply( this, rest );
			}
			rest.unshift( name );
			return super.callProperty.apply( this, rest );
		}
		
	}

}