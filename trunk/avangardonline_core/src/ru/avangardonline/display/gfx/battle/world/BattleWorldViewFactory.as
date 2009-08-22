////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.battle.world {

	import ru.avangardonline.database.battle.world.BattleWorldElementData;
	import ru.avangardonline.database.character.CharacterData;
	import ru.avangardonline.database.character.HeroCharacterData;
	import ru.avangardonline.database.character.MinionCharacterData;
	import ru.avangardonline.display.gfx.character.CharacterView;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.08.2009 21:30:45
	 */
	public class BattleWorldViewFactory {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldViewFactory() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getElementView(data:BattleWorldElementData):BattleWorldElementView {
			if ( data is CharacterData ) {
				if ( data is MinionCharacterData )		return new CharacterView( data as CharacterData );
				else if ( data is HeroCharacterData )	return new CharacterView( data as CharacterData );
			}
			return null;
		}

	}

}