////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.character {

	import by.blooddy.core.display.BitmapMovieClip;
	import by.blooddy.core.display.StageObserver;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import ru.avangardonline.data.character.CharacterData;
	import ru.avangardonline.display.gfx.battle.world.animation.Animation;
	import ru.avangardonline.display.gfx.battle.world.animation.BattleWorldAnimatedElementView;
	import ru.avangardonline.events.data.character.CharacterDataEvent;
	import ru.avangardonline.events.data.character.CharacterInteractionDataEvent;
	import ru.avangardonline.data.battle.world.BattleWorldCoordinateData;
	import ru.avangardonline.events.data.battle.world.BattleWorldCoordinateDataEvent;
	
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

		/**
		 * @private
		 */
		private static const _ANIM_IDLE:Animation =		new Animation();

		/**
		 * @private
		 */
		private static const _ANIM_MOVE:Animation =		new Animation( 1, 0 );

		/**
		 * @private
		 */
		private static const _ANIM_ATACK:Animation =	new Animation( 3, 1, 2 );

		/**
		 * @private
		 */
		private static const _ANIM_DEFENCE:Animation =	new Animation( 4, 1, 1 );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function CharacterView(data:CharacterData!) {
			super( data );
			this._data = data;
			var observer:StageObserver = new StageObserver( this );
			observer.registerEventListener( data, CharacterDataEvent.VICTORY,						this.handler_victory );
			observer.registerEventListener( data, CharacterInteractionDataEvent.ATACK,				this.handler_atack );
			observer.registerEventListener( data, CharacterInteractionDataEvent.DEFENCE,			this.handler_defence );
			observer.registerEventListener( data, BattleWorldCoordinateDataEvent.MOVING_START,		this.handler_movingStart );
			observer.registerEventListener( data, BattleWorldCoordinateDataEvent.MOVING_STOP,		this.handler_movingStop );
			observer.registerEventListener( data, BattleWorldCoordinateDataEvent.COORDINATE_CHANGE,	this.handler_coordinateChange );
			this.setAnimation( _ANIM_IDLE );
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
			var key:String = this.getAnimationKey();
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

		protected virtual function getAnimationKey():String {
			throw new ArgumentError();
		}

		/**
		 * @private
		 */
		protected override function clear(event:Event=null):Boolean {
			if ( this.$element ) {
				super.removeChild( this.$element );
				//( this.$element as BitmapMovieClip ).dispose();
				this.$element = null;
			}
			if ( !super.clear( event ) ) return false;
			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_victory(event:CharacterDataEvent):void {
//			trace( event );
		}

		/**
		 * @private
		 */
		private function handler_atack(event:CharacterInteractionDataEvent):void {
			this.setAnimation( _ANIM_ATACK );
		}

		/**
		 * @private
		 */
		private function handler_defence(event:CharacterInteractionDataEvent):void {
			this.setAnimation( _ANIM_DEFENCE );
		}

		/**
		 * @private
		 */
		private function handler_movingStart(event:BattleWorldCoordinateDataEvent):void {
			this.setAnimation( _ANIM_MOVE );
		}

		/**
		 * @private
		 */
		private function handler_movingStop(event:BattleWorldCoordinateDataEvent):void {
			this.setAnimation( _ANIM_IDLE );
		}

		/**
		 * @private
		 */
		private function handler_coordinateChange(event:BattleWorldCoordinateDataEvent):void {
			this.setAnimation( _ANIM_IDLE );
		}

	}

}