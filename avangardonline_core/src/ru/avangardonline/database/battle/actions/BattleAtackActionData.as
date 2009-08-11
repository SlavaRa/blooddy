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
		//  targetHealth
		//----------------------------------

		/**
		 * @private
		 */
		private var _targetHealth:uint;

		public function get targetHealth():uint {
			return this._targetHealth;
		}

		/**
		 * @private
		 */
		public function set targetHealth(value:uint):void {
			if ( this._targetHealth === value ) return;
			this._targetHealth = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function getCommands():Vector.<Command> {
			var result:Vector.<Command> = super.getCommands();
			result.push(
				new Command(
					'forWorldElement',
					new Array(
						this._targetID,
						new Command(
							'setHealth',
							[ this._targetHealth ]
						)
					)
				)
			);
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		protected override function getLocalCommand():Command {
			return new Command( 'atack', [ this._targetID ] );
		}

	}

}