////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

	import platform.errors.ErrorsManager;
	import flash.errors.IllegalOperationError;

	import flash.display.Graphics;

	//--------------------------------------------------------------------------
	//
	//  Override properties: Sprite
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  graphics
	//----------------------------------

	/**
	 * @private
	 */
	public override function get graphics():Graphics {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}