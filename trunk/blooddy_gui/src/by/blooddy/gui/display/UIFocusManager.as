package by.blooddy.gui.display {

	import by.blooddy.gui.managers.IFocusManager;
	import by.blooddy.gui.managers.FocusManager;

	[AbstractClass]
	public class UIFocusManager extends UIFocusElement implements IFocusManager {

		public function UIFocusManager() {
			super();
			this._focusManager = FocusManager.getFocusManager( this );
		}

		private var _focusManager:FocusManager;

	}

}