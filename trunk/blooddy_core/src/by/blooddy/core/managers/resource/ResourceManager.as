////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.resource {

	import by.blooddy.core.events.managers.ResourceBundleEvent;
	import by.blooddy.core.net.ILoadable;
	import by.blooddy.core.net.ILoader;
	import by.blooddy.core.net.LoaderPriority;
	import by.blooddy.core.net.ResourceLoader;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.Capabilities;

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
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var _loading:uint = 0;

		/**
		 * @private
		 */
		private static const _HASH:Object = new Object();

		/**
		 * @private
		 */
		private static const _LOADING_QUEUE:Array = new Array();

		/**
		 * @private
		 */
		private static const _SORT_FIELDS:Array = new Array( "priority", "time" );

		/**
		 * @private
		 */
		private static const _SORT_OPTIONS:Array = new Array( Array.NUMERIC, Array.NUMERIC | Array.DESCENDING );

		//--------------------------------------------------------------------------
		//
		//  Class properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  manager
		//----------------------------------

		public static const manager:ResourceManager = new ResourceManager();

		//----------------------------------
		//  maxLoading
		//----------------------------------

		/**
		 * @private
		 */
		private static var _maxLoading:uint = ( Capabilities.playerType == "StandAlone" ? 240 : 3 );

		public static function get maxLoading():uint {
			return _maxLoading;
		}

		/**
		 * @private
		 */
		public static function set maxLoading(value:uint):void {
			if ( _maxLoading == value ) return;
			_maxLoading = value;
		 	if ( _loading < _maxLoading || _LOADING_QUEUE.length > 0 ) {
		 		enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, updateQueue );
			}
		}

		//----------------------------------
		//  baseURL
		//----------------------------------

		public static function get baseURL():String {
			return ResourceLoaderAsset.baseURL || '';
		}

		public static function set baseURL(value:String):void {
			ResourceLoaderAsset.baseURL = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function addLoaderQueue(loader:ResourceLoaderAsset):void {
			registerQueue( loader );
			if ( loader.priority >= LoaderPriority.HIGHEST ) {
				loader.$load();
				_loading++;
			} else {
				_LOADING_QUEUE.push( loader );
				_LOADING_QUEUE.sortOn( _SORT_FIELDS, _SORT_OPTIONS );
			 	if ( _loading < _maxLoading || _LOADING_QUEUE.length > 0 ) {
			 		enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, updateQueue );
				}
			}
		}

		/**
		 * @private
		 */
		private static function loadQueue():void {
			if ( _LOADING_QUEUE.length <= 0 ) return;
			var loader:ResourceLoaderAsset = _LOADING_QUEUE.pop() as ResourceLoaderAsset;
			if ( loader.$managers.length > 0 ) {
				loader.$load();
				_loading++;
			}
		}

		/**
		 * @private
		 */
		private static function updateQueue(event:Event=null):void {
			if ( _loading < _maxLoading ) {
				loadQueue();
			}
		 	if ( _loading >= _maxLoading || _LOADING_QUEUE.length <= 0 ) {
		 		enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, updateQueue );
		 	}
		}

		/**
		 * @private
		 */
		private static function registerQueue(loader:ILoadable):void {
			loader.addEventListener( Event.COMPLETE, queue_complete );
			loader.addEventListener( IOErrorEvent.IO_ERROR, queue_complete );
			loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, queue_complete );
		}

		/**
		 * @private
		 */
		private static function unregisterQueue(loader:ILoadable):void {
			loader.removeEventListener( Event.COMPLETE, queue_complete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR, queue_complete );
			loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, queue_complete );
		}

		/**
		 * @private
		 */
		private static function queue_complete(event:Event=null):void {
			unregisterQueue( event.target as ILoadable );
			_loading--;
		 	if ( _loading < _maxLoading || _LOADING_QUEUE.length > 0 ) {
		 		enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, updateQueue );
			}
		}

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
		public function getResource(bundleName:String, resourceName:String):* {
			if ( !( bundleName in this._hash ) ) return undefined;
			return ( this._hash[ bundleName ] as IResourceBundle ).getResource( resourceName );
		}

		public function hasResource(bundleName:String, resourceName:String):Boolean {
			if ( !this.hasResourceBundle( bundleName ) ) return false;
			return ( this._hash[ bundleName ] as IResourceBundle ).hasResource( resourceName );
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
		public function hasResourceBundle(bundleName:String, ignoreLoaded:Boolean=false):Boolean {
			if ( !( bundleName in this._hash ) ) return false;
			if ( !ignoreLoaded ) {
				var loader:ILoadable = this._hash[ bundleName ] as ILoadable;
				if ( loader && !loader.loaded ) return false;
			}
			return true;
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
		public function getResourceBundle(bundleName:String, ignoreLoaded:Boolean=false):IResourceBundle {
			var bundle:IResourceBundle = this._hash[ bundleName ] as IResourceBundle;
			return ( !ignoreLoaded && bundle is ILoadable && !( bundle as ILoadable ).loaded ? null : bundle );
		}

		public function isUnloadable(bundleName:String):Boolean {
			var bundle:IResourceBundle = this._hash[ bundleName ] as IResourceBundle;
			return ( !bundle || !( bundle is ResourceLoaderAsset ) || ( bundle as ResourceLoaderAsset ).$managers.length <= 1 );
		}

		[ArrayElementType('String')]
		public function getResourceBundles():Array {
			var result:Array = new Array();
			for ( var name:String in this._hash ) {
				result.push( name );
			}
			return result;
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
		public function addResourceBundle(bundle:IResourceBundle):void {
			var name:String = bundle.name
			if ( !name ) throw new ArgumentError();
			if ( name in this._hash ) {
				if ( this._hash[ name ] !== bundle ) {
					this.removeResourceBundle( name );
				} else return;
			}
			this._hash[ name ] = bundle;
			var loader:ILoadable = bundle as ILoadable;
			if ( loader ) {
				if ( loader is ResourceLoaderAsset ) {
					( loader as ResourceLoaderAsset ).$managers.push( this );
				}
				if ( !loader.loaded ) {
					this.registerLoadable( loader );
				}
			}
			if ( ( !loader || loader.loaded ) && super.hasEventListener( ResourceBundleEvent.BUNDLE_ADDED ) ) {
				super.dispatchEvent( new ResourceBundleEvent( ResourceBundleEvent.BUNDLE_ADDED, false, false, bundle ) );
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
			if ( bundleName in this._hash ) {
				var bundle:IResourceBundle = this._hash[ bundleName ] as IResourceBundle;
				delete this._hash[ bundleName ];
				var loader:ILoadable = bundle as ILoadable;
				if ( loader ) {
					var asset:ResourceLoaderAsset = loader as ResourceLoaderAsset;
					var loaded:Boolean = loader.loaded;
					if ( asset ) { // если ассет, то помучаемся
						var i:int = asset.$managers.indexOf( this );
						if ( i>=0 ) { // надо удлить себя из списков
							asset.$managers.splice( i, 1 );
							if ( asset.$managers.length <= 0 ) { // вдруг мы последние?
								// удаляемся, и выгружаемся
								delete ResourceManager._HASH[ asset.name ];
								if ( !asset.loaded ) asset.$close();
								asset.$unload();
							}
						}
					}
					this.unregisterLoadable( loader );
					if ( loaded && super.hasEventListener( ResourceBundleEvent.BUNDLE_REMOVED ) ) {
						super.dispatchEvent( new ResourceBundleEvent( ResourceBundleEvent.BUNDLE_REMOVED, false, false, bundle ) );
					}
				}
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
		public function loadResourceBundle(url:String, priority:uint=0):ILoadable {
			var loader:ILoader;
			var asset:ResourceLoaderAsset;
			
			if ( url in this._hash ) { // такой уже есть
				loader = this._hash[ url ] as ILoader;
				if ( !loader ) this.removeResourceBundle( url );
				
				if ( loader is ResourceLoaderAsset && !loader.loaded ){
					asset = loader as ResourceLoaderAsset;
					
					if ( asset.priority < priority ) {
						asset.priority = priority;
						ResourceManager._LOADING_QUEUE.sortOn( _SORT_FIELDS, _SORT_OPTIONS );
					}
				} 
			}
			
			if ( !loader ) { // нету
				if ( url in ResourceManager._HASH ) { // ищем в глобальной зоне
					asset = ResourceManager._HASH[ url ] as ResourceLoaderAsset;
					if ( !asset.loaded && asset.priority < priority ) { // изменился приоритет загрузки
						asset.priority = priority;
						ResourceManager._LOADING_QUEUE.sortOn( _SORT_FIELDS, _SORT_OPTIONS );
					}
				} else {
					ResourceManager._HASH[ url ] =
					asset = new ResourceLoaderAsset( url, priority );
					ResourceManager.addLoaderQueue( asset );
				}
				this._hash[ url ] = loader = asset;
				asset.$managers.push( this );
				if ( !asset.loaded )	this.registerLoadable( asset );
				else if ( super.hasEventListener( ResourceBundleEvent.BUNDLE_ADDED ) ) {
					super.dispatchEvent( new ResourceBundleEvent( ResourceBundleEvent.BUNDLE_ADDED, false, false, asset ) );
				}
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
		 * Добавляем уже грузящийся объект
		 */
		private function registerLoadable(loader:ILoadable):void {
			loader.addEventListener( Event.COMPLETE, this.handler_complete );
			loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, this.handler_complete );
			loader.addEventListener( IOErrorEvent.IO_ERROR, this.handler_complete );
		}

		/**
		 * @private
		 * Удаляем загружающайся объект
		 */
		private function unregisterLoadable(loader:ILoadable):void {
			loader.removeEventListener( Event.COMPLETE, this.handler_complete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR, this.handler_complete );
			loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, this.handler_complete );
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
			if ( loader ) this.unregisterLoadable( loader );
			if ( super.hasEventListener( ResourceBundleEvent.BUNDLE_ADDED ) ) {
				super.dispatchEvent( new ResourceBundleEvent( ResourceBundleEvent.BUNDLE_ADDED, false, false, loader as IResourceBundle ) );
			}
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.net.ResourceLoader;
import by.blooddy.core.utils.ClassUtils;

import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.getTimer;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ResourceLoaderAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class ResourceLoaderAsset extends ResourceLoader {

	//--------------------------------------------------------------------------
	//
	//  Class properties
	//
	//--------------------------------------------------------------------------

	public static var baseURL:String;

	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static const _URL:RegExp = /^(https?|file|ftps?|):\/\//;

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	public function ResourceLoaderAsset(url:String, priority:int=0.0, loaderContext:LoaderContext=null) {
		super( null, loaderContext );
		this._url = url;
		this.priority = priority;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	public var priority:int;

	public const time:Number = getTimer();

	internal const $managers:Array = new Array();

	//--------------------------------------------------------------------------
	//
	//  Overriden properties
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _url:String;

	public override function get url():String {
		return this._url;
	}

	public override function get name():String {
		return this._url;
	}

	//--------------------------------------------------------------------------
	//
	//  Overriden methods
	//
	//--------------------------------------------------------------------------

	[Deprecated(message="метод запрещен", replacement="$load")]
	public override function load(request:URLRequest):void {
		throw new IllegalOperationError();
	}

	internal function $load():void {
		var url:String;
		if ( !baseURL || _URL.test( this._url ) ) {
			url = this._url;
		} else {
			url = baseURL + '/' + this._url;
		}
		super.load( new URLRequest( url ) );
	}

	[Deprecated(message="метод запрещен", replacement="$close")]
	public override function close():void {
		throw new IllegalOperationError();
	}

	internal function $close():void {
		try {
			super.close();
		} catch ( e:Error) {
		}
	}

	[Deprecated(message="метод запрещен", replacement="$unload")]
	public override function unload():void {
		throw new IllegalOperationError();
	}

	internal function $unload():void {
		try {
			super.unload();
		} catch ( e:Error ) {
			super.dispatchEvent( new Event( Event.UNLOAD ) );
		}
	}

	public override function toString():String {
		return '[' + ClassUtils.getClassName( this ) + ' priority=' + this.priority + ' time=' + this.time + ' url="' + ( this._url || '' ) + '" bytesLoaded='+ this.bytesLoaded +' bytesTotal=' + this.bytesTotal + ']';
	}

}