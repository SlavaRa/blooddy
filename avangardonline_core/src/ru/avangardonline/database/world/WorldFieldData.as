////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.world {

	import by.blooddy.core.database.DataContainer;

	import ru.avangardonline.events.database.world.WorldDataEvent;

	[Event(name="widthChange", type="ru.avangardonline.events.database.world.WorldDataEvent")]
	[Event(name="heightChange", type="ru.avangardonline.events.database.world.WorldDataEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					29.07.2009 21:14:56
	 */
	public class WorldFieldData extends DataContainer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function WorldFieldData() {
			super();
		}

		//----------------------------------
		//  width
		//----------------------------------

		/**
		 * @private
		 */
		private var _width:uint

		public function get width():uint {
			return this._width;
		}

		/**
		 * @private
		 */
		public function set width(value:uint):void {
			if ( this._width == value ) return;
			this._width = value;
			if ( super.hasEventListener( WorldDataEvent.WIDTH_CHANGE ) ) {
				super.dispatchEvent( new WorldDataEvent( WorldDataEvent.WIDTH_CHANGE ) );
			}
		}

		//----------------------------------
		//  height
		//----------------------------------

		/**
		 * @private
		 */
		private var _height:uint

		public function get height():uint {
			return this._height;
		}

		/**
		 * @private
		 */
		public function set height(value:uint):void {
			if ( this._height == value ) return;
			this._height = value;
			if ( super.hasEventListener( WorldDataEvent.HEIGHT_CHANGE ) ) {
				super.dispatchEvent( new WorldDataEvent( WorldDataEvent.HEIGHT_CHANGE ) );
			}
		}

	}

}