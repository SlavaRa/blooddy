package by.blooddy.platform.events {

	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import by.blooddy.platform.managers.DragObject;

	public class DragEvent extends MouseEvent {

		public static const DRAG_PREPARE:String = "dragPrepare";

		public static const DRAG_START:String = "dragStart";

		public static const DRAG_MOVE:String = "dragMove";

		public static const DRAG_STOP:String = "dragStop";

		public static const DRAG_FAIL:String = "dragFail";


		public function DragEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, localX:Number=0, localY:Number=0, relatedObject:InteractiveObject=null, ctrlKey:Boolean=false, altKey:Boolean=false, shiftKey:Boolean=false, buttonDown:Boolean=false, delta:int=0, dragSource:DisplayObject=null, dragObject:DragObject=null, dropTarget:DisplayObject = null) {
			super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
			this.dragObject = dragObject;
			this.dragSource = dragSource;
			this.dropTarget = dropTarget;
		}

		public var dragObject:DragObject;

		public var dragSource:DisplayObject;
		
		public var dropTarget:DisplayObject;

		public override function clone():Event {
			return new DragEvent( super.type, super.bubbles, super.cancelable, super.localX, super.localY, super.relatedObject, super.ctrlKey, super.altKey, super.shiftKey, super.buttonDown, super.delta, this.dragSource, this.dragObject, this.dropTarget );
		}

	}

}