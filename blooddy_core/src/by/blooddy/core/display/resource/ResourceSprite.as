////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display.resource {

	import by.blooddy.core.errors.getErrorMessage;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.events.net.LoaderEvent;
	import by.blooddy.core.managers.IResourceBundle;
	import by.blooddy.core.managers.ResourceBundle;
	import by.blooddy.core.managers.ResourceManager;
	import by.blooddy.core.net.ILoadable;
	import by.blooddy.core.utils.RecycleBin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.utils.Dictionary;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @eventType			by.blooddy.core.events.display.resource.ResourceEvent.GET_RESOURCE
	 */
	[Event(name="getResource", type="by.blooddy.core.events.display.resource.ResourceEvent")]

	/**
	 * @eventType			by.blooddy.core.events.display.resource.ResourceEvent.TRASH_RESOURCE
	 */
	[Event(name="trashResource", type="by.blooddy.core.events.display.resource.ResourceEvent")]

	/**
	 * @eventType			by.blooddy.core.events.net.LoaderEvent.LOADER_INIT
	 */
	[Event(name="loaderInit", type="by.blooddy.core.events.net.LoaderEvent")]

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
		private static const _TRASH:RecycleBin = new RecycleBin();

		/**
		 * @private
		 */
		private static const _SEPERATOR:String = String.fromCharCode( 0 );

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
			// ХАК
			super.addEventListener( Event.ADDED_TO_STAGE,		this.handler_addedToStage_hack,			false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE,	this.handler_removedFromStage_hack1,	false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE,	this.handler_removedFromStage_hack2,	false, int.MIN_VALUE, true );

			super.addEventListener( Event.REMOVED_FROM_STAGE,	this.handler_removedFromStage,			false, int.MAX_VALUE, true );
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
		private var _resourceManager:ResourceManager;

		//--------------------------------------------------------------------------
		//
		//  Overriden peoperties: DisplayObject
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _stage:Stage;

		public override function get stage():Stage {
			return this._stage;
		}

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
					return ( parent as ResourceSprite ).getResourceManager();
				}
				parent = parent.parent;
			}
			return ( this._stage ? ResourceManager.manager : null );
		}

		protected final function loadResourceBundle(bundleName:String, priority:int=0.0):ILoadable {
			var manager:ResourceManager = this._resourceManager || this.getResourceManager();
			if ( !manager ) throw new ArgumentError();
			var loader:ILoadable = manager.loadResourceBundle( bundleName, priority );
			// диспатчим событие о том что началась загрузка
			if ( !loader.loaded ) super.dispatchEvent( new LoaderEvent( LoaderEvent.LOADER_INIT, true, true, loader ) );
			return loader;
		}

		protected final function unloadResourceBundle(bundleName:String):void {
			var manager:ResourceManager = this._resourceManager || this.getResourceManager();
			if ( !manager ) throw new ArgumentError();
			var bundle:IResourceBundle = manager.getResourceBundle( bundleName, true );
			if ( bundle is ILoadable ) {
				if ( !manager.dispatchEvent( new LoaderEvent( LoaderEvent.LOADER_UNLOAD, false, true, bundle as ILoadable ) ) ) {
					return; // кто- то послал нафиг
				}
			}
			if ( manager.isUnloadable( bundleName ) ) { // больше нигде не понадобится 100%
				_TRASH.clear( bundleName + _SEPERATOR );
			}
			manager.removeResourceBundle( bundleName );
			bundle = manager.getResourceBundle( '$' + bundleName );
			if ( bundle is ResourceBundle ) {
				var resources:Array = bundle.getResources();
				var resource:*;
				for each ( var resourceName:String in resources ) {
					resource = bundle.getResource( resourceName );
					if ( resource is BitmapData ) {
						( resource as BitmapData ).dispose();
					}
				}
				manager.removeResourceBundle( '$' + bundleName );
			}
		}

		protected final function hasResource(bundleName:String, resourceName:String):Boolean {
			var manager:ResourceManager = this._resourceManager || this.getResourceManager();
			if ( !manager ) throw new ArgumentError();
			if ( _TRASH.has( bundleName + _SEPERATOR + resourceName ) ) return true;
			else {
				return manager.hasResource( bundleName, resourceName );
			}
			return false;
		}

		protected final function getResource(bundleName:String, resourceName:String):Object {
			var result:Object = this.getResource_get( bundleName, resourceName );
			if ( result ) {
				this.getResource_set( bundleName, resourceName, result );
			}
			return result;
		}

		protected final function getDisplayObject(bundleName:String, resourceName:String):DisplayObject {
			var resource:Object = this.getResource_get( bundleName, resourceName );
			var result:DisplayObject;
			if ( resource is Class ) {
				var resourceClass:Class = resource as Class;
				if ( DisplayObject.prototype.isPrototypeOf( resourceClass.prototype ) ) {
					result = new resourceClass() as DisplayObject;
				}
			} else if ( resource is DisplayObject ) {
				result = resource as DisplayObject;
			} else if ( resource is BitmapData ) {
				result = new Bitmap( resource as BitmapData );
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
			var manager:ResourceManager = this._resourceManager || this.getResourceManager();
			if ( !manager ) throw new ArgumentError();

			var def:ResourceLinker = this._resources[ resource ];
			if ( !def ) throw new ArgumentError( '' );
			def.count--;
			if ( !def.count ) {
				delete this._resources[ resource ];
			}

			if ( resource is DisplayObject ) {
				var mc:DisplayObject = resource as DisplayObject;
				if ( mc.parent ) {
					mc.parent.removeChild( mc );
				}
				if ( time > 0 ) {
					_TRASH.takeIn( def.bundleName + _SEPERATOR + def.resourceName, resource, time );
				}
			}
			super.dispatchEvent( new ResourceEvent( ResourceEvent.TRASH_RESOURCE, true, false, def.bundleName, def.resourceName ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function getResourceManager():ResourceManager {
			if ( !this._resourceManager ) {
				this._resourceManager = this.getResourceManager();
			}
			return this._resourceManager;
		}

		/**
		 * @private
		 */
		private function getResource_get(bundleName:String, resourceName:String):Object {
			var manager:ResourceManager = this._resourceManager || this.getResourceManager();
			if ( !manager ) throw new ArgumentError();

			var key:String = bundleName + _SEPERATOR + resourceName;

			if ( _TRASH.has( key ) ) {

				return _TRASH.takeOut( key );

			} else {

				if ( manager.hasResource( bundleName, resourceName ) ) {

					var resource:Object = manager.getResource( bundleName, resourceName );
					if ( resource is Class ) {

						var bundle:ResourceBundle;
						var resourceClass:Class = resource as Class;

						if (
							BitmapData.prototype.isPrototypeOf( resourceClass.prototype ) ||
							Sound.prototype.isPrototypeOf( resourceClass.prototype )
						) {

							var name:String = '$' + bundleName;
							if ( manager.hasResource( name, resourceName ) ) {

								resource = manager.getResource( name, resourceName );

							} else {

								if ( BitmapData.prototype.isPrototypeOf( resourceClass.prototype ) ) {
									resource = new resourceClass( 0, 0 );
								} else {
									resource = new resourceClass();
								}

								bundle = manager.getResourceBundle( name ) as ResourceBundle;
								if ( !bundle ) {
									bundle = new ResourceBundle( name );
									manager.addResourceBundle( bundle );
								}
								bundle.addResource( resourceName, resource );

							}

						}

					}
					return resource; 
				}
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

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			this._resourceManager = null;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers: ХАК
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _addedToStage:Boolean = false;

		/**
		 * @private
		 */
		private function handler_addedToStage_hack(event:Event):void {
			if ( this._addedToStage ) {
				event.stopImmediatePropagation();
			} else {
				var manager:ResourceManager = this._resourceManager;
				if ( manager && manager != this.getResourceManager() ) { // у нас появился новый манагер
					// если у нас остались ресурсы, это ЖОПА!
					for ( var resource:Object in this._resources ) {
						throw new SecurityError( getErrorMessage( 5100 ), 5100 );
					}
					this._resourceManager = null;
				}
				this._addedToStage = true;
				this._stage = super.stage;
			}
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage_hack1(event:Event):void {
			this._addedToStage = false;
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage_hack2(event:Event):void {
			if ( !this._addedToStage ) { // нас опять добавили
				this._stage = null;
				// если у нас остались ресурсы, это ЖОПА!
				for ( var resource:Object in this._resources ) {
					throw new SecurityError( getErrorMessage( 5100 ), 5100 );
				}
				this._resourceManager = null;
			}
		}

	}

}

import by.blooddy.core.display.resource.ResourceDefinition;

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
	//  Constructor
	//
	//--------------------------------------------------------------------------

	public var count:uint = 0;

}