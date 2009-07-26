////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers {

	import flash.system.Capabilities;
	
	import flash.external.ExternalInterface;

	/**
	 * Интерфейс FocusManager.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					cookiemanager, cookie, manager
	 */
	public class CookieManager {

		//--------------------------------------------------------------------------
		//
		//  Class properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  available
		//----------------------------------

		public static function get available():Boolean {
			switch (Capabilities.playerType) {
				case "ActiveX": case "PlugIn": case "Desktop":	break;			// всё ок
				default:										return false;	// не там открыли
			}
			if (!ExternalInterface.available) return false;
			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function CookieManager(defaultTime:uint=0, path:String="/", domain:String=null, secure:Boolean=false) {
			super();
			this._defaultTime = defaultTime;
			this._path = path;
			this._domain = domain;
			this._secure = secure;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  available
		//----------------------------------

		/**
		 * @private
		 */
		private var _defaultTime:uint;

		public function get defaultTime():uint {
			return this._defaultTime;
		}

		/**
		 * @private
		 */
		public function set defaultTime(value:uint):void {
			this._defaultTime = value;
		}

		//----------------------------------
		//  path
		//----------------------------------

		/**
		 * @private
		 */
		private var _path:String;

		public function get path():String {
			return this._path;
		}

		/**
		 * @private
		 */
		public function set path(value:String):void {
			if (this._path == value) return;
			this._path = value;
		}

		//----------------------------------
		//  domain
		//----------------------------------

		/**
		 * @private
		 */
		private var _domain:String;

		public function get domain():String {
			return this._domain;
		}

		/**
		 * @private
		 */
		public function set domain(value:String):void {
			if (this._domain == value) return;
			this._domain = value;
		}

		//----------------------------------
		//  secure
		//----------------------------------

		/**
		 * @private
		 */
		private var _secure:Boolean;

		public function get secure():Boolean {
			return this._secure;
		}

		/**
		 * @private
		 */
		public function set secure(value:Boolean):void {
			if (this._secure == value) return;
			this._secure = value;
		}		

		//----------------------------------
		//  enabled
		//----------------------------------

		public function get enabled():Boolean {
			if (!available) throw new Error();
			var result:* = ExternalInterface.call('function() { try { if ( typeof(navigator.cookieEnabled) != "undefined ) return navigator.cookieEnabled; else return null; } catch(e) {} }');
			if ( result is Boolean ) return result;
			else { // свойство navigator.cookieEnabled не поддерживается, установим и получим тестовую куку
				var name:String = "__AS3_TEST_COOKIE_NAME__";
				this.setCookie(name, 1);
				if (this.getCookie(name)) {
					this.deleteCookie(name);
					return true;
				}
			}
			return false;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  getCookie
		//----------------------------------

		/**
		 * 
		 * @param	name		имя куки.
		 * 
		 * @return				кука.
		 * 
		 * @throw	Error		нету возможности обращаться к кукам.
		 */
		public function getCookie(name:String):* {
			this.$getCookie(name);
		}

		/**
		 * @private
		 */
		private function $getCookie(name:String):* {
			if (!available) throw new Error();
			if (!name || name.length<=0) return null;
			var cookie:String = ( ExternalInterface.call('function() { try {  return document.cookie } catch(e) {} }') as String ) + ";";
			var match:Object = ( new RegExp("\\s*"+name+"=(?P<value>.*?);", "g") ).exec( cookie );
			return ( match && match.value ? match.value : null );
		}

		//----------------------------------
		//  setCookie
		//----------------------------------

		public function setCookie(name:String, value:Object, time:uint=0):void {
			this.$setCookie(name, value, time);
		}

		/**
		 * @private
		 */
		private function $setCookie(name:String, value:Object, time:uint=0):void {
			if (!available) throw new Error();
			if (!name) return;
			else {
				if (!value) value = "";
				var result:Array = new Array( name + "=" + escape(value.toString()) );
				time = uint(time) || this._defaultTime;
				if (time) {
					var d:Date = new Date();
					d.setTime( d.getTime() + time );
					result.push( "expires=" + d.toString() );
				}
				if (this.path) result.push( "path=" + this.path );
				if (this.domain) result.push( "domain=" + this.domain );
				if (this.secure) result.push( "secure" );
				ExternalInterface.call('function() { try {  document.cookie = "'+result.join("; ")+'" } catch(e) {} }');
			}
		}

		//----------------------------------
		//  deleteCookie
		//----------------------------------

		public function deleteCookie(name:String):void {
			this.$deleteCookie(name);
		}

		/**
		 * @private
		 */
		private function $deleteCookie(name:String):void {
			if ( this.$getCookie(name) ) {
				this.$setCookie(name, null, -( new Date() ).getTime());
			}
		}

	}

}