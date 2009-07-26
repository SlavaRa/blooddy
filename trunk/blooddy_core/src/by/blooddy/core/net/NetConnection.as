////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.net.NetConnection;

	import flash.events.EventDispatcher;

	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;

	import by.blooddy.core.logging.ConnectionLogger;

	//--------------------------------------
	//  Implements events: IConnection
	//--------------------------------------

	/**
	 * @inheritDoc
	 */
	[Event(name="connect", type="flash.events.Event")]

	/**
	 * @inheritDoc
	 */
	[Event(name="close", type="flash.events.Event")]

	/**
	 * @inheritDoc
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")]		

	/**
	 * @inheritDoc
	 */
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]	

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					netconnection, connection, net
	 * 
	 * @see						by.blooddy.core.net.NetConnection
	 */
	public class NetConnection extends EventDispatcher implements INetConnection {

		//--------------------------------------------------------------------------
		//
		//  Class properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  defaultObjectEncoding
		//----------------------------------

		/**
		 * @copy					flash.net.NetConnection#defaultObjectEncoding
		 */
		public static function get defaultObjectEncoding():uint {
			return flash.net.NetConnection.defaultObjectEncoding;
		}

		/**
		 * @private
		 */
		public static function set defaultObjectEncoding(value:uint):void {
			flash.net.NetConnection.defaultObjectEncoding = value;
		}
   
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy					flash.net.NetConnection#NetConnection
		 */
		public function NetConnection() {
			super();
			this._CONNECTION.client = this;
			this._CONNECTION.addEventListener(NetStatusEvent.NET_STATUS,			this.handler_netStatus);
			this._CONNECTION.addEventListener(AsyncErrorEvent.ASYNC_ERROR,			this.handler_asyncError);
			this._CONNECTION.addEventListener(IOErrorEvent.IO_ERROR,				this.dispatchEvent);
			this._CONNECTION.addEventListener(SecurityErrorEvent.SECURITY_ERROR,	this.dispatchEvent);
		}

		//--------------------------------------------------------------------------
		//
		//  Constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Сцылка на настоящие соединение.
		 */
		private const _CONNECTION:flash.net.NetConnection = new flash.net.NetConnection();

		//--------------------------------------------------------------------------
		//
		//  Implements properties: IConnection
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  client
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get client():Object {
			return this._CONNECTION.client || this;
		}

		/**
		 * @private
		 */
		public function set client(value:Object):void {
			this._CONNECTION.client = value;
		}

		//----------------------------------
		//  connected
		//----------------------------------

	    [Bindable("connect")]
		/**
		 * @inheritDoc
		 */
		public function get connected():Boolean {
			return this._CONNECTION.connected;
		}

		//----------------------------------
		//  protocol ( geter implements by IConnection )
		//----------------------------------

		/**
		 * @private
		 */
		private var _protocol:String = Protocols.RTMP;

		/**
		 * @inheritDoc
		 */
		public function get protocol():String {
			return this._protocol;
		}

		//----------------------------------
		//  connectionType
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get connectionType():String {
			return this._CONNECTION.proxyType;
		}

		/**
		 * @private
		 */
		public function set connectionType(value:String):void {
			if (this.connected) new ArgumentError(); /** TODO: описать ошибку. низя менять протокол, когда законектился */
			switch (value) {
				case Protocols.RTMP:
				case Protocols.RTMPS:
				case Protocols.AFM:
				case Protocols.AFMS:
				case Protocols.HTTP:
				case Protocols.HTTPS:
					break;
				default:
					throw new ArgumentError(); /** TODO: такой протокол не поддерживается данным соединением */
			}
			this._CONNECTION.proxyType = value;
		}

		//----------------------------------
		//  host
		//----------------------------------

		/**
		 * @private
		 */
		private var _host:String;

	    [Bindable("connect")]
		/**
		 * @inheritDoc
		 */
		public function get host():String {
			if (!this.connected) throw new ArgumentError(); /** TODO: описать ошибку */
			return this._host;
			
		}

		//----------------------------------
		//  port
		//----------------------------------

		/**
		 * @private
		 */
		private var _port:int;

	    [Bindable("connect")]
		/**
		 * @inheritDoc
		 */
		public function get port():int {
			if (!this.connected) throw new ArgumentError(); /** TODO: описать ошибку */
			return this._port;
			
		}

		//----------------------------------
		//  logger
		//----------------------------------

		/**
		 * @private
		 */
		private const _logger:ConnectionLogger = new ConnectionLogger();

		/**
		 * @inheritDoc
		 */
		public function get logger():ConnectionLogger {
			return this._logger;
			
		}

		//----------------------------------
		//  logging
		//----------------------------------

		/**
		 * @private
		 */
		private var _logging:Boolean = true;

		[Inspectable( type="Boolean", defaultValue="true" )]
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
			if (this._logging == value) return;
			this._logging = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  connectedProxyType
		//----------------------------------

		/**
		 * @copy					flash.net.NetConnection#connectedProxyType
		 */
		public function get connectedProxyType():String {
			return this._CONNECTION.connectedProxyType;
		}

		//----------------------------------
		//  objectEncoding
		//----------------------------------

		/**
		 * @copy					flash.net.NetConnection#objectEncoding
		 */
		public function get objectEncoding():uint {
			return this._CONNECTION.objectEncoding;
		}

		/**
		 * @private
		 */
		public function set objectEncoding(value:uint):void {
			this._CONNECTION.objectEncoding = value;
		}

		//----------------------------------
		//  usingTLS
		//----------------------------------

	    [Bindable("connect")]
		/**
		 * @copy					flash.net.NetConnection#usingTLS
		 */
		public function get usingTLS():Boolean {
			return this._CONNECTION.usingTLS;
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
			this._CONNECTION.connect( this._protocol + ":" + ( host ? "//"+host : "" ) + ( port ? ":"+port : "" ) + "/" );
			this._host = host;
			this._port = port;
		}

		/**
		 * @inheritDoc
		 */
		public function close():void {
			this._CONNECTION.close();
		}

		/**
		 * @inheritDoc
		 */
		public function call(command:String, ...arguments):void {
			arguments.unshift(command, null);
			this._CONNECTION.call.apply(this._CONNECTION, arguments);
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy					flash.net.NetConnection#addHeader()
		 */
		public function addHeader(operation:String, mustUnderstand:Boolean=false, param:Object=null):void {
			this._CONNECTION.addHeader(operation, mustUnderstand, param);
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Обрабатываем события connect, close, ioError.
		 */
		private function handler_netStatus(event:NetStatusEvent):void {
			var info:Object = event.info;
			if (info.code.indexOf("NetConnection.Call")==0) {
				if (info.level == "error") {
					this.dispatchEvent( new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "") ); /** TODO: описать ошибку */
				}
			} else if (info.code.indexOf("NetConnection.Connect")==0) { // обработка соединений
				if (info.level == "status") { // всё ок
					if (info.code.lastIndexOf("Success")==0) { // закоектились
						this.dispatchEvent( new Event(Event.CONNECT) );
					} else if (info.code.lastIndexOf("Closed")==0) { // закрылись
						this.dispatchEvent( new Event(Event.CLOSE) );
					}
				} else if (info.level == "error") {
					this.dispatchEvent( new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "") ); /** TODO: описать ошибку */
				}
			}
		}

		/**
		 * @private
		 */
		private function handler_asyncError(event:AsyncErrorEvent):void {
			/** TODO: чё-то надо понаписать */
		}

/*
		private function handler_asyncError(event:AsyncErrorEvent):void {
			trace(event);
		}

		private function handler_ioError(event:IOErrorEvent):void {
			trace(event);
		}

		private function handler_securityError(event:SecurityErrorEvent):void {
			trace(event);
		}
*/
	}
}