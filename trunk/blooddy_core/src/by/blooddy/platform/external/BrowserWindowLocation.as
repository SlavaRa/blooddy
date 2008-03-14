package platform.external {

	import flash.external.ExternalInterface;
	import flash.net.URLVariables;
	import platform.external.callExternalMethod;

	public final class BrowserWindowLocation {

		/**
		 * @private
		 */
		internal static const instance:BrowserWindowLocation = new BrowserWindowLocation();

		/**
		 * @private
		 */
		private static var _inited:Boolean = false;

		/**
		 * @private
		 */
		public function BrowserWindowLocation() {
			super();
			if (_inited) throw new ArgumentError();
			_inited = true;
		}

		/**
		 * the part of the URL that follows the # symbol.
		 * 
		 * @example			#test
		 */
		public function get hash():String {
			return getExternalProperty("window.location.hash");
		}

		/**
		 * the host name and port number.
		 * 
		 * @example			www.google.com:80
		 */
		public function get host():String {
			return getExternalProperty("window.location.host");
		}

		/**
		 * the host name (without the port number).
		 * 
		 * @example			www.google.com
		 */
		public function get hostname():String {
			return getExternalProperty("window.location.hostname");
		}

		/**
		 * the entire URL.
		 * 
		 * @example			http://www.google.com:80/search?q=devmo#test
		 */
		public function get href():String {
			return getExternalProperty("window.location.href");
		}

		/**
		 * the path (relative to the host).
		 * 
		 * @example			/search
		 */
		public function get pathname():String {
			return getExternalProperty("window.location.pathname");
		}

		/**
		 * the port number of the URL.
		 * 
		 * @example			80
		 */
		public function get port():String {
			return getExternalProperty("window.location.port");
		}

		/**
		 * the protocol of the URL.'
		 * 
		 * @example			http:
		 */
		public function get protocol():String {
			return getExternalProperty("window.location.protocol");
		}

		/**
		 * the part of the URL that follows the ? symbol, including the ? symbol.
		 * 
		 * @example			
		 */
		public function get search():String {
			return getExternalProperty("window.location.search");
		}

		public function get variables():URLVariables {
			return new URLVariables( this.search );
		}

		/**
		 * Load the document at the provided URL.
		 * 
		 * @param	url			
		 */
		public function assign(url:String):void {
			callExternalMethod("window.location.assign", url);
		}

		/**
		 * Reload the document from the current URL.
		 * 
		 * @param	forceget	when it is true, causes the page to always be reloaded from the server. If it is false or not specified, the browser may reload the page from its cache.
		 */
		public function reload(forceget:Boolean=false):void {
			callExternalMethod("window.location.reload", forceget);
		}

		/**
		 * Replace the current document with the one at the provided URL. The difference from the assign() method is that after using replace() the current page will not be saved in session history, meaning the user won't be able to use the Back button to navigate to it.
		 * 
		 * @param	url			
		 */
		public function replace(url:String):void {
			callExternalMethod("window.location.replace", url);
		}

		/**
		 * @private
		 */
		public function toString():String {
			return ( ExternalInterface.available ? this.href : this.toLocaleString() );
		}

		/**
		 * @private
		 */
		public function toLocaleString():String {
			return Object.prototype.toLocaleString.call(this);
		}

	}

}