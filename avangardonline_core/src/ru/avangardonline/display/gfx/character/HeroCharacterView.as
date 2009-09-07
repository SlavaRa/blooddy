////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.character {

	import by.blooddy.core.display.resource.ResourceDefinition;
	
	import flash.events.Event;
	
	import ru.avangardonline.data.character.HeroCharacterData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					06.09.2009 16:13:00
	 */
	public class HeroCharacterView extends CharacterView {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function HeroCharacterView(data:HeroCharacterData) {
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
		private var _data:HeroCharacterData;

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

		/**
		 * @private
		 */
		protected override function getAnimationDefinition():ResourceDefinition {
			return new ResourceDefinition( 'lib/display/character/c' + '1' + '.swf', 'x' );
		}

		protected override function getAnimationKey():String {
			return this.currentAnim.id.toString();
		}

	}

}