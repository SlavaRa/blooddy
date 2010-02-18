////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.controllers {

	import flash.display.DisplayObjectContainer;
	import flash.events.Event;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.08.2009 18:11:00
	 */
	public class DisplayObjectController extends AbstractController {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function DisplayObjectController(controller:IBaseController, container:DisplayObjectContainer, sharedObjectKey:String=null) {
			super( controller, sharedObjectKey );
			this._container = container;
			this._container.addEventListener( Event.ADDED_TO_STAGE,			this.handler_addedToStage,		false, 0, true );
			this._container.addEventListener( Event.REMOVED_FROM_STAGE,		this.handler_removedFromStage,	false, 0, true );
			if ( this._container.stage ) {
				this._container.addEventListener( Event.FRAME_CONSTRUCTED,	this.handler_frameConstructed,	false, 0, true );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _constructed:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  container
		//----------------------------------

		/**
		 * @private
		 */
		private var _container:DisplayObjectContainer;

		public function get container():DisplayObjectContainer {
			return this._container;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected virtual function construct():void {
		}

		protected virtual function destruct():void {
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_frameConstructed(event:Event):void {
			this._container.removeEventListener( Event.FRAME_CONSTRUCTED, this.handler_frameConstructed );
			if ( !this._constructed && this._container.stage ) {
				this._constructed = true;
				this.construct();
			}
		}

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {
			if ( !this._constructed ) {
				this._constructed = true;
				this.construct();
			}
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			if ( this._constructed ) {
				this._constructed = false;
				this.destruct();
			}
		}

	}

}