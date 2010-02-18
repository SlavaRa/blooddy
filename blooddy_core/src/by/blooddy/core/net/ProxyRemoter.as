////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.utils.proxy.Proxy;
	
	import flash.utils.flash_proxy;

	use namespace flash_proxy;

	/**
	 * класс, нужен для того, что бы при вызове у него неопределённымх методов,
	 * он перенаправлял это всё на remoter.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					08.09.2009 20:12:04
	 */
	public dynamic class ProxyRemoter extends Proxy {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ProxyRemoter(remoter:IRemoter!) {
			super();
			this._remoter = remoter;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _remoter:IRemoter;

		public function get remoter():IRemoter {
			return this._remoter;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _name:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Overriden flash_proxy methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		flash_proxy override function hasProperty(name:*) : Boolean {
			return name && ( name is QName || name is String );
		}

		/**
		 * @private
		 */
		flash_proxy override function getProperty(name:*):* {
			if ( !name || super.flash_proxy::hasProperty( name ) ) {
				return super.flash_proxy::getProperty( name );
			} else {
				var n:String = name.toString();
				var result:*;
				if ( result == null ) {
					var app:ProxyRemoter = this;
					this._name[ n ] = result = function(...rest):* {
						return app.call( n, rest );
					}
				}
				return result;
			}
		}

		/**
		 * @private
		 */
		flash_proxy override function callProperty(name:*, ...rest):* {
			if ( !name || super.flash_proxy::hasProperty( name ) ) {
				rest.unshift( name );
				return super.flash_proxy::callProperty.apply( this, rest );
			} else {
				if ( !name ) throw new ReferenceError();
				return this.call( name.toString(), rest );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function call(methodName:String, args:Array):* {
			if ( !( this._remoter is IAbstractConnection ) || ( this._remoter as IAbstractConnection ).connected ) {
				try {
					args.unshift( methodName );
					return this._remoter.call.apply( this._remoter, args );
				} catch ( e:Error ) {
				}
			}
		}

	}

}