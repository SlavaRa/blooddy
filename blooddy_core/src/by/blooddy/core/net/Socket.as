////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.events.Event;
	import flash.net.Socket;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;

	[Event( name="open", type="flash.events.Event" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					socket
	 * 
	 * @see						flash.net.Socket
	 */
	public class Socket extends flash.net.Socket implements ISocket {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function Socket(host:String=null, port:int=0.0) {
			super( host, port );
			super.addEventListener( Event.CLOSE, this.handler_close, false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ISocket
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  protocol
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get protocol():String {
			return Protocols.SOCKET;
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

		//--------------------------------------------------------------------------
		//
		//  Overrided methods: Socket
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public override function connect(host:String, port:int):void {
			super.connect( host, port );
			this._host = host;
			this._port = port;
			super.dispatchEvent( new Event( Event.OPEN ) ); // задержечку надо бы сделать
		}

		/**
		 * @inheritDoc
		 */
		public override function close():void {
			super.close();
			// патч. эта сука не генерит событие.
			super.dispatchEvent( new Event( Event.CLOSE ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_close(event:Event):void {
			this._host = null;
			this._port = 0;
		}

	}

}