////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

	import platform.errors.ErrorsManager;
	import flash.errors.IllegalOperationError;

	import flash.ui.ContextMenu;

	//--------------------------------------------------------------------------
	//
	//  Override properties: InteractiveObject
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  contextMenu
	//----------------------------------

	/**
	 * @private
	 */
	public override function get contextMenu():ContextMenu {
		return null;
	}

	/**
	 * @private
	 */
	public override function set contextMenu(cm:ContextMenu):void {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}

	//----------------------------------
	//  mouseEnabled
	//----------------------------------

	/**
	 * @private
	 */
	public override function set mouseEnabled(enabled:Boolean):void {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}