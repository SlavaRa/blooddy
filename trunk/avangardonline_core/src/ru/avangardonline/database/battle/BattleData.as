////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle {

	import by.blooddy.core.database.Data;
	import by.blooddy.core.database.DataContainer;
	import by.blooddy.core.events.database.DataBaseEvent;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					28.07.2009 20:20:44
	 */
	public class BattleData extends DataContainer implements IActionContainerData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleData() {
			super();
			super.addEventListener( DataBaseEvent.ADDED,	this.handler_changed, false, int.MAX_VALUE, true );
			super.addEventListener( DataBaseEvent.REMOVED,	this.handler_changed, false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _turns:Vector.<BattleTurnData> = new Vector.<BattleTurnData>();

		/**
		 * @private
		 */
		private var _actions:Vector.<BattleActionData> = new Vector.<BattleActionData>();

		/**
		 * @private
		 */
		private var _lastTurn:int = -1;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public function get numTurns():uint {
			return this._turns.length;
		}

		/**
		 * @inheritDoc
		 */
		public function get numActions():uint {
			const numTurns:uint = this._actions.length;
			if ( this._lastTurn < numTurns - 1 ) {
				var t:uint;
				var turn:BattleTurnData;
				var a:uint;
				var numActions:uint;
				for ( t=this._lastTurn + 1; t<numTurns; t++ ) {
					turn = this._turns[ t ];
					numActions = turn.numActions;
					for ( a=0; a<numActions; a++ ) {
						this._actions.push( turn.getAction( a ) );
					}
				}
				this._lastTurn = numTurns - 1;
			}
			return this._actions.length;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getTurn(num:uint):BattleTurnData {
			return this._turns[ num ];
		}

		/**
		 * @inheritDoc
		 */
		public function getAction(num:uint):BattleActionData {
			if ( this._actions.length <= num ) {
				var t:uint;
				const numTurns:uint = this._actions.length;
				var turn:BattleTurnData;
				var a:uint;
				var numActions:uint;
				for ( t=this._lastTurn + 1; t<numTurns || this._actions.length > num; t++ ) {
					turn = this._turns[ t ];
					numActions = turn.numActions;
					for ( a=0; a<numActions; a++ ) {
						this._actions.push( turn.getAction( a ) );
					}
				}
				this._lastTurn = t;
			}
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
			if ( child is BattleTurnData ) {
				var data:BattleTurnData = child as BattleTurnData;
				if ( data.num != this._turns.length ) throw new ArgumentError();
				this._turns.push( data );
				if ( this._actions.length > 0 ) {
					this._actions.splice( 0, this._actions.length );
				}
			}
		}

		/**
		 * @private
		 */
		protected override function removeChild_before(child:Data):void {
			if ( child is BattleTurnData ) {
				var data:BattleTurnData = child as BattleTurnData;
				if ( data.num != this._turns.length-1 ) throw new ArgumentError();
				if ( this._turns[ data.num ] !== data ) throw new ArgumentError();
				this._turns.pop();
				if ( this._actions.length > 0 ) {
					this._actions.splice( 0, this._actions.length );
				}
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_changed(event:DataBaseEvent):void {
			if ( event.target is BattleActionData ) {
				if ( this._actions.length > 0 ) {
					this._actions.splice( 0, this._actions.length );
				}
			}
		}

	}

}