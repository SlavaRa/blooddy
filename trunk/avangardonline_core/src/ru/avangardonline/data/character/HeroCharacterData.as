////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.character {

	import by.blooddy.core.data.Data;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					19.08.2009 22:11:37
	 */
	public class HeroCharacterData extends CharacterData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function HeroCharacterData(id:uint) {
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
		private var _nick:String;

		public function get nick():String {
			return this._nick;
		}

		/**
		 * @private
		 */
		public function set nick(value:String):void {
			if ( this._nick == value ) return;
			this._nick = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'id', 'nick', 'group' );
		}

		public override function clone():Data {
			var result:HeroCharacterData = new HeroCharacterData( super.id );
			result.copyFrom( this );
			return result;
		}

		public override function copyFrom(data:Data):void {
			var target:HeroCharacterData = data as HeroCharacterData;
			if ( !target ) throw new ArgumentError();
			super.copyFrom( target );
			this.nick = target._nick;
		}

	}

}