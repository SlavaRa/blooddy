////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

	import by.blooddy.core.errors.ErrorsManager;
	import flash.errors.IllegalOperationError;

	//--------------------------------------------------------------------------
	//
	//  Overriden properties: Data
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  name
	//----------------------------------

	/**
	 * @private
	 */
	public override function set name(value:String):void {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}