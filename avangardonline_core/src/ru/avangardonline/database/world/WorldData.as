////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.world {

	import by.blooddy.core.database.DataContainer;
	import by.blooddy.core.database.DataLinker;
	import ru.avangardonline.database.character.CharacterCollectionData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.08.2009 21:39:10
	 */
	public class WorldData extends DataContainer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function WorldData() {
			super();
			DataLinker.link( this, this.field, true );
			DataLinker.link( this, this.characters, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  battleField
		//----------------------------------

		public const field:WorldFieldData = new WorldFieldData();

		//----------------------------------
		//  characters
		//----------------------------------

		public const characters:CharacterCollectionData = new CharacterCollectionData();

	}

}