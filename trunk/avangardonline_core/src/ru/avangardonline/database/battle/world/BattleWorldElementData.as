////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle.world {

	import by.blooddy.core.database.DataContainer;
	import by.blooddy.core.database.DataLinker;
	import ru.avangardonline.events.database.world.BattleWorldCoordinateDataEvent;
	
	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event(name="coordinateChange", type="ru.avangardonline.events.database.world.BattleWorldCoordinateDataEvent")]
	[Event(name="movingStart", type="ru.avangardonline.events.database.world.BattleWorldCoordinateDataEvent")]
	[Event(name="movingStop", type="ru.avangardonline.events.database.world.BattleWorldCoordinateDataEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.08.2009 22:12:56
	 */
	public class BattleWorldElementData extends BattleWorldAssetDataContainer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldElementData() {
			super();
			DataLinker.link( this, this.coord, true );
			this.coord.addEventListener( BattleWorldCoordinateDataEvent.COORDINATE_CHANGE,	this.dispatchCoordinateEvent, false, int.MAX_VALUE, true );
			this.coord.addEventListener( BattleWorldCoordinateDataEvent.MOVING_START,		this.dispatchCoordinateEvent, false, int.MAX_VALUE, true );
			this.coord.addEventListener( BattleWorldCoordinateDataEvent.MOVING_STOP,		this.dispatchCoordinateEvent, false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Proeprties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  coord
		//----------------------------------

		public const coord:BattleWorldCoordinateData = new BattleWorldCoordinateData();

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function dispatchCoordinateEvent(event:BattleWorldCoordinateDataEvent):void {
			super.dispatchEvent( new BattleWorldCoordinateDataEvent( event.type, true ) );
		}

	}

}