////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.character {
	import by.blooddy.core.database.Data;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					19.08.2009 22:13:38
	 */
	public class MinionCharacterData extends CharacterData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function MinionCharacterData(id:uint) {
			super( id );
		}

		//--------------------------------------------------------------------------
		//
		//  Proeprties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  group
		//----------------------------------

		/**
		 * @private
		 */
		private var _type:uint;

		public function get type():uint {
			return this._type;
		}

		/**
		 * @private
		 */
		public function set type(value:uint):void {
			if ( this._type != value ) return;
			this._type = value;
		}

		//----------------------------------
		//  health
		//----------------------------------

		/**
		 * @private
		 */
		private var _health:uint;

		public function get health():uint {
			return this._health;
		}

		/**
		 * @private
		 */
		public function set health(value:uint):void {
			if ( this._health != value ) return;
			this._health = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function clone():Data {
			var result:MinionCharacterData = new MinionCharacterData( super.id );
			result.copyFrom( this );
			return result;
		}

		public override function copyFrom(data:Data):void {
			var target:MinionCharacterData = data as MinionCharacterData;
			if ( !target ) throw new ArgumentError();
			this.type = target._type;
			this.health = target._health;
		}

	}

}