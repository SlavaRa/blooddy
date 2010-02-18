////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.events.net.SerializeErrorEvent;
	import by.blooddy.core.logging.InfoLog;
	import by.blooddy.core.utils.ByteArrayUtils;
	
	import flash.errors.IOError;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.events.ErrorEvent;

	//--------------------------------------
	//  Implements events: IConnection
	//--------------------------------------

	[Event( name="open", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="connect", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="close", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]		

	/**
	 * @inheritDoc
	 */
	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]	

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * ошибка сериализации протокола
	 */
	[Event( name="serializeError", type="by.blooddy.core.events.net.SerializeErrorEvent" )]	

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					socketconnection, connection, proxysocket, socket, proxy
	 */
	public class SocketConnection extends AbstractRemoter implements INetConnection {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructior
		 */
		public function SocketConnection() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Сцылка на конкретное сокетное соединение.
		 */
		private var _socket:ISocket;

		/**
		 * @private
		 */
		private const _inputBuffer:ByteArray = new ByteArray();

		/**
		 * @private
		 */
		private var _inputPosition:uint = 0;

		//--------------------------------------------------------------------------
		//
		//  Implements properties: INetConnection
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  connected
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get connected():Boolean {
			return ( this._socket ? this._socket.connected : false );
		}

		//----------------------------------
		//  protocol
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get protocol():String {
			if ( this._socket ) {
				return this._socket.protocol;
			} else {
				return null;
			}
		}

		//----------------------------------
		//  connectionType
		//----------------------------------

		/**
		 * @private
		 */
		private var _connectionType:String = '';

		/**
		 * @inheritDoc
		 */
		public function get connectionType():String {
			return this._connectionType;
		}

		/**
		 * @private
		 */
		public function set connectionType(value:String):void {
			if ( this.connected ) throw new ArgumentError(); /** TODO: описать ошибку */
/*			switch (value) {
				
			}
*/			this._connectionType = value;
		}

		//----------------------------------
		//  host
		//----------------------------------

		/**
		 * @private
		 */
		private var _host:String;

		/**
		 * @inheritDoc
		 */
		public function get host():String {
			return this._host;
		}

		//----------------------------------
		//  port
		//----------------------------------

		/**
		 * @private
		 */
		private var _port:int;

		/**
		 * @inheritDoc
		 */
		public function get port():int {
			return this._port;
		}

		//----------------------------------
		//  connectionTimeout
		//----------------------------------

		/**
		 * @private
		 */
		private var _connectionTimeout:Number = 10E3;

		/**
		 * @inheritDoc
		 */
		public function get timeout():uint {
			return this._connectionTimeout;
		}

		/**
		 * @private
		 */
		public function set timeout(value:uint):void {
			if ( this._connectionTimeout == value ) return;
			this._connectionTimeout = value;
			if ( this._socket ) this._socket.timeout = this._connectionTimeout;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  filter
		//----------------------------------

		/**
		 * @private
		 */
		private var _filter:ISocketFilter;

		/**
		 * Через эту фигню идёт обработка протокола.
		 */
		public function get filter():ISocketFilter {
			return this._filter;
		}

		/**
		 * @private
		 */
		public function set filter(value:ISocketFilter):void {
			this._filter = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IConnection
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function connect(host:String, port:int):void {
			if ( this.connected ) throw new IOError();//this.close();
			switch ( this._connectionType ) {
				case Protocols.SOCKET:
					this._socket = new Socket();
					//Security.loadPolicyFile( 'xmlsocket://' + host + ':' + port );
					break;
				case Protocols.HTTP:
					this._socket = new ProxySocket();
					break;
			}
			if ( !this._socket ) throw new ArgumentError(); /** TODO: описать обшибку */
			this._socket.timeout = this._connectionTimeout;
			this._socket.addEventListener( Event.OPEN,							super.dispatchEvent );
			this._socket.addEventListener( Event.CONNECT,						this.handler_connect );
			this._socket.addEventListener( ProgressEvent.SOCKET_DATA,			this.handler_socketData );
			this._socket.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
			this._socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
			this._socket.addEventListener( Event.CLOSE,							this.handler_close );
			this._socket.connect( host, port );
			this._host = this._socket.host;
			this._port = this._socket.port;
			if ( super.logging ) {
				super.logger.addLog( new InfoLog( 'Open: ' + this._host + ':' + this._port, InfoLog.INFO ) );
			}
		}

		/**
		 * @inheritDoc
		 */
		public function close():void {
			if ( this._socket ) {
				this._socket.close();
			}
		}

		/**
		 * @inheritDoc
		 */
		public override function call(commandName:String, ...parameters):* {
			if ( !this._socket ) throw new IllegalOperationError();
			if ( !this._filter ) throw new IllegalOperationError();
			return super.$invokeCallOutputCommand(
				new NetCommand( commandName, NetCommand.OUTPUT, parameters )
			);
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

//			var bytes:ByteArray = new ByteArray();
//			this._filter.writeCommand( bytes, command as NetCommand );
//			this._socket.writeBytes( bytes );
//			trace( ByteArrayUtils.dump( bytes ) );

			this._filter.writeCommand( this._socket, command as NetCommand );
			this._socket.flush(); 
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_connect(event:Event):void {
			if ( super.logging ) {
				super.logger.addLog( new InfoLog( 'Connect: ' + this._host + ':' + this._port, InfoLog.INFO ) );
			}
			super.dispatchEvent( event )
		}

		/**
		 * @private
		 */
		private function handler_error(event:ErrorEvent):void {
			if ( super.logging ) {
				super.logger.addLog( new InfoLog( 'Error: ' + this._host + ':' + this._port, InfoLog.INFO ) );
			}
			this._host = null;
			this._port = 0;
			super.dispatchEvent( event );
		}

		/**
		 * @private
		 * Соединение закрылось.
		 */
		private function handler_close(event:Event):void {
			if ( super.logging ) {
				super.logger.addLog( new InfoLog( 'Close: ' + this._host + ':' + this._port, InfoLog.INFO ) );
			}
			this._host = null;
			this._port = 0;
			this._socket.removeEventListener( Event.OPEN,							super.dispatchEvent );
			this._socket.removeEventListener( Event.CONNECT,						super.dispatchEvent );
			this._socket.removeEventListener( ProgressEvent.SOCKET_DATA,			this.handler_socketData );
			this._socket.removeEventListener( IOErrorEvent.IO_ERROR,				super.dispatchEvent );
			this._socket.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	super.dispatchEvent );
			this._socket.removeEventListener( Event.CLOSE,							this.handler_close );
			this._socket = null;
			this._inputBuffer.length = 0;
			this._inputPosition = 0;
			super.dispatchEvent( event );
		}

		/**
		 * @private
		 * обрабатываем пришедшие данные и запускаем.
		 */
		private function handler_socketData(event:ProgressEvent):void {

			if ( !this._filter ) throw new IOError(); /** TODO: пипец. нету обработчика протокола. */

			if ( super.hasEventListener( ProgressEvent.PROGRESS ) ) {
				super.dispatchEvent(
					new ProgressEvent(
						ProgressEvent.PROGRESS, false, false,
						this._socket.bytesAvailable - this._inputBuffer.bytesAvailable, 0
					)
				);
			}


			//var pos:uint = this._inputBuffer.length;
			// запихиваем фсё в буфер
			this._socket.readBytes( this._inputBuffer, this._inputBuffer.length );
			//trace( ByteArrayUtils.dump( this._inputBuffer, pos  ) );

			var command:NetCommand;

			do { // считываем до тех пор, пока есть чего читать

				try { // серилизуем комманду

					command = this._filter.readCommand( this._inputBuffer, NetCommand.INPUT );

				} catch ( e:Error ) {

					command = null;

					var data:ByteArray = new ByteArray();
					this._inputBuffer.position = this._inputPosition;
					this._inputBuffer.readBytes( data );
					this._inputBuffer.length = 0;

					if ( super.logging ) {
						super.logger.addLog( new InfoLog( ( e.getStackTrace() || e.toString() ), InfoLog.FATAL ) );
						trace( e.getStackTrace() || e.toString() );
						trace( ByteArrayUtils.dump( data ) );
					}

					if ( super.dispatchEvent( new SerializeErrorEvent( SerializeErrorEvent.SERIALIZE_ERROR, false, true, e.toString(), e, data ) ) ) {
						this.close();
					}

				}

				if ( command ) {

					this._inputPosition = this._inputBuffer.position;

					// вызываем метод обработки
					super.$invokeCallInputCommand( command );

				}

			} while ( command && this._inputBuffer.bytesAvailable > 0 );

			if ( this._inputPosition == this._inputBuffer.length ) { // нечего накапливать буфер. чистим.
				this._inputPosition = 0;
				this._inputBuffer.length = 0;
			}

		}

	}
}