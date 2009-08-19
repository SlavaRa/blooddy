////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle.actions {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.database.Data;
	
	import flash.errors.IllegalOperationError;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					02.08.2009 13:16:42
	 */
	public class BattleActionData extends Data {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleActionData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  startTime
		//----------------------------------

		/**
		 * @private
		 */
		private var _startTime:uint;

		public function get startTime():uint {
			return this._startTime;
		}

		/**
		 * @private
		 */
		public function set startTime(value:uint):void {
			if ( this._startTime === value ) return;
			this._startTime = value;
		}

		//----------------------------------
		//  lengthTime
		//----------------------------------

		/**
		 * @private
		 */
		private var _lengthTime:uint;

		public function get lengthTime():uint {
			return this._lengthTime;
		}

		/**
		 * @private
		 */
		public function set lengthTime(value:uint):void {
			if ( this._lengthTime === value ) return;
			this._lengthTime = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function isResult():Boolean {
			return false;
		}

		public virtual function getCommands():Vector.<Command> {
			throw new IllegalOperationError();
		}

	}

}