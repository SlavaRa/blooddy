package by.blooddy.gui.display {

	import by.blooddy.gui.managers.IFocusElement;
	import by.blooddy.gui.managers.IFocusManager;
	import by.blooddy.gui.managers.FocusManager;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;

	[AbstractControl]
	public class UIFocusElement extends UIControl implements IFocusElement {

		public function UIFocusElement() {
			super();
			super.addEventListener(Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MAX_VALUE);
			super.addEventListener(Event.REMOVED_FROM_STAGE, this.handler_removedFromStage, false, int.MAX_VALUE);
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

	}

}