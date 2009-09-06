////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.external {

	import flash.errors.IllegalOperationError;
	import flash.events.Event;

	[Event( name="historyChange", type="by.blooddy.core.events.DynamicEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class HistoryExternalConnection extends ExternalConnection {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _PATH:RegExp = /[\?\#]/;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
 		 * Constructor
		 *  
		 * @param	baseController
		 * @param	dataBase
		 * @param	sharedObject
		 */
		public function HistoryExternalConnection() {
			super();
			super.addEventListener( Event.CONNECT, this.handler_connect, false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _historyAvailable:Boolean = false;

		public function get historyAvailable():Boolean {
			return this._historyAvailable;
		}

		public function get href():String {
			if ( !this._historyAvailable ) throw new IllegalOperationError();
			return String( super.call( 'getHREF' ) );
		}

		public function set href(value:String):void {
			if ( !this._historyAvailable ) throw new IllegalOperationError();
			super.call( 'setHREF', value );
		}

		public function get path():String {
			if ( !this._historyAvailable ) throw new IllegalOperationError();
			var href:String = String( super.call( 'getHREF' ) );
			return href.split( _PATH, 2 )[ 0 ];
		}

		public function get search():String {
			if ( !this._historyAvailable ) throw new IllegalOperationError();
			var href:String = String( super.call( 'getHREF' ) );
			var index:int = href.indexOf( '?' );
			return ( index < 0 ? '' : href.substr( index + 1 ) );
		}

		public function get hash():String {
			if ( !this._historyAvailable ) throw new IllegalOperationError();
			var href:String = String( super.call( 'getHREF' ) );
			var index:int = href.indexOf( '#' );
			return ( index < 0 ? '' : href.substr( index + 1 ) );
		}

		public function get title():String {
			if ( !this._historyAvailable ) throw new IllegalOperationError();
			return String( super.call( 'getTitle' ) );
		}
	
		public function set title(value:String):void {
			if ( !this._historyAvailable ) throw new IllegalOperationError();
			super.call( 'setTitle', value );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function back():void {
			super.call( 'back' );
		}

		public function forward():void {
			super.call( 'forward' );
		}

		public function up():void {
			super.call( 'up' );
		}

		public function go(delta:int):void {
			super.call( 'go', delta )
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
			try {
				this._historyAvailable = Boolean( super.call( 'isHistoryAvailable' ) );
			} catch ( e:Error ) {
			}
		}
		
	}

}