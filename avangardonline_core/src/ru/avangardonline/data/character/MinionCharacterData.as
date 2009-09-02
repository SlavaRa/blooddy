////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.character {

	import by.blooddy.core.data.Data;
	import by.blooddy.core.data.DataLinker;
	import by.blooddy.game.data.PointsData;

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
			DataLinker.link( this, this.health, true );
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
			if ( this._type == value ) return;
			this._type = value;
		}

		//----------------------------------
		//  health
		//----------------------------------

		public const health:PointsData = new PointsData();

		//----------------------------------
		//  live
		//----------------------------------

		/**
		 * @private
		 */
		private var _live:Boolean;

		public function get live():Boolean {
			return this._live;
		}

		/**
		 * @private
		 */
		public function set live(value:Boolean):void {
			if ( this._live == value ) return;
			this._live = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'id', 'group', 'type' );
		}

		public override function clone():Data {
			var result:MinionCharacterData = new MinionCharacterData( super.id );
			result.copyFrom( this );
			return result;
		}

		public override function copyFrom(data:Data):void {
			var target:MinionCharacterData = data as MinionCharacterData;
			if ( !target ) throw new ArgumentError();
			super.copyFrom( target );
			this.type = target._type;
			this.health.min =		target.health.min;
			this.health.current =	target.health.current;
			this.health.max =		target.health.max;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function changeLiveStatus(live:Boolean):void {
			this.live = live;
		}

		public function setHealth(health:uint):void {
			this.health.current = health;
		}

	}

}