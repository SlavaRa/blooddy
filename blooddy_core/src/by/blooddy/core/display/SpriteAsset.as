////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;

	/**
	 * Класс хак.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class SpriteAsset extends Sprite {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function SpriteAsset() {
			super();
			// ХАК
			this._stage = super.stage;
			super.addEventListener( Event.ADDED_TO_STAGE, this.handler_addedToStage_hack, false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE, this.handler_removedFromStage_hack1, false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE, this.handler_removedFromStage_hack2, false, int.MIN_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden peoperties: DisplayObject
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _stage:Stage;

		public override function get stage():Stage {
			return this._stage;
		}

		/**
		 * @private
		 */
		public override function set filters(value:Array):void {
			if ( !super.filters.length && ( !value || !value.length ) ) return;
			super.filters = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers: ХАК
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _addedToStage:Boolean = false;

		/**
		 * @private
		 */
		private function handler_addedToStage_hack(event:Event):void {
			if ( this._addedToStage ) {
				event.stopImmediatePropagation();
			} else {
				this._addedToStage = true;
				this._stage = super.stage;
			}
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage_hack1(event:Event):void {
			this._addedToStage = false;
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage_hack2(event:Event):void {
			if ( !this._addedToStage ) {
				this._stage = null;
			}
		}

	}

}