////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.character {

	import by.blooddy.core.data.Data;
	
	import flash.errors.IllegalOperationError;

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
		public function HeroCharacterData(id:uint, name:String) {
			super( id );
			super.name = name;
		}

		//--------------------------------------------------------------------------
		//
		//  Proeprties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  name
		//----------------------------------

		/**
		 * @private
		 */
		public override function set name(value:String):void {
			throw new IllegalOperationError();
		}

		//----------------------------------
		//  sex
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _sex:Boolean;
		
		public function get sex():Boolean {
			return this._sex;
		}
		
		/**
		 * @private
		 */
		public function set sex(value:Boolean):void {
			if ( this._sex == value ) return;
			this._sex = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'id', 'name', 'group', 'sex' );
		}

		public override function clone():Data {
			var result:HeroCharacterData = new HeroCharacterData( super.id, super.name );
			result.copyFrom( this );
			return result;
		}

		public override function copyFrom(data:Data):void {
			var target:HeroCharacterData = data as HeroCharacterData;
			if ( !target ) throw new ArgumentError();
			super.copyFrom( target );
			this.sex = target._sex;
		}

	}

}