////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.world {

	import by.blooddy.core.display.resource.ResourceSprite;
	
	import flash.events.Event;
	
	import ru.avangardonline.database.world.WorldElementData;
	import by.blooddy.core.display.destruct;
	import flash.errors.IllegalOperationError;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.08.2009 22:12:19
	 */
	public class WorldElementView extends ResourceSprite {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function WorldElementView(data:WorldElementData) {
			super();
			this._data = data;
			super.addEventListener( Event.ADDED_TO_STAGE,		this.render,	false, int.MAX_VALUE, false );
			super.addEventListener( Event.REMOVED_FROM_STAGE,	this.clear,		false, int.MAX_VALUE, false );
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
		private var _data:WorldElementData;

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