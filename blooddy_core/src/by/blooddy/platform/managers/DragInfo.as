////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.managers {

	import by.blooddy.platform.events.DragEvent;
	import by.blooddy.platform.utils.getCallerInfo;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;

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

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

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

		public function DragInfo() {
			super();
			var info:XML = getCallerInfo();
			if ( info.localName() != "method" && info.@name != getQualifiedClassName(DragManager)+"$cinit" ) throw new ArgumentError();
		}

		private var _lastMouseEvent:MouseEvent;

		private var _dropTarget:DisplayObject;

		public function get dropTarget():DisplayObject {
			return this._dropTarget;
		}

		private var _dragSource:DisplayObject;

		public function get dragSource():DisplayObject {
			return this._dragSource;
		}

		private var _dragObject:DragObject;

		public function get dragObject():DragObject {
			return this._dragObject;
		}

		internal function $doDrag(dragSource:DisplayObject, rescale:Boolean=false, offset:Point=null, bounds:Rectangle=null):void {
			if (!dragSource.stage) throw new ArgumentError();

			this._dragSource = dragSource;

			if (!offset) offset = new Point( -this._dragSource.mouseX, -this._dragSource.mouseY );

			this._dragObject = new DragObject( this._dragSource, rescale, offset, bounds );

			offset = this._dragObject.offset;

			this._lastMouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, offset.x, offset.y, null, false, false, false, true, 0);

			var stage:Stage = this._dragSource.stage;

			stage.addChild( this._dragObject );

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

			this.dispatchDragEvent( DragEvent.DRAG_START );

		}

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
		}

		private function dispatchDragEvent(type:String):void {
			var e:MouseEvent = this._lastMouseEvent;
			var offset:Point = ( this._dragObject ? this._dragObject.offset : null ) || new Point();
			super.dispatchEvent( new DragEvent(type, false, false, offset.x, offset.y, null, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta, this._dragSource, this._dragObject, this._dropTarget ) );
		}

		private function handler_fail(event:Event):void {
			( event.target as DisplayObject ).removeEventListener(Event.REMOVED_FROM_STAGE, this.handler_fail);
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

		private function handler_mouseOver(event:MouseEvent):void {
			this._dropTarget = event.target as DisplayObject;
		}

		private function handler_mouseOut(event:MouseEvent):void {
			this._dropTarget = null;
		}

	}

}

import flash.events.IEventDispatcher;

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