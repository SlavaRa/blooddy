////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.character {

	import by.blooddy.core.database.Data;
	
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
			super( id );
		}

		//--------------------------------------------------------------------------
		//
		//  Proeprties
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function clone():Data {
			var result:CharacterData = new CharacterData( super.id );
			result.copyFrom( this );
			return result;
		}

	}

}