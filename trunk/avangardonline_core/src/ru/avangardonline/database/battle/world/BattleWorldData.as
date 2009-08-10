////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle.world {

	import by.blooddy.core.database.Data;
	import by.blooddy.core.database.DataLinker;
	import by.blooddy.core.utils.time.Time;
	

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
			DataLinker.link( this, this.field, true );
			DataLinker.link( this, this.elements, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

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
		//  field
		//----------------------------------

		public const field:BattleWorldFieldData = new BattleWorldFieldData();

		//----------------------------------
		//  characters
		//----------------------------------

		public const elements:BattleWorldElementCollectionData = new BattleWorldElementCollectionData();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function clone():Data {
			var result:BattleWorldData = new BattleWorldData( this._time );
			result.copyFrom( this );
			return result;
		}

		public function copyFrom(data:Data):void {
			var target:BattleWorldData = data as BattleWorldData;
			if ( !target ) throw new ArgumentError();
			this._time = target._time;
			this.field.copyFrom( target.field );
			this.elements.copyFrom( target.elements );
		}

	}

}