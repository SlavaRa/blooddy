////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import flash.display.DisplayObject;
	import flash.events.Event;

	[ExcludeClass]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					01.03.2010 3:18:11
	 */
	public final class DisplayObjectListener {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function DisplayObjectListener(target:DisplayObject) {
			super();
			target.addEventListener( Event.ADDED_TO_STAGE,		this.handler_addedToStage,		false, int.MAX_VALUE );
			target.addEventListener( Event.REMOVED_FROM_STAGE,	this.handler_removedFromStage,	false, int.MAX_VALUE );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _addedToStage:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {
			if ( this._addedToStage ) {
				event.stopImmediatePropagation();
			} else {
				this._addedToStage = true;
			}
		}
		
		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			this._addedToStage = false;
		}
		
	}

	}