////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.events.CommandEvent;
	import by.blooddy.core.utils.Command;
	import by.blooddy.core.utils.ProxyEventDispatcher;
	
	import flash.events.IEventDispatcher;
	import flash.utils.flash_proxy;

	use namespace flash_proxy;

	[Event(name="command", type="by.blooddy.core.events.CommandEvent")]

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
		private var _qname:Object = new Object();

		/**
		 * @private
		 */
		private var _name:Object = new Object();

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
				var result:*;
				if ( name is QName )	result = this._qname[ ( name as QName ).toString() ];
				else					result = this._name[ name ];
				if ( result == null ) {
					var app:AbstractClient = this;
					result = function(...rest):* {
						return app.dispatchCommand( name, rest );
					}
					if ( name is QName )	this._qname[ name ] =	result;
					else					this._hash[ name ] =	result;
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
			var command:Command = new Command( name.toString() );
			command.push.apply( command, args );
			return super.dispatchEvent( new CommandEvent( CommandEvent.COMMAND, false, false, command ) );
		}

	}

}