////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle {

	import by.blooddy.core.database.Data;
	import by.blooddy.core.database.DataContainer;
	import by.blooddy.core.database.DataLinker;
	import by.blooddy.core.utils.time.Time;
	
	import ru.avangardonline.database.battle.world.BattleWorldData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					28.07.2009 20:20:44
	 */
	public class BattleData extends DataContainer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleData(time:Time) {
			super();
			this._world = new BattleWorldData( time )
			DataLinker.link( this, this._world, true );
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

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  numTurns
		//----------------------------------

		public function get numTurns():uint {
			return this._turns.length;
		}

		//----------------------------------
		//  world
		//----------------------------------

		/**
		 * @private
		 */
		private var _world:BattleWorldData;

		public function get world():BattleWorldData {
			return this._world;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getTurn(num:uint):BattleTurnData {
			return this._turns[ num ];
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
			}
		}

	}

}