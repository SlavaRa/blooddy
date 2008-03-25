////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.display {

	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import by.blooddy.platform.managers.IResourceManagerOwner;
	import by.blooddy.platform.net.ILoadable;
	import by.blooddy.platform.managers.ResourceBundleTrash;
	import by.blooddy.platform.managers.ResourceManager;
	import by.blooddy.platform.events.LoaderEvent;
	import flash.display.DisplayObject;
	import by.blooddy.platform.managers.IResourceBundle;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @eventType			platform.events.LoaderEvent.LOADER_INIT
	 */
	[Event(name="loaderInit", type="platform.events.LoaderEvent")]

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
	public class ResourceManagerOwnerSprite extends Sprite implements IResourceManagerOwner {

		private static const _TRASH:ResourceBundleTrash = new ResourceBundleTrash();

		private static const _MANAGER:ResourceManager = new ResourceManager();

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function ResourceManagerOwnerSprite() {
			super();
			super.addEventListener(Event.REMOVED_FROM_STAGE, this.handler_removedFromStage, false, int.MAX_VALUE);
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properies: IResourceManagerOwner
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _resourceManager:ResourceManager;

		/**
		 * @copy				platform.managers.IResourceManagerOwner#resourceManager
		 */
		public function get resourceManager():ResourceManager {
			if (!super.stage) throw new IllegalOperationError();
			if (!this._resourceManager) {
				var parent:DisplayObjectContainer = this;
				while ( ( parent = parent.parent ) && !( parent is IResourceManagerOwner ) );
				this._resourceManager = ( !parent ? _MANAGER : ( parent as IResourceManagerOwner ).resourceManager );
			}
			return this._resourceManager;
		}

		public function get trash():ResourceBundleTrash {
			return _TRASH;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function loadResource(bundleName:String):ILoadable {
			if (!this.stage) throw new IllegalOperationError();
			var manager:ResourceManager = this._resourceManager || this.resourceManager;
			var loader:ILoadable = manager.loadResourceBundle( bundleName );
			// диспатчим событие о том что началась загрузка
			super.dispatchEvent( new LoaderEvent(LoaderEvent.LOADER_INIT, true, false, loader) );
			return loader;
		}

		protected function hasResource(bundleName:String, resourceName:String):Boolean {
			if ( _TRASH.has(bundleName, resourceName) ) return true;
			else if ( super.stage ) {
				var manager:ResourceManager = this._resourceManager || this.resourceManager;
				return manager.hasResource( bundleName, resourceName );
			}
			return false;
		}

		protected function getResource(bundleName:String, resourceName:String):DisplayObject {
			if ( _TRASH.has(bundleName, resourceName) ) {
				return _TRASH.takeOut( bundleName, resourceName );
			} else if ( super.stage ) {
				var manager:ResourceManager = this._resourceManager || this.resourceManager;
				if ( manager.hasResource( bundleName, resourceName ) ) {
					return manager.getResource( bundleName, resourceName );
				}
			}
			return null;
		}

		protected function trashResource(bundleName:String, resourceName:String, object:DisplayObject):void {
			if (object.parent) {
				object.parent.removeChild( object );
			}
			_TRASH.takeIn( bundleName, resourceName, object );
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

	}

}