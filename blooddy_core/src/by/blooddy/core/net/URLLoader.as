////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.utils.ClassUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	//--------------------------------------
	//  Implements events: ILoadable
	//--------------------------------------

	/**
	 * @copy					by.blooddy.core.net.ILoadable#complete
	 */
	[Event(name="complete", type="flash.events.Event")]

	/**
	 * @copy					by.blooddy.core.net.ILoadable#ioError
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")]

	/**
	 * @copy					by.blooddy.core.net.ILoadable#open
	 */
	[Event(name="open", type="flash.events.Event")]

	/**
	 * @copy					by.blooddy.core.net.ILoadable#progress
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")]

	//--------------------------------------
	//  Implements events: ILoader
	//--------------------------------------

	/**
	 * @copy					by.blooddy.core.net.ILoader#httpStatus
	 */
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]

	/**
	 * @copy					by.blooddy.core.net.ILoader#securityError
	 */
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					urlloader
	 */
	public class URLLoader extends EventDispatcher implements ILoader {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	request			Если надо, то сразу передадим и начнётся загрузка.
		 */
		public function URLLoader(request:URLRequest=null) {
			super();
			// FIXME: надо убить лоадер после загрузки
			this._loader.addEventListener( Event.OPEN,							super.dispatchEvent );
			this._loader.addEventListener( ProgressEvent.PROGRESS,				super.dispatchEvent );
			this._loader.addEventListener( HTTPStatusEvent.HTTP_STATUS,			super.dispatchEvent );
			this._loader.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
			this._loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
			this._loader.addEventListener( Event.COMPLETE,						this.handler_complete );
			if ( request ) this.$load( request );
		}

		//--------------------------------------------------------------------------
		//
		//  Includes
		//
		//--------------------------------------------------------------------------

		include "../../../../includes/override_EventDispatcher.as"

		//--------------------------------------------------------------------------
		//
		//  Variblies
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _loader:flash.net.URLLoader = new flash.net.URLLoader();

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoadable
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  bytesLoaded
		//----------------------------------

		/**
		 * @copy					by.blooddy.core.net.ILoadable#bytesLoaded
		 */
		public function get bytesLoaded():uint {
			return this._loader.bytesLoaded;
		}

		//----------------------------------
		//  bytesTotal
		//----------------------------------

		/**
		 * @copy					by.blooddy.core.net.ILoadable#bytesTotal
		 */
		public function get bytesTotal():uint {
			return this._loader.bytesTotal;
		}

		//----------------------------------
		//  loaded
		//----------------------------------

		/**
		 * @private
		 */
		private var _loaded:Boolean = false;

		/**
		 * @copy					by.blooddy.core.net.ILoadable#loaded
		 */
		public function get loaded():Boolean {
			return this._loaded;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoader
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  url
		//----------------------------------

		/**
		 * @private
		 */
		private var _url:String = null;

	    [Bindable("open")]
		/**
		 * @copy					by.blooddy.core.net.ILoader#url
		 */
		public function get url():String {
			return this._url;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  dataFormat
		//----------------------------------

		/**
		 * @copy			flash.net.URLLoader#dataFormat
		 */
		public function get dataFormat():String {
			return this._loader.dataFormat;
		}

		/**
		 * @private
		 */
		public function set dataFormat(value:String):void {
			this._loader.dataFormat = value;
		}

		//----------------------------------
		//  data
		//----------------------------------

		/**
		 * @copy			flash.net.URLLoader#data
		 */
		public function get data():* {
			return this._loader.data;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: ILoader
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy					by.blooddy.core.net.ILoader#load
		 */
		public function load(request:URLRequest):void {
			this.$load( request );
		}

		/**
		 * @copy					by.blooddy.core.net.ILoader#close
		 */
		public function close():void {
			this._loader.close();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function toString():String {
			return '[' + ClassUtils.getClassName( this ) + ' url="'+this.url + '"]';
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function $load(request:URLRequest):void {
			this.clearVariables();
			this._url = request.url;
			this._loader.load( request );
		}

		/**
		 * @private
		 */
		private function $close():void {
			this._loader.close();
		}

		/**
		 * @private
		 * Чистим переменные.
		 */
		private function clearVariables():void {
			try {
				this.$close();
			} catch ( e:Error ) {
			}
			this._url = null;
			this._loaded = false;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_error(event:IOErrorEvent):void {
			// Перенапрвляем, только если есть листенер
			// иначе возникает ошибка.
			if ( super.hasEventListener( event.type ) ) super.dispatchEvent( event );
			this.clearVariables(); // очищаем переменные
		}

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			this._loaded = true;
			super.dispatchEvent( event );
		}

	}

}