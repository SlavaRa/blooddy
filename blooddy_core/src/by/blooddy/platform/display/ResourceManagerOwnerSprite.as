////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.display {

	import by.blooddy.platform.managers.ResourceManager;

	import by.blooddy.platform.managers.IResourceManagerOwner;
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;

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
				this._resourceManager = ( !parent ? new ResourceManager() : ( parent as IResourceManagerOwner ).resourceManager );
			}
			return this._resourceManager;
		}

		private function handler_removedFromStage(event:Event):void {
			this._resourceManager = null;
		}

	}

}