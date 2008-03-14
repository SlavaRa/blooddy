package platform.external {

	import flash.errors.IllegalOperationError;

	import flash.external.ExternalInterface;

	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	import flash.net.URLRequest;

	public final class BrowserWindow {

		/**
		 * Gets the location, of the window object.
		 */
		public static function get location():BrowserWindowLocation {
			return BrowserWindowLocation.instance;
		}

		/**
		 * Returns a reference to the history object.
		 */
		public static function get history():BrowserWindowHistory {
			return BrowserWindowHistory.instance;
		}

		/**
		 * Gets/sets the name of the window.
		 */
		public static function get name():String {
			return getExternalProperty("window.name");
		}

		/**
		 * @private
		 */
		public static function set name(value:String):void {
			setExternalProperty("window.name", value)
		}

		/**
		 * Gets/sets the text in the statusbar at the bottom of the browser.
		 */
		public static function get status():String {
			return getExternalProperty("window.status");
		}

		/**
		 * @private
		 */
		public static function set status(value:String):void {
			setExternalProperty("window.status", value)
		}

		/**
		 * Displays an alert dialog.
		 */
		public static function alert(value:String):void {
			callExternalMethod("alert", value);
		}

		/**
		 * Closes the current window.
		 */
		public static function close():void {
			callExternalMethod("close");
		}

		/**
		 * Opens the Print Dialog to print the current document.
		 */
		public static function print():void {
			callExternalMethod("print");
		}

	}

}