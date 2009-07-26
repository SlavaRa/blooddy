package by.blooddy.core.display {

	import by.blooddy.core.display.IProgressBar;
	import by.blooddy.core.managers.IProgressable;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import by.blooddy.core.utils.css.ColorUtils;

	public class ProgressBar extends Shape implements IProgressBar {

		public function ProgressBar() {
			super();
			super.addEventListener(Event.ADDED_TO_STAGE, this.render, false, int.MAX_VALUE, true);
			super.addEventListener(Event.REMOVED_FROM_STAGE, this.clear, false, int.MAX_VALUE, true);
		}

		private var _width:Number = 40;

		public override function get width():Number {
			return this._width;
		}

		public override function set width(value:Number):void {
			if ( this._width == value ) return;
			this._width = value;
			this.render();
		}

		private var _height:Number = 2;

		public override function get height():Number {
			return this._height;
		}

		public override function set height(value:Number):void {
			if ( this._height == value ) return;
			this._height = value;
			this.render();
		}

		private var _borderColor32:Object;

		public function get borderColor32():Object {
			return this._borderColor32;
		}

		public function set borderColor32(value:Object):void {
			if ( this._borderColor32 == value ) return;
			this._borderColor32 = value;
			this.render();
		}

		private var _bgColor32:Object;

		public function get bgColor32():Object {
			return this._bgColor32;
		}

		public function set bgColor32(value:Object):void {
			if ( this._bgColor32 == value ) return;
			this._bgColor32 = value;
			this.render();
		}

		private var _indicatorColor32:Object;

		public function get indicatorColor32():Object {
			return this._indicatorColor32;
		}

		public function set indicatorColor32(value:Object):void {
			if ( this._indicatorColor32 == value ) return;
			this._indicatorColor32 = value;
			this.render();
		}

		/**
		 * @private
		 */
		private var _progressDispatcher:IProgressable;

		public function get progressDispatcher():IProgressable {
			return this._progressDispatcher;
		}

		public function set progressDispatcher(value:IProgressable):void {
			if ( this._progressDispatcher === value ) return;
			if ( this._progressDispatcher ) {
				this._progressDispatcher.removeEventListener(ProgressEvent.PROGRESS, this.handler_progress);
			}
			this._progressDispatcher = value;
			if ( this._progressDispatcher ) {
				this._progressDispatcher.addEventListener(ProgressEvent.PROGRESS, this.handler_progress);
				this._progress = this._progressDispatcher.progress;
			} else {
				this._progress = 0;
			}
			this.render();
		}
		
		/**
		 * @private
		 */
		private var _progress:Number = 0;
		
		public function get progress():Number {
			return this._progress;
		}
		
		public function set progress(value:Number):void {
			if ( this._progressDispatcher || this._progress == value ) return;
			value = Math.max( Math.min( 0, value ), 1 );
			if ( this._progress == value ) return;
			this._progress = value;
			this.render();
		}
		
		protected function render(event:Event=null):Boolean {
			if ( !super.stage ) return false;

			super.graphics.clear();

			if ( this._width <= 0 || this._height <= 0 ) return false;

			var alpha:Number;
			var color:uint;
			
			color =	(	this._bgColor32 is Number ?
						this._bgColor32 as Number :
						(	this._bgColor32 is Array ?
							ColorUtils.getGradientColor( this._progress, this._bgColor32 as Array ) :
							parseInt( this._bgColor32 as String )
						)
					);
			alpha = ( ( color >> 24 ) & 0xFF ) / 0xFF;
			if ( alpha>0.05 ) {
				color = color & 0xFFFFFF;
				super.graphics.beginFill( color, alpha );
				super.graphics.drawRect(0, 0, this._width, this._height);
				super.graphics.endFill();
			}

			if ( this._progress > 0 ) {
				super.graphics.lineStyle();
				color =	(	this._indicatorColor32 is Number ?
							this._indicatorColor32 as Number :
							(	this._indicatorColor32 is Array ?
								ColorUtils.getGradientColor( this._progress, this._indicatorColor32 as Array ) :
								parseInt( this._indicatorColor32 as String )
							)
						);
				alpha = ( ( color >> 24 ) & 0xFF ) / 0xFF;
				color = color & 0xFFFFFF;
				super.graphics.beginFill( color, alpha );
				super.graphics.drawRect(0, 0, this._width * this._progress, this._height );
				super.graphics.endFill();
				// 3D суко!
				super.graphics.lineStyle(1, 0, 0.70, true);
				super.graphics.moveTo(0, this._height-1);
				super.graphics.lineTo(this._width * this._progress, this._height-1);
				super.graphics.lineStyle(1, 0, 0.40, true);
				super.graphics.moveTo(0, 1);
				super.graphics.lineTo(this._width * this._progress, 1);
			}

			color =	(	this._borderColor32 is Number ?
						this._borderColor32 as Number :
						(	this._borderColor32 is Array ?
							ColorUtils.getGradientColor( this._progress, this._borderColor32 as Array ) :
							parseInt( this._borderColor32 as String )
						)
					);
			alpha = ( ( color >> 24 ) & 0xFF ) / 0xFF;
			if ( alpha>0.05 ) {
				color = color & 0xFFFFFF;
				super.graphics.lineStyle( 1, color, alpha );
				super.graphics.drawRect(0, 0, this._width, this._height);
			}

			return true;
		}

		protected function clear(event:Event=null):Boolean {
			super.graphics.clear();
			return true;
		}

		private function handler_progress(event:ProgressEvent):void {
			this._progress = Math.min( Math.max( 0, this._progressDispatcher.progress ), 1 );
			this.render( event );
		}

	}

}