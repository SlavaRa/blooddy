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

	import flash.display.LoaderInfo;

	import flash.events.EventDispatcher;

	//--------------------------------------
	//  Implements events: ILoadable
	//--------------------------------------

	/**
	 * @copy					platform.net.ILoadable#complete
	 */
	[Event(name="complete", type="flash.events.Event")]

	/**
	 * @copy					platform.net.ILoadable#progress
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")]

	/**
	 * Класс предназначен для мониторинга процесса загрузки
	 * нескольких файлов одновременно.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					loaderdispatcher, loader, dispatcher
	 */
	public class LoaderDispatcher extends EventDispatcher implements ILoaderDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 * Constructor.
		 *
		 * @param	enabled			Включать ли по умолчанию лоадер.
		 *
		 * @see						#enabled
		 */
		public function LoaderDispatcher(enabled:Boolean=true) {
			super();
			this._enabled = enabled;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _loaders:Array = new Array();

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoadable
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  loaded
		//----------------------------------

	    [Bindable("complete")]
		/**
		 * @copy					platform.net.ILoadable#loaded
		 */
		public function get loaded():Boolean {
			return this.$loaded;
		}

		/**
		 * @private
		 */
		private function get $loaded():Boolean {
			for each (var loader:ILoadable in this._loaders) {
				if (!loader.loaded) return false;
			}
			return true;
		}

		//----------------------------------
		//  bytesLoaded
		//----------------------------------

	    [Bindable("progress")]
		/**
		 * @copy					platform.net.ILoadable#bytesLoaded
		 */
		public function get bytesLoaded():uint {
			return this.$bytesLoaded;
		}

		/**
		 * @private
		 */
		private function get $bytesLoaded():uint {
			var loaded:uint = 0;
			for each (var loader:ILoadable in this._loaders) {
				loaded += ( loader.bytesTotal ? loader.bytesLoaded : 0 );
			}
			return loaded;
		}

		//----------------------------------
		//  bytesTotal
		//----------------------------------

	    [Bindable("complete")]
		/**
		 * @copy					platform.net.ILoadable#bytesTotal
		 */
		public function get bytesTotal():uint {
			return this.$bytesTotal;
		}

		/**
		 * @private
		 */
		private function get $bytesTotal():uint {
			var loaded:uint = 0;
			for each (var loader:ILoadable in this._loaders) {
				loaded += loader.bytesTotal || 0;
			}
			return loaded;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoaderDispatcher
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  enabled
		//----------------------------------

		/**
		 * @private
		 */
		private var _enabled:Boolean = true;

		[Inspectable( type="Boolean", defaultValue="true" )]
		/**
		 * @copy					platform.net.ILoaderDispatcher#enabled
		 */
		public function get enabled():Boolean {
			return this._enabled;
		}

		/**
		 * @private
		 */
		public function set enabled(value:Boolean):void {
			if (this._enabled == value) return;
			this._enabled = value;
			if (!this._enabled) return;
			if (this.$loaded) {
				this.dispatchCompleteEvent();
			} else {
				this.dispatchProgressEvent();
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: EventDispatcher
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
		//  Implements methods: ILoaderDispatcher
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy					platform.net.ILoaderDispatcher#addLoaderListener()
		 */
		public function addLoaderListener(loader:ILoadable):void {
			this.$addLoaderListener(loader);
		}

		/**
		 * @copy					platform.net.ILoaderDispatcher#removeLoaderListener()
		 */
		public function removeLoaderListener(loader:ILoadable):void {
			this.$removeLoaderListener(loader);
		}

		/**
		 * @copy					platform.net.ILoaderDispatcher#hasLoaderListener()
		 */
		public function hasLoaderListener(loader:ILoadable):Boolean {
			return this.$hasLoaderListener(loader);
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function $addLoaderListener(loader:ILoadable):void {
			if (this.$hasLoaderListener(loader)) return; // проверим. может какой-то баран уже дабавил нас сюда.

			if (!loader.loaded) {
				loader.addEventListener(Event.COMPLETE,						this.handler_complete);
				loader.addEventListener(ProgressEvent.PROGRESS,				this.handler_progress);
				loader.addEventListener(IOErrorEvent.IO_ERROR,				this.handler_error);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,	this.handler_error);
			}

			this._loaders.push( loader );

			if (this._enabled && loader.bytesTotal>0) {
				this.dispatchProgressEvent();
				if (this.$loaded) this.dispatchCompleteEvent();
			}
		}

		/**
		 * @private
		 */
		private function $removeLoaderListener(loader:ILoadable):void {
			loader.removeEventListener(Event.COMPLETE,						this.handler_complete);
			loader.removeEventListener(ProgressEvent.PROGRESS,				this.handler_progress);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,	this.handler_error);
			loader.removeEventListener(IOErrorEvent.IO_ERROR,				this.handler_error);

			var index:int = this._loaders.indexOf(loader);
			if (index<0) return; // надо удалить, если такой присутвует...

			this._loaders.splice(index, 1);

			if (this._enabled && loader.bytesTotal>0) {
				this.dispatchProgressEvent();
				if (this.$loaded) this.dispatchCompleteEvent();
			}
		}

		/**
		 * @private
		 */
		private function $hasLoaderListener(loader:ILoadable):Boolean {
			return ( this._loaders.indexOf(loader)>=0 );
		}

		/**
		 * @private
		 */
		private function dispatchCompleteEvent():Boolean {
			if (!this._enabled) return false;
			// загрузилось всё. чистимся и вызываемся.
			for each (var loader:ILoadable in this._loaders) {
				this.$removeLoaderListener(loader);
			}
			return super.dispatchEvent( new Event(Event.COMPLETE) );
		}

		/**
		 * @private
		 */
		private function dispatchProgressEvent():Boolean {
			if (!this._enabled) return false;
			else return super.dispatchEvent( new ProgressEvent(ProgressEvent.PROGRESS, false, false, this.$bytesLoaded, this.$bytesTotal) );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			// проверим всё ли загрузилось
			this.dispatchProgressEvent();
			if (this.$loaded) this.dispatchCompleteEvent();
		}

		/**
		 * @private
		 */
		private function handler_progress(event:ProgressEvent):void {
			this.dispatchProgressEvent();
		}

		/**
		 * @private
		 */
		private function handler_error(event:Event):void {
			this.$removeLoaderListener( event.target as ILoadable );
			this.dispatchProgressEvent();
			if (this.$loaded) this.dispatchCompleteEvent();
		}

	}

}