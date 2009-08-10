////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.database.Data;
	
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
		public function BattleActionData(num:uint) {
			super();
			this._num = num;
		}

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

		//----------------------------------
		//  command
		//----------------------------------

		/**
		 * @private
		 */
		private var _command:Command;

		public function get command():Command {
			return this._command.clone();
		}

		public function set command(value:Command):void {
			if ( this._command === value ) return;
			this._command = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function call(client:Object, ns:Namespace=null):* {
			return this.command.call( client, ns );
		}

	}

}