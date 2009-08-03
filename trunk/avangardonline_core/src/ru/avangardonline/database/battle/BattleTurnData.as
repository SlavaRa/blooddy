////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle {

	import by.blooddy.core.database.Data;
	import by.blooddy.core.database.DataContainer;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					02.08.2009 12:12:51
	 */
	public class BattleTurnData extends DataContainer implements IActionContainerData {

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

		/**
		 * @private
		 */
		private var _num:uint;

		public function get num():uint {
			return this._num;
		}

		/**
		 * @inheritDoc
		 */
		public function get numActions():uint {
			return this._actions.length;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function getAction(num:uint):BattleActionData {
			return this._actions[ num ];
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
				if ( data.num != this._actions.length ) throw new ArgumentError();
				this._actions.push( data );
			}
		}

		/**
		 * @private
		 */
		protected override function removeChild_before(child:Data):void {
			if ( child is BattleActionData ) {
				var data:BattleActionData = child as BattleActionData;
				if ( data.num != this._actions.length-1 ) throw new ArgumentError();
				if ( this._actions[ data.num ] !== data ) throw new ArgumentError();
				this._actions.pop();
			}
		}

	}

}