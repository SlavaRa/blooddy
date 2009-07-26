////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

	import flash.errors.IllegalOperationError;

	import by.blooddy.core.managers.IResourceManagerOwner;
	import by.blooddy.core.managers.ResourceManager;

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
	 * @copy				by.blooddy.core.managers.IResourceManagerOwner#resourceManager
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