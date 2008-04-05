////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.net {

	import by.blooddy.platform.errors.ErrorsManager;
	import flash.errors.IllegalOperationError;

	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;

	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	import flash.system.ApplicationDomain;
	import flash.system.SecurityDomain;
	import flash.system.LoaderContext;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.display.DisplayObject;

	import by.blooddy.platform.utils.ClassUtils;

	import flash.events.EventDispatcher;

	//--------------------------------------
	//  Implements events: ILoadable
	//--------------------------------------

	/**
	 * @copy					platform.net.ILoadable#complete
	 */
	[Event(name="complete", type="flash.events.Event")]

	/**
	 * @copy					platform.net.ILoadable#ioError
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")]

	/**
	 * @copy					platform.net.ILoadable#open
	 */
	[Event(name="open", type="flash.events.Event")]

	/**
	 * @copy					platform.net.ILoadable#progress
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")]

	//--------------------------------------
	//  Implements events: ILoader
	//--------------------------------------

	/**
	 * @copy					platform.net.ILoader#httpStatus
	 */
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]

	/**
	 * @copy					platform.net.ILoader#securityError
	 */
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Флаха инициализировалась.
	 * 
	 * @eventType			flash.events.Event.INIT
	 */
	[Event(name="init", type="flash.events.Event")]

	/**
	 * Выгрузилось всё нафик.
	 * 
	 * @eventType			flash.events.Event.UNLOAD
	 */
	[Event(name="unload", type="flash.events.Event")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					loader
	 * 
	 * @see						flash.display.Loader
	 */
	public class Loader extends EventDispatcher implements ILoader {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 * Constructor.
		 *
		 * @param	request			Если надо, то сразу передадим и начнётся загрузка.
		 * @param	loaderContext	Если надо грузить, то возможно пригодится.
		 */
		public function Loader(request:URLRequest=null, loaderContext:LoaderContext=null) {
			super();
			var li:LoaderInfo = this._loader.contentLoaderInfo;
			li.addEventListener(Event.OPEN,							this.handler_open);
			li.addEventListener(ProgressEvent.PROGRESS,				this.handler_progress);
			li.addEventListener(HTTPStatusEvent.HTTP_STATUS,		this.handler_httpStatus);
			li.addEventListener(IOErrorEvent.IO_ERROR,				this.handler_ioError);
			li.addEventListener(SecurityErrorEvent.SECURITY_ERROR,	this.handler_securityError);
			li.addEventListener(Event.COMPLETE,						this.handler_complete);
			li.addEventListener(Event.INIT,							this.handler_init);
			li.addEventListener(Event.UNLOAD,						this.handler_unload);
			this._loaderContext = loaderContext;
			if (request) this.$load(request);
		}

		//--------------------------------------------------------------------------
		//
		//  Variblies
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _closed:Boolean = false;

		/**
		 * @private
		 */
		private const _loader:flash.display.Loader = new flash.display.Loader();

		/**
		 * @private
		 */
		private var _request:URLRequest;

		/**
		 * @private
		 */
		private var _attemptingChildAppDomain:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoadable
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  bytesLoaded
		//----------------------------------

	    [Bindable("progress")]
		/**
		 * @copy					platform.net.ILoadable#bytesLoaded
		 */
		public function get bytesLoaded():uint {
			return this.loaderInfo.bytesLoaded;
		}

		//----------------------------------
		//  bytesTotal
		//----------------------------------

	    [Bindable("complete")]
		/**
		 * @copy					platform.net.ILoadable#bytesTotal
		 */
		public function get bytesTotal():uint {
			return this.loaderInfo.bytesTotal;
		}

		//----------------------------------
		//  loaded
		//----------------------------------

		/**
		 * @private
		 */
		private var _loaded:Boolean = false;

	    [Bindable("complete")]
		/**
		 * @copy					platform.net.ILoadable#loaded
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

	    [Bindable("open")]
		/**
		 * @copy					platform.net.ILoader#url
		 */
		public function get url():String {
			return ( this._request ? this._request.url : this.loaderInfo.url );
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  loaderContext
		//----------------------------------

		/**
		 * @private
		 */
		private var _loaderContext:LoaderContext;

		/**
		 * A LoaderContext object to use to control loading of the content.
		 * This is an advanced property. 
		 * Most of the time you can use the trustContent property.
		 * 
		 * @default					null
		 * 
		 * @keyword					loader.loadercontext, loadercontext
		 * 
		 * @see						flash.system.LoaderContext
		 * @see						flash.system.ApplicationDomain
		 * @see						flash.system.SecurityDomain
		 */
		public function get loaderContext():LoaderContext {
			return this._loaderContext;
		}

		/**
		 * @private
		 */
		public function set loaderContext(value:LoaderContext):void {
			if (this._loaderContext === value) return;
			this._loaderContext = value;
		}

		//----------------------------------
		//  trustContent
		//----------------------------------

		/**
		 * @private
		 */
		private var _trustContent:Boolean = false;

		/**
		 * If true, the content is loaded into your security domain.
		 * This means that the load fails if the content is in another domain
		 * and that domain does not have a crossdomain.xml file allowing your
		 * domain to access it. 
		 * This property only has an affect on the next load,
		 * it will not start a new load on already loaded content.
		 *
		 * @default 				false
		 * 
		 * @keyword					loader.trustcontent, trustcontent
		 * 
		 * @see						flash.system.SecurityDomain
		 * @see						flash.system.ApplicationDomain
		 */
	 	public function get trustContent():Boolean {
			return this._trustContent;
		}

		/**
		 * @private
		 */
		public function set trustContent(value:Boolean):void {
			if (this._trustContent == value) return;
			this._trustContent = value;
		}

		//----------------------------------
		//  content
		//----------------------------------

	    [Bindable("complete")]
		/**
		 * @copy					flash.display.Loader#content
		 */
		public function get content():DisplayObject {
			return this._loader.content;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy					flash.display.Loader#contentLoaderInfo
		 */
		protected final function get loaderInfo():LoaderInfo {
			return this._loader.contentLoaderInfo;
		}

		//--------------------------------------------------------------------------
		//
		//  Overiden methods: EventDispatcher
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function dispatchEvent(event:Event):Boolean {
			throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: ILoader
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy					platform.net.ILoader#load()
		 */
		public function load(request:URLRequest):void {
			this.$load(request);
		}

		/**
		 * @copy					platform.net.ILoader#close()
		 */
		public function close():void {
			this.$close();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy					flash.display.Loader#loadBytes()
		 */
		public function loadBytes(bytes:ByteArray):void {
			this.clearVariables();
			this._loader.loadBytes(bytes, this._loaderContext);
		}

		/**
		 * @copy					flash.display.Loader#unload()
		 */
		public function unload():void {
			this._closed = true;
			this._loader.unload();
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return "[" + ClassUtils.getClassName(this) + " url="+this.url + "]";
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 */
		protected function $dispatchEvent(event:Event):Boolean {
			return super.dispatchEvent(event);
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
			this._request = request;
			if (!this._loaderContext) {
				this._loaderContext = new LoaderContext();
				if (this._trustContent) {
					this._loaderContext.securityDomain = SecurityDomain.currentDomain;
				} else {
					this._attemptingChildAppDomain = true;
					// assume the best, which is that it is in the same domain and
					// we can make it a child app domain.
					this._loaderContext.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
				}
			}

			this._loader.load(this._request, this._loaderContext);
		}

		/**
		 * @private
		 */
		private function $close():void {
			this._closed = true;
			this._loader.close();
		}

		/**
		 * @private
		 * Чистит переменные
		 */
		private function clearVariables():void {
			try {
				this.$close();
			} catch (e:Error) {
			}
			this._closed = false;
			this._loaded = false;
			this._attemptingChildAppDomain = false;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 */
		protected function handler_open(event:Event):void {
			super.dispatchEvent(event);
		}

		/**
		 */
		protected function handler_progress(event:ProgressEvent):void {
			super.dispatchEvent(event);
		}

		/**
		 */
		protected function handler_httpStatus(event:HTTPStatusEvent):void {
			super.dispatchEvent(event);
		}

		/**
		 */
		protected function handler_ioError(event:IOErrorEvent):void {
			// Перенапрвляем, только если есть листенер
			// иначе возникает ошибка.
			if (super.hasEventListener(event.type)) super.dispatchEvent(event);
			this.clearVariables(); // очищаем переменные
			this._closed = true;
		}

		/**
		 */
		protected function handler_securityError(event:SecurityErrorEvent):void {
			// надо попытаться ещё раз
			if (this._attemptingChildAppDomain) {
				this._attemptingChildAppDomain = false;
				this._loader.load(this._request);
			} else {
				super.dispatchEvent(event);
				this.clearVariables();
				this._closed = true;
			}
		}

		/**
		 */
		protected function handler_complete(event:Event):void {
			if (!this._closed) {
				this._loaded = true;
				super.dispatchEvent(event);
			}
		}

		/**
		 */
		protected function handler_init(event:Event):void {
			super.dispatchEvent(event);
		}

		/**
		 */
		protected function handler_unload(event:Event):void {
			super.dispatchEvent(event);
			this.clearVariables();
		}

	}

}