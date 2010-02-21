////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.character {

	import by.blooddy.core.display.resource.ResourceDefinition;
	
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
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
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _TEXT_FORMAT:TextFormat = new TextFormat( '_sans', 14, 0xFFFFFF, true, null, null, null, null, 'center' );
		
		/**
		 * @private
		 */
		private static const _TEXT_FILTERS:Array = new Array( new DropShadowFilter( 2, 45, 0x000000, 1, 3, 3 ) );
		
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

		/**
		 * @private
		 */
		private var _nick:TextField;
		
		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		protected override function render():Boolean {
			if ( !super.render() ) return false;
			
			this._nick = new TextField();
			this._nick.width = 120;
			this._nick.multiline = true;
			this._nick.wordWrap = true;
			this._nick.autoSize = TextFieldAutoSize.LEFT;
			this._nick.defaultTextFormat = _TEXT_FORMAT;
			this._nick.filters = _TEXT_FILTERS;
			this._nick.selectable = false;
			this._nick.text = this._data.name;
			super.addChild( this._nick );
			
			this._nick.x = -60;
			this._nick.y = -105 - this._nick.textHeight;

			return true;
		}

		protected override function clear():Boolean {
			if ( !super.clear() ) return false;

			if ( this._nick ) {
				super.removeChild( this._nick );
				this._nick = null;
			}
			
			return true;
		}

		/**
		 * @private
		 */
		protected override function getAnimationDefinition():ResourceDefinition {
			var race:String = this._data.race.toString();
			while ( race.length < 2 ) race = '0' + race;
			return new ResourceDefinition( 'lib/display/character/c' + race + '03' + '.swf', 'x' );
		}

		protected override function getAnimationKey():String {
			return String.fromCharCode( this._data.race, 3, this.currentAnim.id );
		}

	}

}