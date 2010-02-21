////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.actions {

	import by.blooddy.core.commands.Command;
	
	import ru.avangardonline.data.battle.world.BattleWorldElementCollectionData;
	import ru.avangardonline.data.character.MinionCharacterData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					11.08.2009 21:23:40
	 */
	public class BattleAtackActionData extends BattleWorldElementActionData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleAtackActionData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  targetID
		//----------------------------------

		/**
		 * @private
		 */
		private var _targetID:uint;

		public function get targetID():uint {
			return this._targetID;
		}

		/**
		 * @private
		 */
		public function set targetID(value:uint):void {
			if ( this._targetID === value ) return;
			this._targetID = value;
		}

		//----------------------------------
		//  targetIncreaseHealth
		//----------------------------------

		/**
		 * @private
		 */
		private var _targetHealthIncrement:int;

		public function get targetHealthIncrement():int {
			return this._targetHealthIncrement;
		}

		/**
		 * @private
		 */
		public function set targetHealthIncrement(value:int):void {
			if ( this._targetHealthIncrement === value ) return;
			this._targetHealthIncrement = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'startTime', 'elementID', 'targetID', 'targetHealthIncrement' );
		}

		public override function getCommands():Vector.<Command> {
			var result:Vector.<Command> = new Vector.<Command>();
			result.push(
				this.getCommand(
					new Command(
						'atack',
						[ this._targetID ]
					)
				),
				this.getCommand(
					new Command(
						'defence',
						[ super.elementID ]
					),
					this._targetID
				),
				this.getCommand(
					new Command(
						'incHealth',
						[ -this._targetHealthIncrement ]
					),
					this._targetID
				)
			);
			return result;
		}

		public override function apply(collection:BattleWorldElementCollectionData):void {
			var element:MinionCharacterData = collection.getElement( this._targetID ) as MinionCharacterData;
			if ( !element ) throw new ArgumentError();
			element.health.current -= this._targetHealthIncrement;
		}

	}

}