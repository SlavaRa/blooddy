////////////////////////////////////////////////////////////////////////////////
//
//  © 2004—2008 TimeZero LLC.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.external {

	import by.blooddy.core.events.CommandEvent;
	import by.blooddy.core.events.DynamicEvent;
	import by.blooddy.core.events.StackErrorEvent;
	import by.blooddy.core.logging.ConnectionLogger;
	import by.blooddy.core.net.IConnection;
	import by.blooddy.core.utils.Command;
	import by.blooddy.core.utils.copyObject;
	import by.blooddy.core.utils.deferredCall;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.utils.getQualifiedClassName;
	import by.blooddy.core.net.NetCommand;

	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event(name="connect", type="flash.events.Event")]

	[Event(name="error", type="by.blooddy.core.events.StackErrorEvent")]

	[Event(name="ioError", type="flash.events.IOErrorEvent")]

	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class ExternalConnection extends EventDispatcher implements IConnection {

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
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function getName(value:Object):String {
			return getQualifiedClassName( value ).replace( '::', '.' );
		}

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
			if ( _init ) throw new ArgumentError();
			if ( !ExternalInterface.available ) throw new SecurityError();
			_init = true;
			ExternalInterface.addCallback( _PROXY_METHOD, this.$call );
			this._client = this;
			this._clientName = getName( this );
			deferredCall( this.init, null, enterFrameBroadcaster, Event.ENTER_FRAME );
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

		//----------------------------------
		//  logger
		//----------------------------------

		/**
		 * @private
		 */
		private const _logger:ConnectionLogger = new ConnectionLogger( 20, 1*60*1E3 );

		/**
		 * @inheritDoc
		 */
		public function get logger():ConnectionLogger {
			return this._logger; // FIXME: add
		}

		//----------------------------------
		//  logging
		//----------------------------------

		/**
		 * @private
		 */
		private var _logging:Boolean = false;

		/**
		 * @inheritDoc
		 */
		public function get logging():Boolean {
			return this._logging;
		}

		/**
		 * @private
		 */
		public function set logging(value:Boolean):void {
			if ( this._logging == value ) return;
			this._logging = value;
		}

		//----------------------------------
		//  client
		//----------------------------------

		/**
		 * @private
		 */
		private var _client:Object;

		/**
		 * @private
		 */
		private var _clientName:String;

		/**
		 * @inheritDoc
		 */
		public function get client():Object {
			return this._client || this;
		}

		/**
		 * @private
		 */
		public function set client(value:Object):void {
			if ( this._client === value ) return;
			this._client = value || this;
			this._clientName = getName( this._client );
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
		public function call(commandName:String, ...arguments):* {
			if ( !this._connected ) throw new IllegalOperationError();
			if ( this._logging ) {
				var command:NetCommand = new NetCommand( commandName, NetCommand.OUTPUT );
				command.push.apply( arguments );
				if ( !command.system ) {
					this._logger.addCommand( command );
				}
			}
			arguments.unshift( _PROXY_METHOD, ExternalInterface.objectID, commandName );
			ExternalInterface.call.apply( ExternalInterface, arguments );
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
		private function $call(id:String, commandName:String, ...arguments):* {
			if ( id != ExternalInterface.objectID ) {
				super.dispatchEvent( new SecurityErrorEvent( SecurityErrorEvent.SECURITY_ERROR, false, false, 'левое обращение' ) );
				return;
			}

			try { // отлавливаем ошибки выполнения

				var command:Command;

				if ( this._logging ) {
					command = new NetCommand( commandName, NetCommand.INPUT );
					command.push.apply( arguments );
					if ( !command.system ) {
						this._logger.addCommand( command as NetCommand );
					}
				}

				switch ( commandName ) {

					case 'dispatchEvent':	return	this.$dispatchEvent.apply( this, arguments );

					case 'getProperty':		return	this.$getProperty.apply( this, arguments );

					case 'setProperty':				this.$setProperty.apply( this, arguments );		break;

					default:	
						try {

							// пытаемся выполнить что-нить
							return this.client[ commandName ].apply( this.client, arguments );

						} catch ( e:ReferenceError ) {

							if ( // проверим нету хендлера на нашу комманду
								e.errorID != 1069 ||
								e.message.indexOf( this._clientName ) < 0 ||
								!super.hasEventListener( 'command_' + commandName )
							) throw e;

						} catch ( e:Error ) {

							throw e;

						} finally {

							if ( super.hasEventListener( 'command_' + commandName ) ) {
								if ( !command ) {
									command = new Command( commandName );
									command.push.apply( command, arguments );
								}
								super.dispatchEvent( new CommandEvent( 'command_' + commandName, false, false, command ) );
							}

						}
						break;
				}

			} catch ( e:Error ) {
				// нету. диспатчим ошибку
				trace( 'Error:', this._clientName + ':: ' + commandName + '(' + arguments + '):', e );
				super.dispatchEvent( new StackErrorEvent( StackErrorEvent.ERROR, false, false, e.toString(), e.getStackTrace() ) );

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