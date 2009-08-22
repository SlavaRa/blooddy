////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle.turns {

	import by.blooddy.core.database.Data;
	import by.blooddy.core.database.DataContainer;
	
	import ru.avangardonline.database.battle.actions.BattleActionData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					02.08.2009 12:12:51
	 */
	public class BattleTurnData extends DataContainer {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const TURN_TIME:uint = 2E3;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleTurnData(num:uint) {
			super();
			this._num = num;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _actions:Vector.<BattleActionData> = new Vector.<BattleActionData>();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  num
		//----------------------------------

		/**
		 * @private
		 */
		private var _num:uint;

		public function get num():uint {
			return this._num;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'num' );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function getActions():Vector.<BattleActionData> {
			return this._actions.slice();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function addChild_before(child:Data):void {
			if ( child is BattleActionData ) {
				var data:BattleActionData = child as BattleActionData;
				this._actions.push( data );
			}
		}

		/**
		 * @private
		 */
		protected override function removeChild_before(child:Data):void {
			if ( child is BattleActionData ) {
				var index:int = this._actions.indexOf( child );
				if ( index >= 0 ) this._actions.splice( index, 1 );
			}
		}

	}

}