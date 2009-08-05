////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.world {

	import by.blooddy.core.database.DataContainer;
	
	import ru.avangardonline.events.database.world.WorldElementDataEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.08.2009 22:12:56
	 */
	public class WorldElementData extends DataContainer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function WorldElementData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Proeprties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  x
		//----------------------------------

		/**
		 * @private
		 */
		private var _x:Number;

		public function get x():Number {
			return this._x;
		}

		/**
		 * @private
		 */
		public function set x(value:Number):void {
			if ( this._x == value ) return;
			this.stop();
			this._x = value;
			super.dispatchEvent( new WorldElementDataEvent( WorldElementDataEvent.COORDINATE_CHANGE, true ) );
		}

		//----------------------------------
		//  x
		//----------------------------------

		/**
		 * @private
		 */
		private var _y:Number;

		public function get y():Number {
			return this._y;
		}

		/**
		 * @private
		 */
		public function set y(value:Number):void {
			if ( this._y == value ) return;
			this.stop();
			this._y = value;
			super.dispatchEvent( new WorldElementDataEvent( WorldElementDataEvent.COORDINATE_CHANGE, true ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function stop():void {
		}

	}

}