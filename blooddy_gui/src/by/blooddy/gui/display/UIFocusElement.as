package by.blooddy.gui.display {

	import by.blooddy.gui.managers.IFocusElement;
	import by.blooddy.gui.managers.IFocusManager;
	import by.blooddy.gui.managers.FocusManager;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import by.blooddy.platform.events.DragEvent;
	import by.blooddy.platform.managers.DragManager;
	import by.blooddy.platform.events.DragEvent;

	[AbstractControl]
	public class UIFocusElement extends UIControl implements IUIFocusElement {

		public function UIFocusElement() {
			super();
			super.addEventListener(Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MAX_VALUE);
			super.addEventListener(Event.REMOVED_FROM_STAGE, this.handler_removedFromStage, false, int.MAX_VALUE);

			// зарание назначим события мышки, чтобы перехватывать их во время драга
			super.addEventListener(MouseEvent.MOUSE_DOWN, this.handler_mouseDown, false, int.MAX_VALUE);
			super.addEventListener(MouseEvent.MOUSE_MOVE, this.handler_mouseMove, false, int.MAX_VALUE);
			super.addEventListener(MouseEvent.CLICK, this.handler_mouseUp, false, int.MAX_VALUE);
			super.addEventListener(MouseEvent.MOUSE_UP, this.handler_mouseUp, false, int.MAX_VALUE);
			super.addEventListener(MouseEvent.DOUBLE_CLICK, this.handler_mouseUp, false, int.MAX_VALUE);

			super.addEventListener(MouseEvent.MOUSE_DOWN, this.handler_mouseDown, true, int.MAX_VALUE);
			super.addEventListener(MouseEvent.MOUSE_MOVE, this.handler_mouseMove, true, int.MAX_VALUE);
			super.addEventListener(MouseEvent.CLICK, this.handler_mouseUp, true, int.MAX_VALUE);
			super.addEventListener(MouseEvent.MOUSE_UP, this.handler_mouseUp, true, int.MAX_VALUE);
			super.addEventListener(MouseEvent.DOUBLE_CLICK, this.handler_mouseUp, true, int.MAX_VALUE);
		}

		private var _enabled:Boolean = true;

		public function get enabled():Boolean {
			return this._enabled;
		}

		public function set enabled(value:Boolean):void {
			this._enabled = false;
		}

		private var _focusManager:IFocusManager;

		public function get focusManager():IFocusManager {
			return null;
		}

	    //--------------------------------------
	    //  drag declaration
	    //--------------------------------------	

		/**
		 * @private
		 */
		private var _dragble:Boolean = false;

		[Inspectable(category="Position", enumeration="true,false", defaultValue="false")]
		/**
		 */
		public function get dragble():Boolean {
			return this._dragble;
		}

		/**
		 * @private
		 */
		public function set dragble(value:Boolean):void {
			if ( this._dragble == value) return;
			this._dragble = value;
			if (this._dragble) {
				// TODO: зафигачить афигенный драг
			} else {
			}
		}

		private function handler_addedToStage(event:Event):void {
			// найдём наш фокус манагер
			var parent:DisplayObjectContainer = super.parent;
			while ( parent && !( parent is IFocusManager ) ) parent = parent.parent;
			if (parent)	this._focusManager = parent as IFocusManager;
			else		this._focusManager = FocusManager.getFocusManager( super.stage ); // используем глобальный манагер
		}

		private function handler_removedFromStage(event:Event):void {
			this._focusManager = null;
		}

	    //--------------------------------------
	    //  mouse events declaration
	    //--------------------------------------	

		private var _dragPhase:uint = DragPhase.DRAG_WAIT;

		private function handler_mouseDown(event:MouseEvent):void {
			if ( this._dragble ) { // мы можем драгаться. надо прекратить распостранение события
				this._dragPhase = DragPhase.DRAG_PREPARE;
			}
		}

		private function handler_mouseUp(event:MouseEvent):void {
			if ( this._dragble && this._dragPhase == DragPhase.DRAG_PREPARE ) {
				this._dragPhase = DragPhase.DRAG_WAIT;
			} else {
				event.stopImmediatePropagation();
			}
		}

		private function handler_mouseMove(event:MouseEvent):void {
			if (this._dragble && this._dragPhase == DragPhase.DRAG_PREPARE ) {
				var result:Boolean = super.$dispatchEvent( new DragEvent(DragEvent.DRAG_PREPARE, false, true, event.localX, event.localY, event.relatedObject, event.ctrlKey, event.altKey, event.shiftKey, event.buttonDown, event.delta, this ) );
				if (result) {
					this._dragPhase = DragPhase.DRAG_EVENT;
					DragManager.dragInfo.addEventListener(DragEvent.DRAG_START, this.handler_dragRedirect);
					DragManager.dragInfo.addEventListener(DragEvent.DRAG_MOVE, this.handler_dragRedirect);
					DragManager.dragInfo.addEventListener(DragEvent.DRAG_STOP, this.handler_dragStop);
					DragManager.dragInfo.addEventListener(DragEvent.DRAG_FAIL, this.handler_dragStop);
					DragManager.doDrag( this );
				} else {
					this._dragPhase = DragPhase.DRAG_WAIT;
				}
			}
		}

	    //--------------------------------------
	    //  drag events declaration
	    //--------------------------------------

		private function handler_dragRedirect(event:DragEvent):void {
			if ( event.dragSource === this ) {
				super.$dispatchEvent( event );
			}
		}

		private function handler_dragStop(event:DragEvent):void {
			if ( event.dragSource === this ) {
				this._dragPhase = DragPhase.DRAG_WAIT;
				DragManager.dragInfo.removeEventListener(DragEvent.DRAG_START, this.handler_dragRedirect);
				DragManager.dragInfo.removeEventListener(DragEvent.DRAG_MOVE, this.handler_dragRedirect);
				DragManager.dragInfo.removeEventListener(DragEvent.DRAG_STOP, this.handler_dragRedirect);
				DragManager.dragInfo.removeEventListener(DragEvent.DRAG_FAIL, this.handler_dragRedirect);
				super.$dispatchEvent( event );
			}
		}

	}

}

internal final class DragPhase {

	public static const DRAG_WAIT:uint = 0;

	public static const DRAG_PREPARE:uint = 1;

	public static const DRAG_EVENT:uint = 2;

}