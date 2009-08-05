////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.character {

	import ru.avangardonline.database.character.CharacterData;
	import ru.avangardonline.display.world.WorldElementView;
	import flash.events.Event;
	import by.blooddy.core.net.ILoadable;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.display.DisplayObject;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.08.2009 22:10:59
	 */
	public class CharacterView extends WorldElementView {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function CharacterView(data:CharacterData) {
			super( data );
			this._data = data;
		}

		public override function destruct():void {
			this._data = null;
			super.destruct();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _data:CharacterData;

		/**
		 * @private
		 */
		private var _element:DisplayObject;

		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function render(event:Event=null):Boolean {
			if ( !super.render( event ) ) return false;

			var bundleName:String =		'lib/display/character/knight.swf';
			var resourceName:String =	'knight';

			var loader:ILoadable = super.loadResourceBundle( bundleName );
			if ( !loader.loaded ) {
				loader.addEventListener( Event.COMPLETE,						this.render );
				loader.addEventListener( IOErrorEvent.IO_ERROR,					this.render );
				loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,		this.render );
				return false;
			} else {
				loader.removeEventListener( Event.COMPLETE,						this.render );
				loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.render );
				loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.render );
			}

			if ( super.hasResource( bundleName, resourceName ) ) {
				this._element = super.getDisplayObject( bundleName, resourceName );
				super.addChild( this._element );
			}

			return true;
		}

		/**
		 * @private
		 */
		protected override function clear(event:Event=null):Boolean {
			if ( !super.clear( event ) ) return false;
			super.trashResource( this._element );
			this._element = null;
			return true;
		}

	}

}