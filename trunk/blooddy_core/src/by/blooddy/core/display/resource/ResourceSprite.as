////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display.resource {

	import by.blooddy.core.errors.display.resource.ResourceError;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.events.net.LoaderEvent;
	import by.blooddy.core.managers.resource.IResourceBundle;
	import by.blooddy.core.managers.resource.ResourceBundle;
	import by.blooddy.core.managers.resource.ResourceManager;
	import by.blooddy.core.net.ILoadable;
	import by.blooddy.core.utils.DisplayObjectUtils;
	import by.blooddy.core.utils.RecycleBin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @eventType			by.blooddy.core.events.net.LoaderEvent.LOADER_INIT
	 */
	[Event( name="loaderInit", type="by.blooddy.core.events.net.LoaderEvent" )]

	/**
	 * @eventType			by.blooddy.core.events.display.resource.ResourceEvent.GET_RESOURCE
	 */
	[Event( name="getResource", type="by.blooddy.core.events.display.resource.ResourceEvent" )]

	/**
	 * @eventType			by.blooddy.core.events.display.resource.ResourceEvent.TRASH_RESOURCE
	 */
	[Event( name="trashResource", type="by.blooddy.core.events.display.resource.ResourceEvent" )]

	/**
	 * @eventType			by.blooddy.core.events.display.resource.ResourceEvent.LOCK_BUNDLE
	 */
	[Event( name="lockBundle", type="by.blooddy.core.events.display.resource.ResourceEvent" )]

	/**
	 * @eventType			by.blooddy.core.events.display.resource.ResourceEvent.UNLOCK_BUNDLE
	 */
	[Event( name="unlockBundle", type="by.blooddy.core.events.display.resource.ResourceEvent" )]

	/**
	 * @eventType			by.blooddy.core.events.display.resource.ResourceEvent.ADDED_TO_MANAGER
	 */
	[Event( name="addedToManager", type="by.blooddy.core.events.display.resource.ResourceEvent" )]

	/**
	 * @eventType			by.blooddy.core.events.display.resource.ResourceEvent.REMOVED_FROM_MANAGER
	 */
	[Event( name="removedFromManager", type="by.blooddy.core.events.display.resource.ResourceEvent" )]

	/**
	 * Класс у когорого есть ссылка на манагер ресурсов.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					resourcemangerownersprite, resourcemanagerowner, resourcemanager, resource, manager, sprite
	 */
	public class ResourceSprite extends Sprite {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _HASH:Dictionary = new Dictionary( true );

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
		private static const _NAME_BITMAP_DATA:String = getQualifiedClassName( BitmapData );
		
		/**
		 * @private
		 */
		private static const _NAME_SOUND:String = getQualifiedClassName( Sound );
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ResourceSprite() {
			super();
			super.addEventListener( Event.ADDED_TO_STAGE,		this.handler_addedToStage,		false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE,	this.handler_removedFromStage,	false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _resources:Dictionary = new Dictionary( true );

		/**
		 * @private
		 */
		private var _manager:ResourceManager;

		/**
		 * @private
		 */
		private var _bin:RecycleBin;
		
		/**
		 * @private
		 */
		private var _addedToStage:Boolean = false;

		/**
		 * @private
		 */
		private var _addedToManager:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Overriden peoperties: DisplayObject
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function set filters(value:Array):void {
			if ( !super.filters.length && ( !value || !value.length ) ) return;
			super.filters = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function $getResourceManager():ResourceManager {
			var parent:DisplayObjectContainer = super.parent;
			while ( parent ) {
				if ( parent is ResourceSprite ) {
					return ( parent as ResourceSprite )._manager;
				}
				parent = parent.parent;
			}
			return ( super.stage ? ResourceManager.manager : null );
		}

		protected final function loadResourceBundle(bundleName:String, priority:int=0.0):ILoadable {
			if ( !this._addedToManager ) throw new ArgumentError();
			var loader:ILoadable = this._manager.loadResourceBundle( bundleName, priority );
			// диспатчим событие о том что началась загрузка
			if ( !loader.loaded ) super.dispatchEvent( new LoaderEvent( LoaderEvent.LOADER_INIT, true, true, loader ) );
			return loader;
		}

		protected final function unloadResourceBundle(bundleName:String):void {
			if ( !this._addedToManager ) throw new ArgumentError();
			var bundle:IResourceBundle = this._manager.getResourceBundle( bundleName, true );
			if ( bundle is ILoadable ) {
				if ( !this._manager.dispatchEvent( new LoaderEvent( LoaderEvent.LOADER_UNLOAD, false, true, bundle as ILoadable ) ) ) {
					return; // кто- то послал нафиг
				}
			}
			this._bin.clear( bundleName + _SEPARATOR );
			this._manager.removeResourceBundle( bundleName );
			bundle = this._manager.getResourceBundle( '$' + bundleName );
			if ( bundle is ResourceBundle ) {
				var resources:Array = bundle.getResources();
				var resource:*;
				for each ( var resourceName:String in resources ) {
					resource = bundle.getResource( resourceName );
					if ( resource is BitmapData ) {
						( resource as BitmapData ).dispose();
					}
				}
				this._manager.removeResourceBundle( '$' + bundleName );
			}
		}

		protected final function hasResource(bundleName:String, resourceName:String):Boolean {
			if ( !this._addedToManager ) throw new ArgumentError();
			if ( this._bin.has( bundleName + _SEPARATOR + resourceName ) ) return true;
			else {
				return this._manager.hasResource( bundleName, resourceName );
			}
			return false;
		}

		protected final function getResource(bundleName:String, resourceName:String):Object {
			var result:Object = this.getResource_get( bundleName, resourceName );
			switch ( typeof result ) {
				case 'object':
				case 'function':
				case 'xml':
					this.getResource_set( bundleName, resourceName, result );
			}
			return result;
		}

		protected final function getDisplayObject(bundleName:String, resourceName:String):DisplayObject {
			if ( !this._addedToManager ) throw new ArgumentError();
			var key:String = bundleName + _SEPARATOR + resourceName;
			var result:DisplayObject;
			if ( this._bin.has( key ) ) {
				result = this._bin.takeOut( key ) as DisplayObject;
				DisplayObjectUtils.reset( result );
			} else {
				var resource:Object = this.getResource_get( bundleName, resourceName );
				if ( resource is Class ) {
					var resourceClass:Class = resource as Class;
					if (
						DisplayObject.prototype.isPrototypeOf( resourceClass.prototype ) ||
						this._manager.getResource( bundleName, _NAME_DISPLAY_OBJECT ).prototype.isPrototypeOf( resourceClass.prototype ) // проверяем на поддоменность
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
				this.getResource_set( bundleName, resourceName, result );
			}
			return result;
		}

		protected final function getSound(bundleName:String, resourceName:String):Sound {
			var resource:Object = this.getResource_get( bundleName, resourceName );
			var result:Sound;
			if ( resource is Sound ) {
				result = resource as Sound;
			}
			if ( resource ) {
				this.getResource_set( bundleName, resourceName, result );
			}
			return result;
		}

		protected final function trashResource(resource:Object, time:uint=3*60*1E3):void {
			if ( !this._addedToManager ) throw new ArgumentError();
			var def:ResourceLinker = this._resources[ resource ];
			if ( !def ) throw new ArgumentError( '' );
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
			super.dispatchEvent( new ResourceEvent( ResourceEvent.TRASH_RESOURCE, true, false, def.bundleName, def.resourceName ) );
		}

		protected final function lockResourceBundle(bundleName:String):void {
			super.dispatchEvent( new ResourceEvent( ResourceEvent.LOCK_BUNDLE, true, false, bundleName ) );
		}

		protected final function unlockResourceBundle(bundleName:String):void {
			super.dispatchEvent( new ResourceEvent( ResourceEvent.UNLOCK_BUNDLE, true, false, bundleName ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function getResource_get(bundleName:String, resourceName:String):Object {
			if ( !this._addedToManager ) throw new ArgumentError();

			if ( this._manager.hasResource( bundleName, resourceName ) ) {

				var resource:Object = this._manager.getResource( bundleName, resourceName );
				if ( resource is Class ) {

					var bundle:ResourceBundle;
					var resourceClass:Class = resource as Class;

					if (
						BitmapData.prototype.isPrototypeOf( resourceClass.prototype ) ||
						Sound.prototype.isPrototypeOf( resourceClass.prototype ) ||
						this._manager.getResource( bundleName, _NAME_BITMAP_DATA ).prototype.isPrototypeOf( resourceClass.prototype ) ||
						this._manager.getResource( bundleName, _NAME_SOUND ).prototype.isPrototypeOf( resourceClass.prototype )
					) {

						var name:String = '$' + bundleName;
						if ( this._manager.hasResource( name, resourceName ) ) {

							resource = this._manager.getResource( name, resourceName );

						} else {

							if (
								BitmapData.prototype.isPrototypeOf( resourceClass.prototype ) ||
								this._manager.getResource( bundleName, _NAME_BITMAP_DATA ).prototype.isPrototypeOf( resourceClass.prototype )
							) {
								resource = new resourceClass( 0, 0 );
							} else {
								resource = new resourceClass();
							}

							bundle = this._manager.getResourceBundle( name ) as ResourceBundle;
							if ( !bundle ) {
								bundle = new ResourceBundle( name );
								this._manager.addResourceBundle( bundle );
							}
							bundle.addResource( resourceName, resource );

						}

					}

				}
				return resource; 
			}
			return null;
		}

		/**
		 * @private
		 */
		private function getResource_set(bundleName:String, resourceName:String, resource:Object):void {
			var def:ResourceLinker = this._resources[ resource ];
			if ( !def ) {
				this._resources[ resource ] = def = new ResourceLinker( bundleName, resourceName );
			}
			def.count++;
			super.dispatchEvent( new ResourceEvent( ResourceEvent.GET_RESOURCE, true, false, bundleName, resourceName ) );
		}

		/**
		 * @private
		 */
		private function removeFromManager():void {
			if ( super.hasEventListener( ResourceEvent.REMOVED_FROM_MANAGER ) ) {
				super.dispatchEvent( new ResourceEvent( ResourceEvent.REMOVED_FROM_MANAGER ) );
			}
			// если у нас остались ресурсы, это ЖОПА!
			var resources:Vector.<ResourceDefinition>;
			for each ( var def:ResourceLinker in this._resources ) {
				if ( !resources ) resources = new Vector.<ResourceDefinition>();
				resources.push( def );
			}
			if ( resources ) {
				throw new ResourceError( 'Некоторые ресурсы не были возвращены в мэннеджер ресурсов.', 5100, resources );
			}
			// зануляем resourceManager
			this._addedToManager = false;
			this._manager = null; // FIXME надо со старым поработать
			this._bin = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {
			if ( this._addedToStage ) {
				event.stopImmediatePropagation();
			} else {

				super.removeEventListener( Event.FRAME_CONSTRUCTED, this.handler_frameContructed );

				this._addedToStage = true;

				var manager:ResourceManager = this.$getResourceManager();

				if ( this._addedToManager && this._manager !== manager ) {
					this.removeFromManager();
				}
				
				if ( !this._addedToManager ) {
					this._addedToManager = true;
					this._manager = manager;
					this._bin = _HASH[ manager ];
					if ( !this._bin ) _HASH[ manager ] = this._bin = new RecycleBin();
					if ( super.hasEventListener( ResourceEvent.ADDED_TO_MANAGER ) ) {
						super.dispatchEvent( new ResourceEvent( ResourceEvent.ADDED_TO_MANAGER ) );
					}
				}

			}
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			this._addedToStage = false;
			super.addEventListener( Event.FRAME_CONSTRUCTED, this.handler_frameContructed, false, int.MAX_VALUE );
		}

		/**
		 * @private
		 */
		private function handler_frameContructed(event:Event):void {
			super.removeEventListener( Event.FRAME_CONSTRUCTED, this.handler_frameContructed );
			this.removeFromManager();
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.display.resource.ResourceDefinition;

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