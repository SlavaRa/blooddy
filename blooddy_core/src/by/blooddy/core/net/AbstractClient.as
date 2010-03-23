////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.events.commands.CommandEvent;
	import by.blooddy.core.utils.proxy.ProxyEventDispatcher;
	
	import flash.events.IEventDispatcher;
	import flash.utils.flash_proxy;

	use namespace flash_proxy;

	[Event( name="command", type="by.blooddy.core.events.commands.CommandEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public dynamic class AbstractClient extends ProxyEventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function AbstractClient(target:IEventDispatcher=null) {
			super( target );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _hash:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  flash_proxy methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		flash_proxy override function getProperty(name:*):* {
			if ( super.flash_proxy::hasProperty( name ) ) {
				return super.flash_proxy::getProperty( name );
			} else {
				var n:String = name.toString();
				var result:* = this._hash[ name ];
				if ( result == null ) {
					var app:AbstractClient = this;
					this._hash[ name ] = result = function(...rest):* {
						return app.dispatchCommand( name, rest );
					};
				}
				return result;
			}
		}

		/**
		 * @private
		 */
		flash_proxy override function callProperty(name:*, ...rest):* {
			if ( super.flash_proxy::hasProperty( name ) ) {
				rest.unshift( name );
				return super.flash_proxy::callProperty.apply( this, rest );
			} else {
				return this.dispatchCommand( name, rest );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function dispatchCommand(name:*, args:Array=null):Boolean {
			return super.dispatchEvent( new CommandEvent( CommandEvent.COMMAND, false, false, new Command( name.toString(), args ) ) );
		}

	}

}