////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.character {

	import flash.events.Event;
	
	import ru.avangardonline.data.character.MinionCharacterData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					25.08.2009 12:40:03
	 */
	public class MinionCharacterView extends CharacterView {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function MinionCharacterView(data:MinionCharacterData) {
			super( data );
			this._data = data;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _data:MinionCharacterData;

		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		protected override function render(event:Event=null):Boolean {
			if ( !super.render( event ) ) return false;
			
			return true;
		}

		protected override function clear(event:Event=null):Boolean {
			if ( !super.clear( event ) ) return false;
			return true;
		}

	}

}