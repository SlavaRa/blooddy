package by.blooddy.gui.display {

	import by.blooddy.gui.managers.IFocusManager;
	import by.blooddy.gui.managers.FocusManager;

	public class UIFocusManager extends UIFocusElement implements IFocusManager {

		public function UIFocusManager() {
			super();
			if ( ( this as Object ).constructor === UIFocusManager ) throw new ArgumentError();
			this._focusManager = FocusManager.getFocusManager( this );
		}

		private var _focusManager:FocusManager;

	}

}