////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.external {

	import by.blooddy.core.errors.getErrorMessage;
	import by.blooddy.core.events.DynamicEvent;
	import by.blooddy.core.logging.CommandLog;
	import by.blooddy.core.net.AbstractRemoter;
	import by.blooddy.core.net.IConnection;
	import by.blooddy.core.net.NetCommand;
	import by.blooddy.core.utils.Command;
	import by.blooddy.core.utils.copyObject;
	import by.blooddy.core.utils.nexframeCall;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;

	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event(name="connect", type="flash.events.Event")]

	[Event(name="error", type="com.timezero.platform.events.StackErrorEvent")]

	[Event(name="ioError", type="flash.events.IOErrorEvent")]

	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class ExternalConnection extends AbstractRemoter implements IConnection {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var _init:Boolean = false;

		/**
		 * @private
		 */
		private static var _PROXY_METHOD:String = '__flash__call';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructior.
		 */
		public function ExternalConnection() {
			super();
			if ( _init ) throw new ArgumentError( getErrorMessage( 2012, this, 'ExternalConnection' ), 2012 );
			if ( !ExternalInterface.available ) throw new SecurityError();
			_init = true;
			ExternalInterface.addCallback( _PROXY_METHOD, this.$call );
			nexframeCall( this.init );
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties: IConnection
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  connected
		//----------------------------------

		/**
		 * @private
		 */
		private var _connected:Boolean = false;

		/**
		 * @inheritDoc
		 */
		public function get connected():Boolean {
			return this._connected;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  initialized
		//----------------------------------

		public function get initialized():Boolean {
			return this._connected;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IConnection
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public override function call(commandName:String, ...parameters):* {
			if ( !this._connected ) throw new IllegalOperationError();
			if ( super.logging ) {
				var command:NetCommand = new NetCommand( commandName, NetCommand.OUTPUT, parameters );
				if ( !command.system ) {
					super.logger.addLog( new CommandLog( command ) );
				}
			}
			parameters.unshift( _PROXY_METHOD, ExternalInterface.objectID, commandName );
			return ExternalInterface.call.apply( ExternalInterface, parameters );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: EventDispatcher
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public override function dispatchEvent(event:Event):Boolean {
			var o:Object = copyObject( event.clone() ); // делаем клон, что бы разорвать связи
			delete o.type;
			delete o.bubbles;
			delete o.cancelable;
			delete o.eventPhase;
			delete o.target;
			delete o.currentTarget;
			return this.call( 'dispatchEvent', event.type, event.cancelable, o );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getProperty(name:String):* {
			return this.call( 'getProperty', name );
		}

		public function setProperty(name:String, value:*):void {
			this.call( 'setProperty', name, value );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function $callCommand(command:Command):* {
			switch ( command.name ) {
				case 'dispatchEvent':	return	this.$dispatchEvent.apply( this, command );		break;
				case 'getProperty':		return	this.$getProperty.apply( this, command );		break;
				case 'setProperty':				this.$setProperty.apply( this, command );		break;
				default:				return	super.$callCommand( command );					break;
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
		private function init():void {
			try {
				this._connected = true;
				this.call( 'dispatchEvent', Event.INIT );
				super.dispatchEvent( new Event( Event.CONNECT ) );
			} catch ( e:Error ) { // bug fixing: ExternalInterface.available == true, but method ExternalInterface.call throws SecurityError
				this._connected = false;
				super.dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, e.message ) );
			}
		}

		/**
		 * @private
		 */
		private function $call(id:String, commandName:String, ...parameters):* {
			if ( id != ExternalInterface.objectID ) {
				super.dispatchEvent( new SecurityErrorEvent( SecurityErrorEvent.SECURITY_ERROR, false, false, 'левое обращение' ) );
			} else {
				return super.$invokeCallCommand( new NetCommand( commandName, NetCommand.INPUT, parameters ) );
			}
		}

		/**
		 * @private
		 */
		private function $dispatchEvent(type:String, cancelable:Boolean=false, params:Object=null):Boolean {
			var event:DynamicEvent = new DynamicEvent( type, false, cancelable );
			copyObject( params, event );
			return super.dispatchEvent( event );
		}

		/**
		 * @private
		 */
		private function $getProperty(name:String):* {
			return this.client[ name ];
		}

		/**
		 * @private
		 */
		private function $setProperty(name:String, value:*):void {
			this.client[ name ] = value;
		}

	}

}