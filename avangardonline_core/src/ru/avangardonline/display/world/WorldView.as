////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.world {

	import by.blooddy.core.display.destruct;
	import by.blooddy.core.display.resource.MainResourceSprite;
	
	import flash.events.Event;
	
	import ru.avangardonline.database.world.WorldData;
	import flash.utils.Dictionary;
	import ru.avangardonline.database.character.CharacterData;
	import ru.avangardonline.display.character.CharacterView;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					04.08.2009 19:58:31
	 */
	public class WorldView extends MainResourceSprite {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const CELL_WIDTH:uint = 60;

		public static const CELL_HEIGHT:uint = 60;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function WorldView(data:WorldData) {
			super();
			this._data = data;
			this._field = new WorldFieldView( data.field );
			this._field.rotationX = -90;
			super.addEventListener( Event.ADDED_TO_STAGE,		this.render,	false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE,	this.clear,		false, int.MAX_VALUE, true );
		}

		public function destruct():void {
			this._data = null;
			by.blooddy.core.display.destruct( this );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _characters:Dictionary = new Dictionary();

		/**
		 * @private
		 */
		private var _field:WorldFieldView;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  data
		//----------------------------------

		/**
		 * @private
		 */
		private var _data:WorldData;

		public function get data():WorldData {
			return this._data;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected function render(event:Event=null):Boolean {
			if ( !super.stage ) return false;

			super.addChild( this._field );

			var characters:Vector.<CharacterData> = this._data.characters.getCharacters();
			for each ( var data:CharacterData in characters ) {
				this.addCharacter( data );
			}

			return true;
		}

		/**
		 * @private
		 */
		protected function clear(event:Event=null):Boolean {
			super.removeChild( this._field );
			for ( var o:Object in this._characters ) {
				this.removeCharacter( o as CharacterData );
			}
			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function addCharacter(data:CharacterData):void {
			if ( data in this._characters ) throw new ArgumentError();
			var view:CharacterView = new CharacterView( data );
			super.addChild( view );
			this._characters[ data ] = view;
			this.updatePosition( data );
		}

		/**
		 * @private
		 */
		private function removeCharacter(data:CharacterData):void {
			if ( !( data in this._characters) ) throw new ArgumentError();
			var view:CharacterView = this._characters[ data ];
			if ( !view ) return;
			delete this._characters[ data ];
			super.removeChild( view );
		}

		/**
		 * @private
		 */
		private function updatePosition(data:CharacterData):void {
			var view:CharacterView = this._characters[ data ];
			view.x =   data.x * CELL_WIDTH;
			view.z = - data.y * CELL_HEIGHT;
		}

	}

}