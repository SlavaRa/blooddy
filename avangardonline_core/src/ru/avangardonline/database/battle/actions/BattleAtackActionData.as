////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle.actions {

	import by.blooddy.core.commands.Command;
	
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
		private var _targetIncreaseHealth:uint;

		public function get targetIncreaseHealth():uint {
			return this._targetIncreaseHealth;
		}

		/**
		 * @private
		 */
		public function set targetIncreaseHealth(value:uint):void {
			if ( this._targetIncreaseHealth === value ) return;
			this._targetIncreaseHealth = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function getCommands():Vector.<Command> {
			var result:Vector.<Command> = new Vector.<Command>();
			result.push(
				this.getCommand( new Command(
					'atack',
					[ this._targetID ]
				) )
			);
			result.push(
				this.getCommand( new Command(
					'increaseHealth',
					[ this._targetIncreaseHealth ]
				) )
			);
			return result;
		}

	}

}