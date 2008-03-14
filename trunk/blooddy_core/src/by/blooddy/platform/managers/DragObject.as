////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.managers {

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import by.blooddy.platform.events.DragEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @eventType			platform.events.DragEvent.DRAG_STOP
	 */
	[Event(name="dragStop", type="platform.events.DragEvent")]

	/**
	 * @eventType			platform.events.DragEvent.DRAG_MOVE
	 */
	[Event(name="dragMove", type="platform.events.DragEvent")]

	/**
	 * @eventType			platform.events.DragEvent.DRAG_FAIL
	 */
	[Event(name="dragFail", type="platform.events.DragEvent")]

	/**
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					dragobject, drag
	 */
	public final class DragObject extends Shape {

		//--------------------------------------------------------------------------
		//
		//  Internal class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		internal static function getNewInstance(dragSource:DisplayObject, rescale:Boolean=false, offset:Point=null, bounds:Rectangle=null):DragObject {
			internalCall = true;
			var info:DragObject = new DragObject(dragSource, rescale, offset, bounds);
			internalCall = false;
			return info;
		}

		//--------------------------------------------------------------------------
		//
		//  Internal class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var internalCall:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public function DragObject(dragSource:DisplayObject, rescale:Boolean=false, offset:Point=null, bounds:Rectangle=null) {
			super();
			if (!internalCall) throw new ArgumentError();
			this._dragSource = dragSource;
			this._rescale = rescale;
			this._offset = offset || new Point();
			this._bounds = bounds;
			this._lastMouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, this._offset.x, this._offset.y, null, false, false, false, true, 0);
			super.addEventListener(Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MAX_VALUE);
			super.addEventListener(Event.REMOVED_FROM_STAGE, this.handler_removedFromStage, false, int.MAX_VALUE);
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _bitmapData:BitmapData;

		/**
		 * @private
		 */
		private var _rescale:Boolean;

		/**
		 * @private
		 */
		private var _mouseLeave:Boolean = false;

		/**
		 * @private
		 */
		private var _lastMouseEvent:MouseEvent;

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: DisplayObject
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function set x(value:Number):void {
			throw new IllegalOperationError();
		}

		/**
		 * @private
		 */
		public override function set y(value:Number):void {
			throw new IllegalOperationError();
		}

		/**
		 * @private
		 */
		public override function get parent():DisplayObjectContainer {
			return null;
		}

		/**
		 * @private
		 */
		internal function get $parent():DisplayObjectContainer {
			return super.parent;
		}

		/**
		 * @private
		 */
		public override function get stage():Stage {
			return null;
		}

		/**
		 * @private
		 */
		public override function set visible(value:Boolean):void {
			throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: Shape
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function get graphics():Graphics {
			throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _dragSource:DisplayObject;

		public function get dragSource():DisplayObject {
			return this._dragSource;
		}

		/**
		 * @private
		 */
		private var _offset:Point;

		public function get offset():Point {
			return this._offset.clone();
		}

		/**
		 * @private
		 */
		public function set offset(value:Point):void {
			if ( !value || this._offset === value || value.equals( this._offset ) ) return;
			this._offset = value;
			this.updatePosition();
		}

		/**
		 * @private
		 */
		private var _bounds:Rectangle;

		public function get bounds():Rectangle {
			return this._bounds.clone();
		}

		/**
		 * @private
		 */
		public function set bounds(value:Rectangle):void {
			if ( !value || this._bounds === value || value.equals( this._bounds ) ) return;
			this._bounds = value;
			this.updatePosition();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: EventDispatcher
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * переопределяем и ставим заглушку от идиотов.
		 * useWeakReference всегда true, так как объект долго не живёт.
		 */
		public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0.0, useWeakReference:Boolean=false):void {
			super.addEventListener(type, listener, useCapture, priority, true);
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updatePosition():void {
			var oldX:Number = x;
			var oldY:Number = y;
			var x:Number = super.stage.mouseX + this._offset.x;
			var y:Number = super.stage.mouseY + this._offset.y;
			if (this._bounds) {
				x = Math.min( Math.max( this._bounds.left, x ), this._bounds.right );
				y = Math.min( Math.max( this._bounds.top, y ), this._bounds.bottom );
			}
			super.visible = !this._mouseLeave;
/*			if (event && event.shiftKey) { // зажат шифт
				var p:Point = new Point( this._dragSource.x, this._dragSource.y );
				p = this._dragSource.parent.localToGlobal( p );
				p.x = super.x - p.x;
				p.y = super.y - p.y;
				var angle:Number = Math.round( Math.atan2( p.x, p.y ) / Math.PI * 180 / 45 ) * 45 / 180 * Math.PI;
				if ( Math.abs(p.x) < Math.abs(p.y) ) {
					super.y = super.y + Math.tan( angle ) * p.x - p.y;
				} else {
					super.x = super.x + Math.tan( angle ) * p.y - p.x;
				}
			}*/
			super.x = x;
			super.y = y;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {

			// отрисуем
			var scaleX:Number = this._dragSource.scaleX;
			var scaleY:Number = this._dragSource.scaleY;
			this._dragSource.scaleX = 1;
			this._dragSource.scaleY = 1;

			var bounds:Rectangle = this._dragSource.getBounds( this._dragSource );

			this._bitmapData = new BitmapData( bounds.width+4, bounds.height+4, true, 0x00FF00 );
			this._bitmapData.draw( this._dragSource, new Matrix(1, 0, 0, 1, -bounds.x+2, -bounds.y+2) );

			this._dragSource.scaleX = scaleX;
			this._dragSource.scaleY = scaleY;

			super.graphics.beginBitmapFill( this._bitmapData, new Matrix(1, 0, 0, 1, bounds.x-2, bounds.y-2), false );
			super.graphics.drawRect( bounds.x-2, bounds.y-2, bounds.width+4, bounds.height+4 );
			super.graphics.endFill();

			if (this._rescale) {
				super.scaleX = scaleX;
				super.scaleY = scaleY;
			}

			this.updatePosition();

			super.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.handler_mouseMove, false, int.MAX_VALUE);
			super.stage.addEventListener(Event.MOUSE_LEAVE, this.handler_mouseLeave, false, int.MAX_VALUE);

		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {

			super.graphics.clear();
			this._bitmapData.dispose();

			super.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.handler_mouseMove);
			super.stage.removeEventListener(Event.MOUSE_LEAVE, this.handler_mouseLeave);

		}

		/**
		 * @private
		 */
		private function handler_mouseMove(event:MouseEvent):void {
			this._lastMouseEvent = event;
			if (this._mouseLeave) this._mouseLeave = false;
			this.updatePosition();
			event.updateAfterEvent();
		}

		/**
		 * @private
		 */
		private function handler_mouseLeave(event:Event):void {
			this._mouseLeave = true;
			this.updatePosition();
		}

	}

}