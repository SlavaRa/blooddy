////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {
	
	import by.blooddy.core.utils.proxy.Proxy;
	
	import flash.utils.flash_proxy;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	
	use namespace flash_proxy;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					17.05.2010 15:07:47
	 */
	public dynamic class DisplayObjectContainerProxy extends Proxy {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function DisplayObjectContainerProxy(container:DisplayObjectContainer) {
			super();
			this._container = container;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _container:DisplayObjectContainer;

		//--------------------------------------------------------------------------
		//
		//  flash_proxy methods
		//
		//--------------------------------------------------------------------------

		flash_proxy override function hasProperty(name:*):Boolean {
			if ( super.isAttribute( name ) ) {
				return name in this._container;
			} else {
				if ( name is QName ) name = name.toString();
				else if ( ( !name is String ) ) throw new ArgumentError();
				return Boolean( this._container.getChildByName( name ) );
			}
		}

		flash_proxy override function getProperty(name:*):* {
			if ( super.isAttribute( name ) ) {
				return this._container[ name ];
			} else {
				if ( name is QName ) name = name.toString();
				else if ( ( !name is String ) ) throw new ArgumentError();
				return this._container.getChildByName( name );
			}
		}

		flash_proxy override function getDescendants(name:*):* {
			if ( !super.isAttribute( name ) ) {
			}
			return super.getDescendants( name );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function getChild(parent:DisplayObjectContainer):DisplayObject {
			return null;
		}

	}
	
}