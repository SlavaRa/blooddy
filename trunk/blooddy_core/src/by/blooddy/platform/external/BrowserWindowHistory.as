package platform.external {

	public final class BrowserWindowHistory {

		/**
		 * @private
		 */
		internal static const instance:BrowserWindowHistory = new BrowserWindowHistory();

		/**
		 * @private
		 */
		private static var _inited:Boolean = false;

		/**
		 * @private
		 */
		public function BrowserWindowHistory() {
			super();
			if (_inited) throw new ArgumentError();
			_inited = true;
		}

		/**
		 * Retrieves the number of elements in the History list.
		 */
		public function get length():String {
			return getExternalProperty("window.history.length");
		}

		/**
		 * TODO: current, next, previous
		 */

		/**
		 * Loads a previous URL from the History list.
		 */
		public function back():void {
			callExternalMethod("window.history.back");
		}

		/**
		 * Loads the next URL from the History list.
		 */
		public function forward():void {
			callExternalMethod("window.history.forward");
		}

		/**
		 * Loads a URL from the History list.
		 * 
		 * @param	url			
		 */
		public function go(location:String):void {
			callExternalMethod("window.history.go", location);
		}

	}

}