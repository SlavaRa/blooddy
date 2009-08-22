////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle.turns {

	import by.blooddy.core.database.DataContainer;
	import by.blooddy.core.database.DataLinker;
	
	import ru.avangardonline.database.battle.world.BattleWorldElementCollectionData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					20.08.2009 21:57:54
	 */
	public class BattleTurnWorldElementContainerData extends DataContainer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleTurnWorldElementContainerData(turnNum:uint, collection:BattleWorldElementCollectionData) {
			super();
			this._turnNum = turnNum;
			this._collection = collection;
			DataLinker.link( this, collection, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  turnNum
		//----------------------------------

		/**
		 * @private
		 */
		private var _turnNum:uint;

		public function get turnNum():uint {
			return this._turnNum;
		}

		//----------------------------------
		//  num
		//----------------------------------

		/**
		 * @private
		 */
		private var _collection:BattleWorldElementCollectionData;

		public function get collection():BattleWorldElementCollectionData {
			return this._collection;
		}

	}

}