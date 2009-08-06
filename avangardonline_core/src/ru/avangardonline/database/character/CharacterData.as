////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.character {

	import ru.avangardonline.database.battle.world.BattleWorldElementData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * @created					05.08.2009 22:12:56
	 */
	public class CharacterData extends BattleWorldElementData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function CharacterData(id:uint) {
			super();
			this._id = id;
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

	}

}