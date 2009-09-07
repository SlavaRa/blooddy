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
		public function BattleWorldAnimatedElementView(data:BattleWorldElementData!) {
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
		private var _startTime:uint;

		/**
		 * @private
		 */
		private var _animation:MovieClip;

		/**
		 * @private
		 */
		private var _currentAnim_count:uint = 0;

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _currentAnim:Animation;

		protected function get currentAnim():Animation {
			return this._currentAnim;
		}

		protected function get animationSpeed():Number {
			return ( this._data.moving ? this._data.speed : 1 );
		}

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
			super.addChild( this.$element );
			if ( this.$element is MovieClip && ( this.$element as MovieClip ).totalFrames > 1 ) {
				this._data.world.time.addEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.updateDelay );
				this._animation = this.$element as MovieClip;
				this.updateDelay( event );
				this._timer.start();
				this.renderFrame( event );
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

			if ( !this._animation ) throw new IllegalOperationError();

			var totalFrames:int = this._animation.totalFrames;
			var time:Number = BattleTurnData.TURN_LENGTH / this.animationSpeed;
			
			var currentTime:Number = this._data.world.time.currentTime;
			if ( currentTime < this._startTime ) this._startTime = currentTime;
			
			var timesCount:Number = ( currentTime - this._startTime ) / time;
			var currentFrame:uint = Math.round( timesCount * ( totalFrames - 1 ) ) % totalFrames + 1;

			this._currentAnim_count = timesCount;

			this._animation.gotoAndStop( currentFrame );

			//если текущая анимация закончилась
			if ( this._currentAnim.repeatCount>0 && this._currentAnim_count >= this._currentAnim.repeatCount ) {
				this._currentAnim = null;
				this._currentAnim_count = 0;
				this._timer.stop();
				this._animation.gotoAndStop( this._animation.totalFrames );
				this.onAnimationComplete( event );
			}			

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
			if ( this._currentAnim && anim && this._currentAnim.priority > anim.priority ) return;
			this._currentAnim = anim;
			this._startTime = this._data.world.time.currentTime;
			this.render();
		}

		protected function onAnimationComplete(event:Event=null):void {
		}

		//--------------------------------------------------------------------------
		//
		//  Event handler
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updateDelay(event:Event=null):void {
			if ( this.$element is MovieClip && ( this.$element as MovieClip ).totalFrames > 1 ) {
				this._timer.delay = BattleTurnData.TURN_LENGTH / this.animationSpeed / ( this.$element as MovieClip ).totalFrames * 0.7;
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