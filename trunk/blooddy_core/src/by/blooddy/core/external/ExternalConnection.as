////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.external {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.events.DynamicEvent;
	import by.blooddy.core.logging.InfoLog;
	import by.blooddy.core.net.AbstractRemoter;
	import by.blooddy.core.net.IConnection;
	import by.blooddy.core.net.NetCommand;
	import by.blooddy.core.utils.copyObject;
	import by.blooddy.core.utils.nexframeCall;
	import by.blooddy.core.utils.time.setTimeout;
	
	import flash.errors.IllegalOperationError;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;

	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event( name="connect", type="flash.events.Event" )]

	[Event( name="ioError", type="flash.events.IOErrorEvent" )]

	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]

	[Event( name="close", type="flash.events.Event" )]
	
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

		/**
		 * @private
		 */
		private static var _objectID:String = ExternalInterface.objectID;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructior.
		 */
		public function ExternalConnection(objectID:String=null) {
			super();
			if ( _init ) throw new ArgumentError();
			_init = true;
			if ( ExternalInterface.available ) {
				if ( _objectID ) {
					if ( objectID && _objectID != objectID ) {
						throw new ArgumentError();
					}
				} else {
					if ( !objectID ) throw new ArgumentError();
					_objectID = objectID;
				}
				ExternalInterface.addCallback( _PROXY_METHOD, this.$call );
			}
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
		//  Implements methods: IConnection
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public override function call(commandName:String, ...parameters):* {
			if ( !this._connected ) throw new IllegalOperationError( );
			return super.$invokeCallOutputCommand(
				new NetCommand( commandName, NetCommand.OUTPUT, parameters )
			);
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
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function $callOutputCommand(command:Command):* {
			var parameters:Array = command.slice();
			parameters.unshift( _PROXY_METHOD, _objectID, command.name );
			return ExternalInterface.call.apply( ExternalInterface, parameters );
		}

		/**
		 * @private
		 */
		protected override function $callInputCommand(command:Command):* {
			switch ( command.name ) {
				case 'dispatchEvent':	return	this.$dispatchEvent.apply( this, command );
				case 'dispose':					this.$dispose.apply( this, command );		break;
				default:				return	super.$callInputCommand( command );
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
				if ( true !== super.dispatchEvent( new Event( Event.CONNECT ) ) ) {
					throw new IllegalOperationError( 'недопустимый контэйнер для флэшки' );
				}
			} catch ( e:SecurityError ) { // bug fixing: ExternalInterface.available == true, but method ExternalInterface.call throws SecurityError
				this._connected = false;
				super.dispatchEvent( new SecurityErrorEvent( SecurityErrorEvent.SECURITY_ERROR, false, false, e.message ) );
			} catch ( e:Error ) {
				this._connected = false;
				super.dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, e.message ) );
			}
		}

		/**
		 * @private
		 */
		private function $call(id:String, commandName:String, ...parameters):* {
			if ( id != _objectID ) {
				super.dispatchEvent( new SecurityErrorEvent( SecurityErrorEvent.SECURITY_ERROR, false, false, 'левое обращение' ) );
			} else {
				return super.$invokeCallInputCommand( new NetCommand( commandName, NetCommand.INPUT, parameters ) );
			}
		}

		/**
		 * @private
		 */
		private function $dispatchEvent(type:String, cancelable:Boolean=false, params:Object=null):Boolean {
			var event:DynamicEvent = new DynamicEvent( type, false, cancelable );
			copyObject( params, event );
			if ( cancelable ) { // синхронный ответ
				return super.dispatchEvent( event );
			} else {
				setTimeout( this._dispatchEvent, 1, event );
				return true;
			}
		}

		/**
		 * @private
		 */
		private function _dispatchEvent(event:Event):Boolean {
			try { // отлавливаем ошибки выполнения
				return super.dispatchEvent( event );
			} catch ( e:Error ) {
				if ( super.logging ) {
					super.logger.addLog( new InfoLog( ( e.getStackTrace() || e.toString() ), InfoLog.ERROR ) );
					trace( e.getStackTrace() || e.toString() );
				}
				super.dispatchEvent( new AsyncErrorEvent( AsyncErrorEvent.ASYNC_ERROR, false, false, e.toString(), e ) );
			}
			return true;
		}

		/**
		 * @private
		 */
		private function $dispose():void {
			this._connected = false;
			super.dispatchEvent( new Event( Event.CLOSE ) );
		}
		
	}

}