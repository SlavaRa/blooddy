////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.battle.world.animation {

	import by.blooddy.core.display.resource.ResourceDefinition;
	import by.blooddy.core.events.time.TimeEvent;
	import by.blooddy.core.net.ILoadable;
	import by.blooddy.core.utils.time.FrameTimer;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	
	import ru.avangardonline.data.battle.turns.BattleTurnData;
	import ru.avangardonline.data.battle.world.BattleWorldElementData;
	import ru.avangardonline.display.gfx.battle.world.BattleWorldElementView;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.08.2009 11:45:10
	 */
	public class BattleWorldAnimatedElementView extends BattleWorldElementView {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldAnimatedElementView(data:BattleWorldElementData) {
			super( data );
			this._data = data;
			this._timer.addEventListener( TimerEvent.TIMER,	this.renderFrame,	false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _data:BattleWorldElementData;

		/**
		 * @private
		 */
		private const _timer:FrameTimer = new FrameTimer( 0 );

		/**
		 * @private
		 */
		private var _currentAnim:Animation;

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function render(event:Event=null):Boolean {
			this.clear( event );
			this._timer.stop();
			if ( !super.stage ) return false;
			var definition:ResourceDefinition = this.getAnimationDefinition();
			if ( !definition ) return false;
			var loader:ILoadable = super.loadResourceBundle( definition.bundleName );
			if ( loader.loaded ) {
				return this.renderAnimation();
			} else {
				loader.addEventListener( Event.COMPLETE,					this.handler_complete );
				loader.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_complete );
				loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_complete );
			}
			return false;
		}

		protected function renderAnimation(event:Event=null):Boolean {
			if ( !super.stage || !this._currentAnim ) return false;
			this.$element = this.getAnimation();
			if ( this.$element ) {
				super.addChild( this.$element );
				if ( this.$element is MovieClip && ( this.$element as MovieClip ).totalFrames > 1 ) {
					this._data.world.time.addEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.updateDelay );
					this.updateDelay();
					this._timer.start();
					this.renderFrame( event );
				}
			}
			this.updateRotation( event );
			return true;
		}

		/**
		 * @private
		 */
		protected override function clear(event:Event=null):Boolean {
			if ( this.$element ) {
				this.trashResource( this.$element );
				this.$element = null;
			}
			this._timer.stop();
			this._data.world.time.addEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.updateDelay );
			return true;
		}

		protected function renderFrame(event:Event=null):Boolean {
			var mc:MovieClip = this.$element as MovieClip;
			if ( !mc ) return false;
			
			var ratio:Number = this._data.world.time.currentTime / BattleTurnData.TURN_LENGTH;
			
			mc.gotoAndStop( Math.round( ratio * ( mc.totalFrames - 1 ) ) % mc.totalFrames + 1 );
			
			return true;
		}

		protected virtual function getAnimationDefinition():ResourceDefinition {
			throw new IllegalOperationError();
		}

		protected function getAnimation():DisplayObject {
			var definition:ResourceDefinition = this.getAnimationDefinition();
			return super.getDisplayObject( definition.bundleName, definition.resourceName + this._currentAnim.id );
		}

		protected function setAnimation(anim:Animation):void {
			this._currentAnim = anim;
			this.render();
		}

		//--------------------------------------------------------------------------
		//
		//  Event handler
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updateDelay(event:TimeEvent=null):void {
			if ( this.$element is MovieClip ) {
				this._timer.delay = ( BattleTurnData.TURN_LENGTH * this._data.world.time.speed ) / ( this.$element as MovieClip ).totalFrames;
				trace( this._timer.delay );
			}
		}

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			var loader:ILoadable = event.target as ILoadable;
			loader.removeEventListener( Event.COMPLETE,						this.handler_complete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_complete );
			loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_complete );
			this.render( event );
		}

	}

}