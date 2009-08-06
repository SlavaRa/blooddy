////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle.world {

	import by.blooddy.core.database.DataContainer;
	import by.blooddy.core.database.DataLinker;
	
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


	}

}