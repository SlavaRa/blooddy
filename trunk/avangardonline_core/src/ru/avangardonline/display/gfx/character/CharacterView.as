////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.character {

	import by.blooddy.core.display.BitmapMovieClip;
	import by.blooddy.core.display.resource.ResourceDefinition;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import ru.avangardonline.data.character.CharacterData;
	import ru.avangardonline.display.gfx.battle.world.animation.Animation;
	import ru.avangardonline.display.gfx.battle.world.animation.BattleWorldAnimatedElementView;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.08.2009 22:10:59
	 */
	public class CharacterView extends BattleWorldAnimatedElementView {

		//--------------------------------------------------------------------------
		//
		//  Class variable
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _HASH:Object = new Object();

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
			this.setAnimation( new Animation() );
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

		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
/*		protected override function render(event:Event=null):Boolean {
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
				this.$element = super.getDisplayObject( bundleName, resourceName );
				super.addChild( this.$element );
				this.updateRotation( event );
			}

			return true;
		}*/

		protected override function renderAnimation(event:Event=null):Boolean {
			if ( !super.renderAnimation( event ) ) return false;
			if ( this.$element ) {
				//this.$element.scaleX = this.$element.scaleY = this.$element.scaleZ = .75;
			}
			return true;
		}

		protected override function getAnimation():DisplayObject {
			var key:String = 'key';
			var result:BitmapMovieClip;
			if ( key in _HASH ) {
				result = ( _HASH[ key ] as BitmapMovieClip ).clone();
			} else {
				var resource:DisplayObject = super.getAnimation();
				result = new BitmapMovieClip();
				if ( resource is MovieClip ) {
					var totalFrames:uint = ( resource as MovieClip ).totalFrames;
					for ( var i:uint = 1; i<totalFrames; i++ ) {
						( resource as MovieClip ).gotoAndStop( i+1 );
						result.addBitmap( resource );
					}
				} else {
					result.addBitmap( resource );
				}
				super.trashResource( resource );
				_HASH[ key ] = result;
			}
			return result;
		}

		/**
		 * @private
		 */
		protected override function clear(event:Event=null):Boolean {
			if ( this.$element ) {
				super.removeChild( this.$element );
				( this.$element as BitmapMovieClip ).dispose();
				this.$element = null;
			}
			if ( !super.clear( event ) ) return false;
			return true;
		}

		protected override function getAnimationDefinition():ResourceDefinition {
			return new ResourceDefinition( 'lib/display/character/c1.swf', 'x' );
		}

	}

}