////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.proxy {

	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import by.blooddy.core.utils.ClassUtils;

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
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		private static function getPrototypeByProperty(cl:Class, name:*):Object {
			if ( !cl || !cl.prototype ) return null;
			if ( name in cl.prototype ) return cl.prototype;
			return getPrototypeByProperty( ClassUtils.getSuperclass( cl ), name );
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function Proxy() {
			super();
			this._constructor = ClassUtils.getClass( this );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		private var _constructor:Class;

		//--------------------------------------------------------------------------
		//
		//  Overriden flash_proxy methods: flash.utils.Proxy
		//
		//--------------------------------------------------------------------------

		flash_proxy override function getProperty(name:*):* {
			if ( name == "constructor" ) return this._constructor;
			var prototype:Object = getPrototypeByProperty( this._constructor, name );
			if ( prototype ) return prototype[name];
			return super.flash_proxy::getProperty(name);
		}

		flash_proxy override function callProperty(name:*, ...rest):* {
			var prototype:Object = getPrototypeByProperty( this._constructor, name );
			if ( prototype ) {
				return prototype[name].apply( this, rest );
			} else {
				rest.unshift( name );
				return super.flash_proxy::callProperty.apply( this, rest );
			}
		}

		flash_proxy override function hasProperty(name:*):Boolean {
			return Boolean( getPrototypeByProperty(this._constructor, name) );
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

		prototype.setPropertyIsEnumerable("toLocaleString", false);
		prototype.setPropertyIsEnumerable("toString", false);
		prototype.setPropertyIsEnumerable("valueOf", false);

	}

}