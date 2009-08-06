////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle.world {

	import by.blooddy.core.database.DataContainer;
	import by.blooddy.core.database.DataLinker;
	import by.blooddy.core.utils.time.Time;
	
	import ru.avangardonline.database.character.CharacterCollectionData;
	import ru.avangardonline.events.database.world.BattleWorldDataEvent;

	/**
	 * @eventType			ru.avangardonline.events.database.world.WorldDataEvent.WIDTH_CHANGE
	 */
	[Event(name="widthChange", type="ru.avangardonline.events.database.world.BattleWorldDataEvent")]

	/**
	 * @eventType			ru.avangardonline.events.database.world.WorldDataEvent.HEIGHT_CHANGE
	 */
	[Event(name="heightChange", type="ru.avangardonline.events.database.world.BattleWorldDataEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.08.2009 21:39:10
	 */
	public class BattleWorldData extends BattleWorldAssetDataContainer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldData(time:Time) {
			super();
			this._time = time;
			super.set$world( this );
			DataLinker.link( this, this.characters, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  characters
		//----------------------------------

		public const characters:CharacterCollectionData = new CharacterCollectionData();

		//----------------------------------
		//  time
		//----------------------------------

		/**
		 * @private
		 */
		private var _time:Time;

		public function get time():Time {
			return this._time;
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
			if ( super.hasEventListener( BattleWorldDataEvent.WIDTH_CHANGE ) ) {
				super.dispatchEvent( new BattleWorldDataEvent( BattleWorldDataEvent.WIDTH_CHANGE ) );
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
			if ( super.hasEventListener( BattleWorldDataEvent.HEIGHT_CHANGE ) ) {
				super.dispatchEvent( new BattleWorldDataEvent( BattleWorldDataEvent.HEIGHT_CHANGE ) );
			}
		}

	}

}