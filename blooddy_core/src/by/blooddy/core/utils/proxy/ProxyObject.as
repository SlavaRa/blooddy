////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.proxy {

	import flash.utils.ByteArray;
	import flash.utils.flash_proxy;

	use namespace flash_proxy;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					proxyobject, proxy, object
	 */
	public dynamic class ProxyObject extends Proxy {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function ProxyObject(target:Object, parent:ProxyObject=null, name:*=null) {
			super();
			this._target = target;
			this._parent = parent;
			this._name = name;

			// составим ключи
			for ( var i:Object in this._target ) {
				this._keys.push( i );
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
		private var _parent:ProxyObject;

		/**
		 * @private
		 */
		private var _lock:Boolean = false;

		/**
		 * @private
		 */
		private var _target:Object;

		/**
		 * @private
		 */
		private var _name:*;

		/**
		 * @private
		 */
		private const _keys:Array = new Array();

		/**
		 * @private
		 */
		private const _hash:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function valueOf():Object {
			return this._target;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden flash_proxy methods: Proxy
		//
		//--------------------------------------------------------------------------

		flash_proxy override function getProperty(name:*):* {
			if ( !name || super.hasProperty( name ) ) {
				return super.getProperty( name );
			} else if ( name in this._hash ) return this._hash[ name ]; // FIXED: развлетление хэшей!
			else if ( name in this._target ) {
				var value:* = this._target[name];
				if (
					value is Number ||
					value is String ||
					value is Boolean ||
					value is Array ||
					value is Date ||
					value is ByteArray
				) return value;
				else if ( value is Object ) {
					this._hash[ name ] = new ProxyObject( value, this, name );
					return this._hash[ name ];
				} else {
					return super.getProperty( name );
				}
			}
			return null;
		}

		flash_proxy override function hasProperty(name:*):Boolean {
			return ( name in this._target || name in this._hash || super.hasProperty(name) );
		}

		flash_proxy override function deleteProperty(name:*):Boolean {
			delete this._hash[ name ];
			var result:Boolean = delete this._target[ name ]; // TODO: сперва рекурсивно поубивать детей
			this._keys.splice( this._keys.indexOf(name), 1 );
			if ( !this._lock ) this.bubbleUpdate( name );
			return result;
		}

		flash_proxy override function nextName(index:int):String {
			return this._keys[ index - 1 ];
		}

		flash_proxy override function nextNameIndex(index:int):int {
			return ( index < this._keys.length ? index+1 : 0 );
		}

		flash_proxy override function nextValue(index:int):* {
			return this[ this._keys[ index -1 ] ];
		}

		flash_proxy override function setProperty(name:*, value:*):void {
			if ( this._target[ name ] === value ) return;
			if ( this.hasProperty( name ) ) {
				this._lock = true;
				this.deleteProperty( name );
				this._lock = false;
			}
			if ( value != null ) {
				this._target[ name ] = value;
				if (
					value is Number ||
					value is String ||
					value is Boolean ||
					value is Array ||
					value is Date ||
					value is ByteArray
				) {
					//
				} else if ( value is Object ){
					this._hash[ name ] = new ProxyObject( value, this, name );
				} else {
					throw new ArgumentError();
				}
				this._keys.push( name ); // добавили новый ключ
			}
			if ( !this._lock ) this.bubbleUpdate( name );
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function bubbleUpdate(...propertyPath):Boolean {
			if ( this._parent ) {
				propertyPath.unshift( this._name );
				return this._parent.bubbleUpdate.apply( this._parent, propertyPath );
			}
			return false;
		}

		protected function captureUpdate(...propertyPath):Boolean {
			var name:* = propertyPath[0];
			if ( this.hasProperty( name ) ) {
				if ( propertyPath.length > 1 ) {
					var value:* = this.getProperty( name );
					if ( value is ProxyObject ) {
						propertyPath.shift();
						( value as ProxyObject ).captureUpdate.apply( value, propertyPath );
					} else {
						throw new ArgumentError();
					}
				} else { // последний элемент
					this.setProperty( name, this._target[ name ] );
				}
			}
			return false;
		}

	}

}