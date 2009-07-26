////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

	import by.blooddy.core.errors.getErrorMessage;
	
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

	[Deprecated(message="свойство запрещено")]
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
		throw new IllegalOperationError( getErrorMessage( 2071 ), 2071 );
	}

	//----------------------------------
	//  mouseEnabled
	//----------------------------------

	/**
	 * @private
	 */
	public override function set mouseEnabled(enabled:Boolean):void {
		throw new IllegalOperationError( getErrorMessage( 2071 ), 2071 );
	}