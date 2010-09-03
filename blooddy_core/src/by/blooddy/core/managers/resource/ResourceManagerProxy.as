////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.resource {

	import by.blooddy.core.display.resource.ResourceDefinition;
	import by.blooddy.core.errors.display.resource.ResourceError;
	import by.blooddy.core.events.managers.ResourceBundleEvent;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.utils.DisplayObjectUtils;
	import by.blooddy.core.utils.RecycleBin;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					21.02.2010 3:46:27
	 */
	public final class ResourceManagerProxy implements IResourceManager {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _SEPARATOR:String = String.fromCharCode( 0 );

		/**
		 * @private
		 */
		private static const _NAME_DISPLAY_OBJECT:String = getQualifiedClassName( DisplayObject );

		/**
		 * @private
		 */
		private static const _PROTO_DISPLAY_OBJECT:Object =	DisplayObject.prototype;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ResourceManagerProxy() {
			super();
			this._manager.addEventListener( ResourceBundleEvent.BUNDLE_ADDED,	this.handler_bundleAdded, false, int.MAX_VALUE, true );
			this._manager.addEventListener( ResourceBundleEvent.BUNDLE_REMOVED,	this.handler_bundleRemoved, false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _manager:ResourceManager = new ResourceManager();

		/**
		 * @private
		 */
		private const _bin:RecycleBin = new RecycleBin();

		/**
		 * @private
		 */
		private const _resources:Dictionary = new Dictionary( true );

		/**
		 * @private
		 */
		private const _resourceUsages:Object = new Object();

		/**
		 * @private
		 */
		private const _timer:Timer = new Timer( 15e3 );

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _resourceLiveTime:uint = 60e3;

		public final function get resourceLiveTime():uint {
			return this._resourceLiveTime;
		}

		/**
		 * @private
		 */
		public final function set resourceLiveTime(value:uint):void {
			if ( this._resourceLiveTime == value ) return;
			this._resourceLiveTime = value;
			this._timer.delay = this._resourceLiveTime / 4;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function clear():void {
			var resources:Vector.<ResourceDefinition>;
			var hash:Object = new Object();
			for each ( var def:ResourceLinker in this._resources ) {
				if ( !resources ) resources = new Vector.<ResourceDefinition>();
				resources.push( def );
				hash[ def.bundleName ] = true;
			}
			var locks:Vector.<ResourceDefinition>;
			for ( var bundleName:String in this._resourceUsages ) {
				if ( !( bundleName in hash ) ) {
					var usage:ResourceUsage = this._resourceUsages[ bundleName ];
					if ( usage.lock ) {
						if ( !resources ) { // у нас другая ошибка будет
							if ( !locks ) locks = new Vector.<ResourceDefinition>();
							locks.push( new ResourceDefinition( bundleName ) );
						}
					} else {
						this.unloadResourceBundle( bundleName );
					}
				}
			}
			if ( resources ) {
				throw new ResourceError( 'Некоторые ресурсы не были возвращены в мэннеджер ресурсов.', 0, resources );
			} else if ( locks ) {
				throw new ResourceError( 'Некоторые ресурсы не были разблокированны.', 0, locks );
			}
		}

		public function loadResourceBundle(url:String, priority:int=0.0):ILoadable {
			return this._manager.loadResourceBundle( url, priority );
		}

		public function hasResource(bundleName:String, resourceName:String=null):Boolean {
			if ( !resourceName ) resourceName = '';
			if ( this._bin.has( bundleName + _SEPARATOR + resourceName ) ) return true;
			else return this._manager.hasResource( bundleName, resourceName );
		}

		public function getResource(bundleName:String, resourceName:String=null):* {
			var result:* = this._manager.getResource( bundleName, resourceName );
			switch ( typeof result ) {
				case 'object':
				case 'function':
					if ( !resourceName ) resourceName = '';
					this.saveResource( bundleName, resourceName, result );
					break;
				case 'xml':
					result = result.copy();
					break;
			}
			return result;
		}

		public function getDisplayObject(bundleName:String, resourceName:String=null):DisplayObject {
			if ( !resourceName ) resourceName = '';
			var key:String = bundleName + _SEPARATOR + resourceName;
			var result:DisplayObject;
			if ( this._bin.has( key ) ) {
				result = this._bin.takeOut( key ) as DisplayObject;
				DisplayObjectUtils.reset( result );
			} else {
				var resource:Object = this._manager.getResource( bundleName, resourceName );
				if ( resource is Class ) {
					var resourceClass:Class = resource as Class;
					var p:Object = resourceClass.prototype;
					if (
						_PROTO_DISPLAY_OBJECT.isPrototypeOf( p ) ||
						this._manager.getResource( bundleName, _NAME_DISPLAY_OBJECT ).prototype.isPrototypeOf( p ) // проверяем на поддоменность
					) {
						result = new resourceClass() as DisplayObject;
					}
				} else if ( resource is DisplayObject ) {
					result = resource as DisplayObject;
				} else if ( resource is BitmapData ) {
					result = new Bitmap( resource as BitmapData );
				}
			}
			if ( result ) {
				this.saveResource( bundleName, resourceName, result );
			}
			return result;
		}

		public function getSound(bundleName:String, resourceName:String=null):Sound {
			var resource:Object = this._manager.getResource( bundleName, resourceName );
			var result:Sound;
			if ( resource is Sound ) {
				result = resource as Sound;
			}
			if ( result ) {
				if ( !resourceName ) resourceName = '';
				this.saveResource( bundleName, resourceName, result );
			}
			return result;
		}

		public function trashResource(resource:Object, time:uint=3*60*1E3):void {
			var def:ResourceLinker = this._resources[ resource ];
			if ( !def ) throw new ArgumentError( 'Ресурс не был создан.', 5101 );
			def.count--;
			if ( !def.count ) {
				delete this._resources[ resource ];
			}
			if ( resource is DisplayObject ) {
				var mc:DisplayObject = resource as DisplayObject;
				if ( mc is MovieClip ) {
					( mc as MovieClip ).stop();
				}
				if ( mc.parent ) {
					mc.parent.removeChild( mc );
				}
				if ( time > 0 ) {
					this._bin.takeIn( def.bundleName + _SEPARATOR + def.resourceName, resource, time );
				}
			}
			var usage:ResourceUsage = this._resourceUsages[ def.bundleName ] as ResourceUsage;
			usage.count--;
			if ( usage.count <= 0 ) usage.lastUse = getTimer();
		}

		public function lockResourceBundle(bundleName:String):void {
			var usage:ResourceUsage = this._resourceUsages[ bundleName ] as ResourceUsage;
			if ( !usage ) this._resourceUsages[ bundleName ] = usage = new ResourceUsage();
			usage.lock = true;
		}

		public function unlockResourceBundle(bundleName:String):void {
			var usage:ResourceUsage = this._resourceUsages[ bundleName ] as ResourceUsage;
			if ( usage && usage.lock ) {
				usage.lock = false;
				if ( usage.count <= 0 ) usage.lastUse = getTimer();
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function saveResource(bundleName:String, resourceName:String, resource:Object):void {
			var def:ResourceLinker = this._resources[ resource ];
			if ( !def ) this._resources[ resource ] = def = new ResourceLinker( bundleName, resourceName );
			def.count++;
			var usage:ResourceUsage = this._resourceUsages[ bundleName ] as ResourceUsage;
			usage.count++;
		}

		/**
		 * @private
		 */
		private function unloadResourceBundle(bundleName:String):void {
			this._bin.clear( bundleName + _SEPARATOR );
			this._manager.removeResourceBundle( bundleName );
		}

		/**
		 * @private
		 */
		private function isEmpty():Boolean {
			for each ( var usage:ResourceUsage in this._resourceUsages ) {
				return false;
			}
			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_bundleAdded(event:ResourceBundleEvent):void {
			if ( this.isEmpty() ) {
				this._timer.reset();
				this._timer.start();
				this._timer.addEventListener( TimerEvent.TIMER, this.handler_timer );
			}
			this._resourceUsages[ event.bundle.name ] = new ResourceUsage();
		}

		/**
		 * @private
		 */
		private function handler_bundleRemoved(event:ResourceBundleEvent):void {
			delete this._resourceUsages[ event.bundle.name ];
			if ( this.isEmpty() ) {
				this._timer.stop();
				this._timer.removeEventListener( TimerEvent.TIMER, this.handler_timer );
			}
		}

		/**
		 * @private
		 */
		private function handler_timer(event:TimerEvent):void {
			var time:Number = getTimer() - this._resourceLiveTime;
			var usage:ResourceUsage;
			for ( var bundleName:String in this._resourceUsages ) {
				usage = this._resourceUsages[ bundleName ] as ResourceUsage;
				if ( !usage.lock && usage.count <= 0 && usage.lastUse <= time ) {
					this.unloadResourceBundle( bundleName );
				}
			}
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.display.resource.ResourceDefinition;

import flash.utils.Dictionary;
import flash.utils.getTimer;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ResourceLinker
//
////////////////////////////////////////////////////////////////////////////////

internal final class ResourceLinker extends ResourceDefinition {
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 * Constructor
	 */
	public function ResourceLinker(bundleName:String=null, resourceName:String=null) {
		super( bundleName, resourceName );
	}
	
	//--------------------------------------------------------------------------
	//
	//  Proeprties
	//
	//--------------------------------------------------------------------------
	
	public var count:uint = 0;
	
}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ResourceUsage
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class ResourceUsage {
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor
	 */
	public function ResourceUsage() {
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	public var count:uint;
	
	public var lastUse:Number = getTimer();
	
	public var lock:Boolean = false;
	
}