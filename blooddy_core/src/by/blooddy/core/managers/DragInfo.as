////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers {

	import by.blooddy.core.events.DragEvent;
	import by.blooddy.core.events.isIntrinsicEvent;
	import by.blooddy.core.utils.DisplayObjectUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @eventType			platform.events.DragEvent.DRAG_START
	 */
	[Event(name="dragStart", type="by.blooddy.core.events.DragEvent")]

	/**
	 * @eventType			platform.events.DragEvent.DRAG_STOP
	 */
	[Event(name="dragStop", type="by.blooddy.core.events.DragEvent")]

	/**
	 * @eventType			platform.events.DragEvent.DRAG_MOVE
	 */
	[Event(name="dragMove", type="by.blooddy.core.events.DragEvent")]

	/**
	 * @eventType			platform.events.DragEvent.DRAG_FAIL
	 */
	[Event(name="dragFail", type="by.blooddy.core.events.DragEvent")]

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude(kind="property", name="$instance")]

	[Exclude(kind="method", name="$doDrag")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					draginfo, drag
	 */
	public final class DragInfo extends EventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var _inited:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Internal class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		internal static const $instance:DragInfo = new DragInfo();

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public function DragInfo() {
			super();
			if (_inited) throw new ArgumentError();
			_inited = true;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _lastMouseEvent:MouseEvent;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//--------------------------------------
		//  dropTarget
		//--------------------------------------
	
		/**
		 * @private
		 */
		private var _dropTarget:DisplayObject;

		public function get dropTarget():DisplayObject {
			return this._dropTarget;
		}

		//--------------------------------------
		//  dragSource
		//--------------------------------------
	
		/**
		 * @private
		 */
		private var _dragSource:DisplayObject;

		public function get dragSource():DisplayObject {
			return this._dragSource;
		}

		//--------------------------------------
		//  dragObject
		//--------------------------------------
	
		/**
		 * @private
		 */
		private var _dragObject:DragObject;

		public function get dragObject():DragObject {
			return this._dragObject;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function dispatchEvent(event:Event):Boolean {
			if ( isIntrinsicEvent( this, event ) ) return true;
			else return super.dispatchEvent( event );
		}
		
		public function stopDrag():void {
			if (!this._dragSource) throw new IllegalOperationError();
			this.dispatchDragEvent( DragEvent.DRAG_FAIL );
			this.clear();
		}

		//--------------------------------------------------------------------------
		//
		//  Internal methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		internal function $doDrag(dragSource:DisplayObject, rescale:Boolean=false, offset:Point=null, bounds:Rectangle=null):void {
			if (!dragSource.stage) throw new ArgumentError();

			if ( this._dragSource == dragSource ) return;

			if ( this._dragSource ) {
				this.clear();
			}

			this._dragSource = dragSource;

			this._dragObject = DragObject.$getInstance( this._dragSource, rescale, offset, bounds );

			offset = this._dragObject.offset;

			this._lastMouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, offset.x, offset.y, null, false, false, false, true, 0);

			var stage:Stage = this._dragSource.stage;

			var listeners:Array = new Array(
				new Listener( this._dragSource, Event.REMOVED_FROM_STAGE, this.handler_fail ),
				new Listener( this._dragSource, Event.DEACTIVATE, this.handler_fail ),
				new Listener( stage, MouseEvent.MOUSE_MOVE, this.handler_mouseMove ),
				new Listener( stage, MouseEvent.MOUSE_UP, this.handler_mouseUp ),
				new Listener( stage, MouseEvent.MOUSE_OVER, this.handler_mouseOver ),
				new Listener( stage, MouseEvent.MOUSE_OUT, this.handler_mouseOut ),
				new Listener( stage, KeyboardEvent.KEY_UP, this.handler_keyUp )
			);

			for each ( var listener:Listener in listeners ) {
				listener.target.addEventListener( listener.type, listener.handler, false, int.MAX_VALUE );
				listener.target.addEventListener( listener.type, listener.handler, true, int.MAX_VALUE );
			}
			
			this._dropTarget = DisplayObjectUtils.getDropTarget(stage, new Point(stage.mouseX, stage.mouseY));
			stage.addChild( this._dragObject );
			this.dispatchDragEvent( DragEvent.DRAG_START );

		}

		/**
		 * @private
		 */
		private function clear():void {
			if (this._dragObject && this._dragObject.$parent) {
				this._dragObject.$parent.removeChild( this._dragObject );
			}

			if (this._dragSource && this._dragSource.stage) {

				var stage:Stage = this._dragSource.stage;

				var listeners:Array = new Array(
					new Listener( this._dragSource, Event.REMOVED_FROM_STAGE, this.handler_fail ),
					new Listener( this._dragSource, Event.DEACTIVATE, this.handler_fail ),
					new Listener( stage, MouseEvent.MOUSE_MOVE, this.handler_mouseMove ),
					new Listener( stage, MouseEvent.MOUSE_UP, this.handler_mouseUp ),
					new Listener( stage, MouseEvent.MOUSE_OVER, this.handler_mouseOver ),
					new Listener( stage, MouseEvent.MOUSE_OUT, this.handler_mouseOut ),
					new Listener( stage, KeyboardEvent.KEY_UP, this.handler_keyUp )
				);

				for each ( var listener:Listener in listeners ) {
					listener.target.removeEventListener( listener.type, listener.handler, false );
					listener.target.removeEventListener( listener.type, listener.handler, true );
				}

			}

			this._dragSource = null;
			this._dragObject = null;
			this._dropTarget = null;
		}

		/**
		 * @private
		 */
		private function dispatchDragEvent(type:String):void {
			var e:MouseEvent = this._lastMouseEvent;
			var offset:Point = ( this._dragObject ? this._dragObject.offset : null ) || new Point();
			super.dispatchEvent( new DragEvent(type, false, false, offset.x, offset.y, null, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta, this._dragSource, this._dragObject, this._dropTarget ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_fail(event:Event):void {
			( event.target as DisplayObject ).removeEventListener(Event.REMOVED_FROM_STAGE, this.handler_fail);
			if ( this._dragSource === event.target ) {
				this.clear();
				this.dispatchDragEvent( DragEvent.DRAG_FAIL );
			}
		}

		/**
		 * @private
		 */
		private function handler_mouseUp(event:MouseEvent):void {
			this._lastMouseEvent = event;
			this.dispatchDragEvent( DragEvent.DRAG_STOP );
			this.clear();
		}

		/**
		 * @private
		 */
		private function handler_mouseMove(event:MouseEvent):void {
			this._lastMouseEvent = event;
			this.dispatchDragEvent( DragEvent.DRAG_MOVE );
		}

		/**
		 * @private
		 */
		private function handler_keyUp(event:KeyboardEvent):void {
			if ( event.keyCode == Keyboard.ESCAPE ) {
				this.dispatchDragEvent( DragEvent.DRAG_FAIL );
				this.clear();
			}
		}

		/**
		 * @private
		 */
		private function handler_mouseOver(event:MouseEvent):void {
			this._dropTarget = event.target as DisplayObject;
		}

		/**
		 * @private
		 */
		private function handler_mouseOut(event:MouseEvent):void {
			this._dropTarget = null;
		}

	}

}

import flash.events.IEventDispatcher;

/**
 * @private
 */
internal final class Listener {

	public function Listener(target:IEventDispatcher, type:String, handler:Function) {
		super();
		this.target = target;
		this.type = type;
		this.handler = handler;
	}

	public var target:IEventDispatcher;

	public var type:String;

	public var handler:Function;

}