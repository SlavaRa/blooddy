package by.blooddy.platform.utils {

	import flash.utils.flash_proxy;
	import flash.utils.Proxy;
	import flash.utils.getQualifiedClassName;

	use namespace flash_proxy;

	public dynamic class DynamicObject extends Proxy {

		public function DynamicObject() {
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
		private const object:Object = new Object();

		/**
		 * @private
		 */
		private var _keys:Array;

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: Proxy
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		flash_proxy final override function callProperty(name:*, ...rest):* {
			return this.object[name].apply(this.object, rest);
		}

		/**
		 * @private
		 */
		flash_proxy final override function deleteProperty(name:*):Boolean {
			if ( !( this.object[name] is Property ) ) {
				this._keys = null;
			}
			return delete this.object[name];
		}

		/*flash_proxy final override function getDescendants(name:*):* {
			return null;
		}*/

		/**
		 * @private
		 */
		flash_proxy final override function getProperty(name:*):* {
			if ( this.object[name] is Property ) {
				( this.object[name] as Property ).getter();
			} else {
				return this.object[name];
			}
		}

		/**
		 * @private
		 */
		flash_proxy final override function hasProperty(name:*):Boolean {
			return this.object.hasOwnProperty( name );
		}

		/*flash_proxy final override function isAttribute(name:*):Boolean {
			return false;
		}*/

		/**
		 * @private
		 */
		flash_proxy final override function nextName(index:int):String {
			return this.getKeys()[ index - 1 ];
		}

		/**
		 * @private
		 */
		flash_proxy final override function nextNameIndex(index:int):int {
			return ( index < this.getKeys().length ? index+1 : 0 );
		}

		/**
		 * @private
		 */
		flash_proxy final override function nextValue(index:int):* {
			return this.object[ this.getKeys()[ index -1 ] ];
		}

		/**
		 * @private
		 */
		flash_proxy final override function setProperty(name:*, value:*):void {
			if ( this.object[name] is Property ) {
				( this.object[name] as Property ).setter(value);
			} else {
				this._keys = null;
				this.object[name] = value;
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		flash_proxy final function addProperty(name:*, getter:Function=null, setter:Function=null):void {
			this.object[name] = new Property(getter, setter);
			this.object.setPropertyIsEnumerable( name, false );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function getKeys():Array {
			if (!this._keys) {
				this._keys = new Array();
				for ( var i:Object in this._values ) {
					this._keys.push( i );
				}
			}
			return this._keys;
		}

	}

}

internal final class Property {

	public function Property(getter:Function=null, setter:Function=null) {
		super();
		this.getter = getter;
		this.setter = setter;
	}

	public var getter:Function;

	public var setter:Function;

}