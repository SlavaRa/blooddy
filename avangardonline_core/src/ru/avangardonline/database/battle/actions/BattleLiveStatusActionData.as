////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle.actions {

	import by.blooddy.core.commands.Command;
	
	import ru.avangardonline.database.battle.world.BattleWorldElementCollectionData;
	import ru.avangardonline.database.character.MinionCharacterData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 23:23:12
	 */
	public class BattleLiveStatusActionData extends BattleWorldElementActionData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleLiveStatusActionData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  live
		//----------------------------------

		/**
		 * @private
		 */
		private var _live:Boolean = false;

		public function get live():Boolean {
			return this._live;
		}

		/**
		 * @private
		 */
		public function set live(value:Boolean):void {
			if ( this._live === value ) return;
			this._live = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'elementID', 'live' );
		}

		public override function isResult():Boolean {
			return true;
		}

		public override function getCommands():Vector.<Command> {
			var result:Vector.<Command> = new Vector.<Command>();
			result.push(
				super.getCommand(
					new Command(
						'changeLiveStatus',
						[ this._live ]
					)
				)
			);
			return result;
		}

		public override function apply(collection:BattleWorldElementCollectionData):void {
			var element:MinionCharacterData = collection.getElement( super.elementID ) as MinionCharacterData;
			if ( !element ) throw new ArgumentError();
		}

	}

}