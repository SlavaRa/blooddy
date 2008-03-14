package by.blooddy.platform.managers {

	import flash.events.EventDispatcher;
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import by.blooddy.platform.events.DragEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @eventType			platform.events.DragEvent.DRAG_START
	 */
	[Event(name="dragStart", type="platform.events.DragEvent")]

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

	public final class DragInfo extends EventDispatcher {

		internal static function getNewInstance():DragInfo {
			internalCall = true;
			var info:DragInfo = new DragInfo();
			internalCall = false;
			return info;
		}

		private static var internalCall:Boolean = false;

		public function DragInfo() {
			super();
			if (!internalCall) throw new ArgumentError();
		}

		private var _lastMouseEvent:MouseEvent;

		private var _dragSource:DisplayObject;

		public function get dragSource():DisplayObject {
			return this._dragSource;
		}

		private var _dragObject:DragObject;

		public function get dragObject():DragObject {
			return this._dragObject;
		}

		internal function doDrag(dragSource:DisplayObject, rescale:Boolean=false, offset:Point=null, bounds:Rectangle=null):void {
			if (!dragSource.stage) throw new ArgumentError();

			this._dragSource = dragSource;
			this._dragSource.addEventListener(Event.REMOVED_FROM_STAGE, this.handler_removeFromStage);

			if (!offset) offset = new Point( -this._dragSource.mouseX, -this._dragSource.mouseY );

			this._dragObject = DragObject.getNewInstance( this._dragSource, rescale, offset, bounds );

			offset = this._dragObject.offset;

			this._lastMouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, offset.x, offset.y, null, false, false, false, true, 0);

			var stage:Stage = this._dragSource.stage;

			stage.addChild( this._dragObject );

			stage.addEventListener(MouseEvent.MOUSE_MOVE, this.handler_mouseMove, false, int.MAX_VALUE);
			stage.addEventListener(MouseEvent.MOUSE_UP, this.handler_mouseUp, false, int.MAX_VALUE);
			stage.addEventListener(KeyboardEvent.KEY_UP, this.handler_keyUp, false, int.MAX_VALUE);

			this.dispatchDragEvent( DragEvent.DRAG_START );

		}

		private function clear():void {
			if (this._dragObject.$parent) {
				this._dragObject.$parent.removeChild( this._dragObject );
			}
			if (this._dragSource && this._dragSource.stage) {
				var stage:Stage = this._dragSource.stage;
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.handler_mouseMove);
				stage.removeEventListener(MouseEvent.MOUSE_UP, this.handler_mouseUp);
				stage.removeEventListener(KeyboardEvent.KEY_UP, this.handler_keyUp);
			}
			this._dragSource = null;
			this._dragObject = null;
		}

		private function dispatchDragEvent(type:String):void {
			var e:MouseEvent = this._lastMouseEvent;
			var offset:Point = ( this._dragObject ? this._dragObject.offset : null ) || new Point();
			super.dispatchEvent( new DragEvent(type, false, false, offset.x, offset.y, null, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta, this._dragSource, this._dragObject ) );
		}

		private function handler_removeFromStage(event:Event):void {
			( event.target as DisplayObject ).removeEventListener(Event.REMOVED_FROM_STAGE, this.handler_removeFromStage);
			if ( this._dragSource === event.target ) {
				this.clear();
				this.dispatchDragEvent( DragEvent.DRAG_FAIL );
			}
		}

		private function handler_mouseUp(event:MouseEvent):void {
			this._lastMouseEvent = event;
			this.dispatchDragEvent( DragEvent.DRAG_STOP );
			this.clear();
		}

		private function handler_mouseMove(event:MouseEvent):void {
			this._lastMouseEvent = event;
			this.dispatchDragEvent( DragEvent.DRAG_MOVE );
		}

		private function handler_keyUp(event:KeyboardEvent):void {
			if ( event.keyCode == Keyboard.ESCAPE ) {
				this.dispatchDragEvent( DragEvent.DRAG_FAIL );
				this.clear();
			}
		}

	}

}