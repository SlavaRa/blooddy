////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.resource {

	import by.blooddy.core.events.managers.ResourceBundleEvent;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.net.loading.LoaderPriority;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.system.Capabilities;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Транслируется, при добавлении "пучка".
	 *
	 * @eventType			by.blooddy.core.events.managers.ResourceBundleEvent.BUNDLE_ADDED
	 */
	[Event( name="bundleAdded", type="by.blooddy.core.events.managers.ResourceBundleEvent" )]

	/**
	 * Транслируется, при удаление "пучка".
	 *
	 * @eventType			by.blooddy.core.events.managers.ResourceBundleEvent.BUNDLE_REMOVED
	 */
	[Event( name="bundleRemoved", type="by.blooddy.core.events.managers.ResourceBundleEvent" )]

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
	public final class ResourceManager extends EventDispatcher implements IResourceManager {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _HASH:Object = new Object();

		/**
		 * @private
		 */
		private static var _loading:uint = 0;

		/**
		 * @private
		 */
		private static const _LOADING_QUEUE:Array = new Array();

		/**
		 * @private
		 */
		private static const _SORT_FIELDS:Array = new Array( 'priority', 'time' );

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
		private static var _maxLoading:uint = ( Capabilities.playerType == 'StandAlone' ? uint.MAX_VALUE : 3 );

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

		//----------------------------------
		//  baseURL
		//----------------------------------
		
		public static function get ignoreSecurity():Boolean {
			return ResourceLoaderAsset.ignoreSecurity;
		}
		
		public static function set ignoreSecurity(value:Boolean):void {
			ResourceLoaderAsset.ignoreSecurity = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function addLoaderQueue(asset:ResourceLoaderAsset, priority:int):void {
			if ( priority >= LoaderPriority.HIGHEST ) {
				registerQueue( asset );
				asset.$load();
				_loading++;
			} else {
				asset.queue = new QueueItem( asset, priority );
				_LOADING_QUEUE.push( asset.queue );
				_LOADING_QUEUE.sortOn( _SORT_FIELDS, _SORT_OPTIONS );
			 	if ( _loading < _maxLoading ) {
			 		enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, updateQueue );
				}
			}
		}

		/**
		 * @private
		 */
		private static function updateQueue(event:Event=null):void {
			if (
				_LOADING_QUEUE.length > 0 && (
					_loading < _maxLoading ||
					( _LOADING_QUEUE[ 0 ] as QueueItem ).priority >= LoaderPriority.HIGHEST
				)
			) {
				var asset:ResourceLoaderAsset = _LOADING_QUEUE.pop().asset;
				asset.queue = null;
				registerQueue( asset );
				asset.$load();
				_loading++;
			}
		 	if ( _loading >= _maxLoading || _LOADING_QUEUE.length <= 0 ) {
		 		enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, updateQueue );
		 	}
		}

		/**
		 * @private
		 */
		private static function registerQueue(asset:ResourceLoaderAsset):void {
			asset.addEventListener( Event.COMPLETE, handler_queue_complete );
			asset.addEventListener( ErrorEvent.ERROR, handler_queue_complete );
		}

		/**
		 * @private
		 */
		private static function unregisterQueue(asset:ResourceLoaderAsset):void {
			asset.removeEventListener( Event.COMPLETE, handler_queue_complete );
			asset.removeEventListener( ErrorEvent.ERROR, handler_queue_complete );
		}

		/**
		 * @private
		 */
		private static function handler_queue_complete(event:Event=null):void {
			unregisterQueue( event.target as ResourceLoaderAsset );
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
			this._hash[ '' ] = _DEFAULT_BUNDLE;
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
		public function getResource(bundleName:String, resourceName:String=null):* {
			if ( !( bundleName in this._hash ) ) return undefined;
			return ( this._hash[ bundleName ] as IResourceBundle ).getResource( resourceName );
		}

		public function hasResource(bundleName:String, resourceName:String=null):Boolean {
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
		public function hasResourceBundle(bundleName:String):Boolean {
			if ( !( bundleName in this._hash ) ) return false;
			var loader:ILoadable = this._hash[ bundleName ] as ILoadable;
			if ( loader && !loader.complete ) return false;
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
		public function getResourceBundle(bundleName:String):IResourceBundle {
			var bundle:IResourceBundle = this._hash[ bundleName ] as IResourceBundle;
			return ( bundle is ILoadable && !( bundle as ILoadable ).complete ? null : bundle );
		}

		public function getResourceBundles():Vector.<String> {
			var result:Vector.<String> = new Vector.<String>();
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
		 * @keyword					resourcemanager.removeresourcebundle, removeresourcebundle
		 */
		public function addResourceBundle(bundle:IResourceBundle):void {
			var name:String = bundle.name;
			if ( !name ) throw new ArgumentError();
			if ( name in this._hash ) {
				if ( this._hash[ name ] !== bundle ) {
					throw new ArgumentError();
				}
			} else {
				this._hash[ name ] = bundle;
				if ( bundle is ILoadable ) {
					var loader:ILoadable = bundle as ILoadable;
					if ( loader is ResourceLoaderAsset ) {
						( loader as ResourceLoaderAsset ).managers[ this ] = true;
					}
					if ( loader.complete ) {
						if ( super.hasEventListener( ResourceBundleEvent.BUNDLE_ADDED ) ) {
							super.dispatchEvent( new ResourceBundleEvent( ResourceBundleEvent.BUNDLE_ADDED, false, false, bundle ) );
						}
					} else {
						this.registerLoadable( loader );
					}
				}
			}
		}

		/**
		 * Удаляет ресурс.
		 * 
		 * @param	bundleName		Имя "пучка".
		 * 
		 * @keyword					resourcemanager.removeresourcebundle, removeresourcebundle
		 */
		public function removeResourceBundle(bundleName:String):void {
			if ( bundleName in this._hash ) {
				var bundle:IResourceBundle = this._hash[ bundleName ] as IResourceBundle;
				delete this._hash[ bundleName ];
				var loader:ILoadable = bundle as ILoadable;
				if ( loader ) {
					this.unregisterLoadable( loader );
					var asset:ResourceLoaderAsset = loader as ResourceLoaderAsset;
					var complete:Boolean = loader.complete;
					if ( asset ) { // если ассет, то помучаемся
						delete asset.managers[ this ];
						for each ( var has:Boolean in asset.managers ) break;
						if ( !has ) {
							delete _HASH[ bundleName ];
							if ( complete ) asset.$unload();
							else {
								if ( asset.queue ) {
									var i:int = _LOADING_QUEUE.indexOf( asset.queue );
									_LOADING_QUEUE.splice( i, 1 );
									asset.queue = null;
								} else asset.$close();
							}
						}
					}
					if ( complete && super.hasEventListener( ResourceBundleEvent.BUNDLE_REMOVED ) ) {
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
		 * @keyword					resourcemanager.loadresourcebundle, loadresourcebundle
		 */
		public function loadResourceBundle(url:String, priority:int=0.0):ILoadable {

			var asset:ResourceLoaderAsset;
			if ( url in this._hash ) { // такой уже есть

				asset = this._hash[ url ] as ResourceLoaderAsset;
				if ( !asset ) throw new ArgumentError();

			} else {

				if ( url in _HASH ) {
					asset = _HASH[ url ];
				} else {
					_HASH[ url ] = asset = new ResourceLoaderAsset( url );
					addLoaderQueue( asset, priority );
				}
				asset.managers[ this ] = true;
				this._hash[ url ] = asset;

				if ( asset.complete ) {
					if ( super.hasEventListener( ResourceBundleEvent.BUNDLE_ADDED ) ) {
						super.dispatchEvent( new ResourceBundleEvent( ResourceBundleEvent.BUNDLE_ADDED, false, false, asset ) );
					}
				} else {
					this.registerLoadable( asset );
				}

			}

			// изменился приоритет загрузки
			if ( !asset.complete ) {
				if ( asset.queue && asset.queue.priority < priority ) {
					asset.queue.priority = priority;
					_LOADING_QUEUE.sortOn( _SORT_FIELDS, _SORT_OPTIONS );
					updateQueue();
				}
			}

			return asset;

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
			loader.addEventListener( Event.COMPLETE,	this.handler_complete );
			loader.addEventListener( ErrorEvent.ERROR,	this.handler_complete );
			loader.addEventListener( Event.UNLOAD,		this.handler_unload );
		}

		/**
		 * @private
		 * Удаляем загружающайся объект
		 */
		private function unregisterLoadable(loader:ILoadable):void {
			loader.removeEventListener( Event.COMPLETE,		this.handler_complete );
			loader.removeEventListener( ErrorEvent.ERROR,	this.handler_complete );
			loader.removeEventListener( Event.UNLOAD,		this.handler_unload );
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
			if ( super.hasEventListener( ResourceBundleEvent.BUNDLE_ADDED ) ) {
				super.dispatchEvent( new ResourceBundleEvent( ResourceBundleEvent.BUNDLE_ADDED, false, false, loader as IResourceBundle ) );
			}
		}

		/**
		 * @private
		 * Обрабатываем выгрузку.
		 */
		private function handler_unload(event:Event):void {
			this.removeResourceBundle( ( event.target as IResourceBundle ).name );
		}
		
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.managers.resource.IResourceBundle;
import by.blooddy.core.managers.resource.ResourceLoader;
import by.blooddy.core.net.loading.LoaderContext;
import by.blooddy.core.utils.ClassUtils;

import flash.display.BitmapData;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getTimer;

/**
 * @private
 */
internal const _DEFAULT_BUNDLE:DefaultResourceBundle = new DefaultResourceBundle();

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

	public static var ignoreSecurity:Boolean = true;

	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static const _URL:RegExp = /^\w+:\/\//;

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	public function ResourceLoaderAsset(url:String) {
		super();
		this._url = url;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	internal var queue:QueueItem;
	
	internal const managers:Dictionary = new Dictionary( true );

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

	/**
	 * @private
	 */
	public override function set loaderContext(value:LoaderContext):void {
		throw new IllegalOperationError();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overriden methods
	//
	//--------------------------------------------------------------------------

	[Deprecated( message="метод запрещен", replacement="$load" )]
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
		super.loaderContext = new LoaderContext( new ApplicationDomain( ApplicationDomain.currentDomain ), ignoreSecurity );
		try { // так как запуск отложен, то и ошибку надо генерировать в виде события
			super.load( new URLRequest( url ) );
		} catch ( e:Error ) {
			super.dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, e.toString() ) );
		}
	}

	[Deprecated( message="метод запрещен", replacement="$load" )]
	public override function loadBytes(request:ByteArray):void {
		throw new IllegalOperationError();
	}
	
	[Deprecated( message="метод запрещен", replacement="$close" )]
	public override function close():void {
		throw new IllegalOperationError();
	}

	internal function $close():void {
		super.close();
	}

	[Deprecated( message="метод запрещен", replacement="$unload" )]
	public override function unload():void {
		throw new IllegalOperationError();
	}

	internal function $unload():void {
		super.unload();
	}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: QueueItem
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class QueueItem {

	public function QueueItem(asset:ResourceLoaderAsset, priority:int=0.0) {
		super();
		this.asset = asset;
		this.priority = priority;
	}

	public var asset:ResourceLoaderAsset;
	
	public var priority:int;
	
	public const time:Number = getTimer();

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: DefaultResourceBundle
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * дефолтный пучёк ресурсов
 * обёртка вокруг ApplicationDomain.currentDomain
 */
internal class DefaultResourceBundle implements IResourceBundle {
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor
	 * 
	 * @param	name		Имя пучка.
	 */
	public function DefaultResourceBundle() {
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 * Хранилеще ресурсов.
	 */
	private const _hash:Object = new Object();
	
	//--------------------------------------------------------------------------
	//
	//  Implements properties: IResourceBundle
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * @inheritDoc
	 */
	public function get name():String {
		return '';
	}
	
	//--------------------------------------------------------------------------
	//
	//  Implements methods: IResourceBundle
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @inheritDoc
	 */
	public function getResource(name:String=null):* {
		if ( !name ) {
			return null;
		} else if ( name in this._hash ) { // пытаемся найти в кэше
			return this._hash[ name ];
		} else {
			
			var resource:* = ApplicationDomain.currentDomain.getDefinition( name );
			if ( resource is Class ) {
				var resourceClass:Class = resource as Class;
				if ( BitmapData.prototype.isPrototypeOf( resourceClass.prototype ) ) {
					resource = new resourceClass( 0, 0 );
				} else if (
					Sound.prototype.isPrototypeOf( resourceClass.prototype ) ||
					ByteArray.prototype.isPrototypeOf( resourceClass.prototype )
				) {
					resource = new resourceClass();
				}
			}				
			this._hash[ name ] = resource;
			return resource;

		}
	}

	/**
	 * @inheritDoc
	 */
	public function hasResource(name:String=null):Boolean {
		return (
			name && (
				name in this._hash || // пытаемся найти в кэше
				ApplicationDomain.currentDomain.hasDefinition( name ) // пытаемся найти в домене
			)
		);
	}
	
	/**
	 * @private
	 */
	public function toString():String {
		return '[' + ClassUtils.getClassName( this ) + ' object]';
	}

}