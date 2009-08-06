////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.battle.world {

	import by.blooddy.core.display.destruct;
	import by.blooddy.core.display.resource.ResourceSprite;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	
	import ru.avangardonline.database.battle.world.BattleWorldElementData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.08.2009 22:12:19
	 */
	public class BattleWorldElementView extends ResourceSprite {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldElementView(data:BattleWorldElementData) {
			super();
			this._data = data;
			super.addEventListener( ResourceEvent.ADDED_TO_RESOURCE_MANAGER,		this.render,	false, int.MAX_VALUE, false );
			super.addEventListener( ResourceEvent.REMOVED_FROM_RESOURCE_MANAGER,	this.clear,		false, int.MAX_VALUE, false );
		}

		public function destruct():void {
			if ( !super.stage ) throw new IllegalOperationError();
			this._data = null;
			by.blooddy.core.display.destruct( this );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _data:BattleWorldElementData;

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected function render(event:Event=null):Boolean {
			if ( !super.stage ) return false;
			return true;
		}

		/**
		 * @private
		 */
		protected function clear(event:Event=null):Boolean {
			return true;
		}

	}

}