////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {

	import by.blooddy.core.events.net.loading.LoaderEvent;
	import by.blooddy.core.events.net.loading.LoaderListenerEvent;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event( name="loaderEnabled", type="by.blooddy.core.events.net.loading.LoaderListenerEvent" )]
	[Event( name="loaderDisabled", type="by.blooddy.core.events.net.loading.LoaderListenerEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class LoaderListener extends ProgressDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function LoaderListener(target:IEventDispatcher) {
			super();
			this._target = target;
			target.addEventListener( LoaderEvent.LOADER_INIT, this.handler_loaderInit, false, int.MAX_VALUE, true );
			super.addEventListener( Event.COMPLETE, this.handler_complete, false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _target:IEventDispatcher;

		public function get target():IEventDispatcher {
			return this._target;
		}

		/**
		 * @private
		 */
		private var _running:Boolean = false;

		public function get running():Boolean {
			return this._running;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public override function close():void {
			if ( this._target ) {
				this._target.removeEventListener( LoaderEvent.LOADER_INIT, this.handler_loaderInit );
				this._target = null;
			}
			super.close();
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_loaderInit(event:LoaderEvent):void {
			var complete:Boolean = super.complete;
			super.addProcess( event.loader );
			if ( complete && !super.complete ) {
				this._running = true;
				super.dispatchEvent( new LoaderListenerEvent( LoaderListenerEvent.LOADER_ENABLED, false, false ) );
			}
		}

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			this._running = false;
			super.dispatchEvent( new LoaderListenerEvent( LoaderListenerEvent.LOADER_DISABLED, false, false ) );
		}

	}

}