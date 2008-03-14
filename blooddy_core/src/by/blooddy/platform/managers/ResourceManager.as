////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.managers {

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import by.blooddy.platform.events.ResourceEvent;

	import by.blooddy.platform.net.ResourceLoader;
	import flash.net.URLRequest;

	import by.blooddy.platform.net.ILoadable;

	import flash.utils.ByteArray;

	import flash.events.EventDispatcher;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Транслируется, при добавлении "пучка".
	 *
	 * @eventType			flash.events.ResourceEvent.BUNDLE_ADDED
	 */
	[Event(name="bundleAdded", type="flash.events.ResourceEvent")]

	/**
	 * Транслируется, при удаление "пучка".
	 *
	 * @eventType			flash.events.ResourceEvent.BUNDLE_REMOVED
	 */
	[Event(name="bundleRemoved", type="flash.events.ResourceEvent")]

	/**
	 * Следитель за ресурсами.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					resourcemanager, resource, manager
	 */
	public class ResourceManager extends EventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function ResourceManager() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Сдесь храняться "пучки" ресурсов :)
		 */
		private const _hash:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Функция находит ресурс в "пучке" и возвращает его.
		 * 
		 * @param	bundleName		Имя либы
		 * @param	resourceName	Имя ресурса из либы
		 * 
		 * @return					Ресурс, если есть, или null.
		 * 
		 * @keyword					resourcemanager.getobject, getobject
		 */
		public function getObject(bundleName:String, resourceName:String):* {
			if (!this._hash[bundleName]) return null;
			return (this._hash[bundleName] as IResourceBundle).getObject(resourceName);
		}

		/**
		 * Функция нопределяет, если ли "пучОк".
		 * 
		 * @param	bundleName		Имя либы
		 * 
		 * @return					true, если есть и false, если нету.
		 * 
		 * @keyword					resourcemanager.hasresourcebundle, hasresourcebundle
		 */
		public function hasResourceBundle(bundleName:String):Boolean {
			var resourceBundle:IResourceBundle = this._hash[bundleName] as IResourceBundle;
			var loader:ILoadable = resourceBundle as ILoadable;
			return ( loader && !loader.loaded ? false : Boolean(resourceBundle) );
		}

		/**
		 * Функция находит "пучОк" и возвращает его.
		 * 
		 * @param	bundleName		Имя либы
		 * 
		 * @return					"ПучОк".
		 * 
		 * @keyword					resourcemanager.getresourcebundle, getresourcebundle
		 */
		public function getResourceBundle(bundleName:String):IResourceBundle {
			var resourceBundle:IResourceBundle = this._hash[bundleName] as IResourceBundle;
			var loader:ILoadable = resourceBundle as ILoadable;
			return ( loader && !loader.loaded ? null : resourceBundle );
		}

		/**
		 * Добавляет новый ресурс.
		 * 
		 * @param	bundleName		Имя "пучка".
		 * 
		 * @event	bundleAdded		ResourceEvent
		 * 
		 * @keyword					resourcemanager.removeresourcebundle, removeresourcebundle
		 */
		public function addResourceBundle(resourceBundle:IResourceBundle):void {
			if (!resourceBundle.name) return; // чё-то не то
			this._hash[resourceBundle.name] = resourceBundle;
			var loader:ILoadable = resourceBundle as ILoadable;
			if (loader && !loader.loaded) { // ещё не загрузились
				this.registerHandlers(loader);
			} else {
				this.dispatchEvent( new ResourceEvent(ResourceEvent.BUNDLE_ADDED, false, false, resourceBundle.name) );
			}
		}

		/**
		 * Удаляет ресурс.
		 * 
		 * @param	bundleName		Имя "пучка".
		 * 
		 * @event	bundleAdded		ResourceEvent
		 * 
		 * @keyword					resourcemanager.removeresourcebundle, removeresourcebundle
		 */
		public function removeResourceBundle(bundleName:String):void {
			if (this._hash[bundleName]) {
				var loader:ILoadable = this._hash[bundleName] as ILoadable;
				delete this._hash[bundleName];
				if (loader) this.unregisterHandlers(loader);
				if (!loader || loader.loaded) this.dispatchEvent( new ResourceEvent(ResourceEvent.BUNDLE_REMOVED, false, false, bundleName) );
			}
		}

		/**
		 * Загружает новый ресурс.
		 * 
		 * @param	url				Урыл, по которому лежит ресурс.
		 * 
		 * @return					Загрузщик, в которм ресурс грузится.
		 * 
		 * @event	bundleAdded		ResourceEvent
		 * 
		 * @keyword					resourcemanager.loadresourcebundle, loadresourcebundle
		 */
		public function loadResourceBundle(url:String):ILoadable {
			var loader:ResourceLoader;
			if (this._hash[url]) { // такой уже есть
				loader = this._hash[url] as ResourceLoader;
			} else {
				loader = new ResourceLoader();
				loader.load( new URLRequest(url) );
				this.registerHandlers(loader);
				this._hash[url] = loader;
			}
			return loader;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Добавляем события на загрузщик.
		 */
		private function registerHandlers(loader:ILoadable):void {
			loader.addEventListener(Event.COMPLETE, this.handler_complete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, this.handler_error);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handler_error);
		}

		/**
		 * @private
		 * Удаляем события с загрузщика.
		 */
		private function unregisterHandlers(loader:ILoadable):void {
			loader.removeEventListener(Event.COMPLETE, this.handler_complete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, this.handler_error);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handler_error);
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Обрабатываем окончание загрузки.
		 */
		private function handler_complete(event:Event):void {
			var loader:ILoadable = event.target as ILoadable;
			if (loader) this.unregisterHandlers(loader);
			this.addResourceBundle(event.target as IResourceBundle);
		}

		/**
		 * @private
		 * Ошибка. Надо удалить.
		 */
		private function handler_error(event:Event):void {
			var resourceBundle:IResourceBundle = event.target as IResourceBundle;
			if (resourceBundle) this.removeResourceBundle(resourceBundle.name);
		}

	}

}