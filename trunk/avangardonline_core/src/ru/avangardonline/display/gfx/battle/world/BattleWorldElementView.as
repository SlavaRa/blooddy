////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.battle.world {

	import by.blooddy.core.display.StageObserver;
	import by.blooddy.core.display.resource.ResourceSprite;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import ru.avangardonline.data.battle.world.BattleWorldElementData;
	import ru.avangardonline.events.data.battle.world.BattleWorldCoordinateDataEvent;
	
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
		public function BattleWorldElementView(data:BattleWorldElementData!) {
			super();
			this._data = data;
			super.addEventListener( ResourceEvent.ADDED_TO_RESOURCE_MANAGER,		this.render,		false, int.MAX_VALUE, true );
			super.addEventListener( ResourceEvent.REMOVED_FROM_RESOURCE_MANAGER,	this.clear,			false, int.MAX_VALUE, true );
			var observer:StageObserver = new StageObserver( this );
			observer.registerEventListener( data, BattleWorldCoordinateDataEvent.COORDINATE_CHANGE,	this.updateRotation );
			observer.registerEventListener( data, BattleWorldCoordinateDataEvent.MOVING_START,		this.updateRotation );
			observer.registerEventListener( data, BattleWorldCoordinateDataEvent.MOVING_STOP,		this.updateRotation );
		}

		public function destruct():void {
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
		//  Protected properties
		//
		//--------------------------------------------------------------------------

		protected var $element:DisplayObject;

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
			if ( !super.stage ) return false;
			this.updateRotation( event );
			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected function updateRotation(event:Event=null):Boolean {
			if ( !this.$element ) return false;
			this.$element.scaleX = ( this._data.rotation < 90 ? 1 : -1 );
			return true
		}

	}

}