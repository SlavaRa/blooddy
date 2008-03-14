////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

	import platform.errors.ErrorsManager;
	import flash.errors.IllegalOperationError;

	import platform.database.Data;

	//--------------------------------------------------------------------------
	//
	//  Overriden methods: DataContainer
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public override function addChild(child:Data):Data {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}

	/**
	 * @private
	 */
	public override function addChildAt(child:Data, index:int):Data {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}

	/**
	 * @private
	 */
	public override function removeChild(child:Data):Data {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}

	/**
	 * @private
	 */
	public override function removeChildAt(index:int):Data {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}