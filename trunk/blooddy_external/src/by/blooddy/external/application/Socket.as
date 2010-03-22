////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.external.application {

	import by.blooddy.core.net.connection.filters.SincereSocketFilter;
	import by.blooddy.external.net.SocketController;
	
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;

	[SWF( width="1", height="1", frameRate="120", backgroundColor="#FF0000", scriptTimeLimit="60" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					13.09.2009 19:02:05
	 */
	public final class Socket extends Sprite {

		//--------------------------------------------------------------------------
		//
		//  Static
		//
		//--------------------------------------------------------------------------

		Security.allowDomain( '*' );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function Socket() {
			super();

			//ExternalInterface.marshallExceptions = true;

			var loader:flash.net.URLLoader = new flash.net.URLLoader( new URLRequest( this.loaderInfo.parameters.protocol || 'protocol.xml' ) );
			loader.addEventListener( Event.COMPLETE,					this.handler_complete );
			loader.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_complete );
			loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_complete );

		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _controller:SocketController;

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			var loader:flash.net.URLLoader = event.target as flash.net.URLLoader;
			loader.removeEventListener( Event.COMPLETE,						this.handler_complete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_complete );
			loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_complete );
			if ( !( event is ErrorEvent ) ) { // протокол загрузился
				try {
					var filter:SincereSocketFilter = new SincereSocketFilter();
					filter.parseXML( new XML( loader.data ) );
					this._controller = new SocketController( this, filter, this.loaderInfo.parameters.so );
				} catch ( e:Error ) { // тупо гасим
					trace( e.getStackTrace() || e.toString() );
				}
			}
		}

	}

}