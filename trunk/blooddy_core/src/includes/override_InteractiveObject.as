////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

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

	[Deprecated( message="свойство запрещено" )]
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
		Error.throwError( IllegalOperationError, 3008 );
	}

	//----------------------------------
	//  mouseEnabled
	//----------------------------------

	/**
	 * @private
	 */
	public override function set mouseEnabled(enabled:Boolean):void {
		Error.throwError( IllegalOperationError, 3008 );
	}
