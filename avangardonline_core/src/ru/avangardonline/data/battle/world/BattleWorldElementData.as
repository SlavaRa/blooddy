////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.world {

	import by.blooddy.core.data.Data;
	import by.blooddy.core.data.DataLinker;
	
	import ru.avangardonline.events.data.battle.world.BattleWorldCoordinateDataEvent;
	
	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event( name="coordinateChange", type="ru.avangardonline.events.database.world.BattleWorldCoordinateDataEvent" )]
	[Event( name="movingStart", type="ru.avangardonline.events.database.world.BattleWorldCoordinateDataEvent" )]
	[Event( name="movingStop", type="ru.avangardonline.events.database.world.BattleWorldCoordinateDataEvent" )]

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
		public function BattleWorldElementData(id:uint) {
			super();
			this._id = id;
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
		//  id
		//----------------------------------

		/**
		 * @private
		 */
		private var _id:uint;

		public function get id():uint {
			return this._id;
		}

		//----------------------------------
		//  coord
		//----------------------------------

		public const coord:BattleWorldCoordinateData = new BattleWorldCoordinateData();

		//----------------------------------
		//  moving
		//----------------------------------

		public function get moving():Boolean {
			return this.coord.moving;
		}

		//----------------------------------
		//  rotation
		//----------------------------------

		public function get rotation():Number {
			return this.coord.direction;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'id' );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function moveTo(x:Number, y:Number, time:Number):void {
			this.coord.moveTo( x, y, time );
		}

		public function clone():Data {
			var result:BattleWorldElementData = new BattleWorldElementData( this._id );
			result.copyFrom ( this );
			return result;
		}

		public function copyFrom(data:Data):void {
			var target:BattleWorldElementData = data as BattleWorldElementData;
			if ( !target ) throw new ArgumentError();
			this.coord.copyFrom( target.coord );
		}

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