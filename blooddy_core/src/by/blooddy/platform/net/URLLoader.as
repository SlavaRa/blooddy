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

	import flash.net.URLLoader;

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
		 * Constructor.
		 * 
		 * @param	request			Если надо, то сразу передадим и начнётся загрузка.
		 */
		public function URLLoader(request:URLRequest=null) {
			super();
			this._loader.addEventListener(Event.OPEN,							this.handler_open);
			this._loader.addEventListener(ProgressEvent.PROGRESS,				this.handler_progress);
			this._loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,			this.handler_httpStatus);
			this._loader.addEventListener(IOErrorEvent.IO_ERROR,				this.handler_ioError);
			this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,	this.handler_securityError);
			this._loader.addEventListener(Event.COMPLETE,						this.handler_complete);
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
		private const _loader:flash.net.URLLoader = new flash.net.URLLoader();

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
			return this._loader.bytesLoaded;
		}

		//----------------------------------
		//  bytesTotal
		//----------------------------------

	    [Bindable("complete")]
		/**
		 * @copy					platform.net.ILoadable#bytesTotal
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

		/**
		 * @private
		 */
		private var _url:String = null;

	    [Bindable("open")]
		/**
		 * @copy					platform.net.ILoader#url
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

	    [Bindable("complete")]
		/**
		 * @copy			flash.net.URLLoader#data
		 */
		public function get data():* {
			return this._loader.data;
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
		 * @copy					platform.net.ILoader#load
		 */
		public function load(request:URLRequest):void {
			this.$load(request);
		}

		/**
		 * @copy					platform.net.ILoader#close
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
			this._url = request.url;
			this._loader.load(request);
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
			} catch (e:Error) {
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
		}

		/**
		 */
		protected function handler_securityError(event:SecurityErrorEvent):void {
			// Перенапрвляем, только если есть листенер
			// иначе возникает ошибка.
			if (super.hasEventListener(event.type)) super.dispatchEvent(event);
			this.clearVariables(); // очищаем переменные
		}

		/**
		 */
		protected function handler_complete(event:Event):void {
			this._loaded = true;
			super.dispatchEvent(event);
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