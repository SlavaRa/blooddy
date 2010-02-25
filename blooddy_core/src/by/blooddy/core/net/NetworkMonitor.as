////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					25.02.2010 9:40:35
	 */
	public final class NetworkMonitor {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const monitor:NetworkMonitor = new NetworkMonitor();

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function NetworkMonitor() {
			super();

			var LoaderConfig:Class = ApplicationDomain.currentDomain.getDefinition( 'mx.messaging.config::LoaderConfig' ) as Class;
			var parameters:Object = ( LoaderConfig ? LoaderConfig['parameters'] : null );

			if ( parameters && parameters['netmonRTMPPort'] != null ) {
				this._port = int( parameters['netmonRTMPPort'] );
			}

			this._socket = new Socket();
			this._socket.addEventListener( Event.CONNECT,						this.handler_connect );
			this._socket.addEventListener( Event.CLOSE,							this.handler_close );
			this._socket.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
			this._socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
			this._socket.addEventListener( ProgressEvent.SOCKET_DATA,			this.handler_socketData );
			this._socket.connect( this._host, this._port );

		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _socket:Socket = new Socket();

		/**
		 * @private
		 */
		private var _host:String = 'localhost';
		
		/**
		 * @private
		 */
		private var _port:int = 27813;
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_connect(event:Event):void {
			trace( event );
		}

		/**
		 * @private
		 */
		private function handler_close(event:Event):void {
			trace( event );
		}
		
		/**
		 * @private
		 */
		private function handler_error(event:ErrorEvent):void {
			trace( event );
		}
		
		/**
		 * @private
		 */
		private function handler_socketData(event:ProgressEvent):void {
			trace( event );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function isMonitoring():Boolean {
			return false;
		}

		public static function adjustURLRequest(urlRequest:URLRequest, rootURL:String, correlationID:String):void {
		}

		public static function monitorResult(resultMessage:Object, actualResult:Object):void {
		}

		public static function monitorEvent(event:Event, correlationID:String):void {
		}

		public static function monitorInvocation(id:String, invocationMessage:Object, messageAgent:Object):void {
		}
		
	}
	
}