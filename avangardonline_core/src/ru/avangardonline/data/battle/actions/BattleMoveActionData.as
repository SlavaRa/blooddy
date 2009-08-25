////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.actions {

	import by.blooddy.core.commands.Command;
	
	import ru.avangardonline.data.battle.world.BattleWorldElementCollectionData;
	import ru.avangardonline.data.battle.world.BattleWorldElementData;
	import ru.avangardonline.data.battle.turns.BattleTurnData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					11.08.2009 20:57:48
	 */
	public class BattleMoveActionData extends BattleWorldElementActionData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleMoveActionData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  x
		//----------------------------------

		/**
		 * @private
		 */
		private var _x:int;

		public function get x():int {
			return this._x;
		}

		/**
		 * @private
		 */
		public function set x(value:int):void {
			if ( this._x == value ) return;
			this._x = value;
		}

		//----------------------------------
		//  y
		//----------------------------------

		/**
		 * @private
		 */
		private var _y:int;

		public function get y():int {
			return this._y;
		}

		/**
		 * @private
		 */
		public function set y(value:int):void {
			if ( this._y == value ) return;
			this._y = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'startTime', 'elementID', 'x', 'y' );
		}

		public override function getCommands():Vector.<Command> {
			var result:Vector.<Command> = new Vector.<Command>();
			result.push(
				super.getCommand(
					new Command(
						'moveTo',
						[ this._x, this._y, this.startTime + BattleTurnData.TURN_LENGTH ]
					)
				)
			);
			return result;
		}

		public override function apply(collection:BattleWorldElementCollectionData):void {
			var element:BattleWorldElementData = collection.getElement( super.elementID );
			if ( !element ) throw new ArgumentError();
			element.coord.setValues( this._x, this._y );
		}

	}

}