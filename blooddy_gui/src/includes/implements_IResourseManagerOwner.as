////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

	import flash.errors.IllegalOperationError;

	import platform.managers.IResourceManagerOwner;
	import platform.managers.ResourceManager;

	import flash.display.DisplayObjectContainer;

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
			var parent:DisplayObjectContainer = super.parent;
			while ( !( parent is IResourceManagerOwner ) || ( parent = parent.parent ) );
			this._resourceManager = ( !parent ? new ResourceManager() : ( parent as IResourceManagerOwner ).resourceManager );
		}
		return this._resourceManager;
	}