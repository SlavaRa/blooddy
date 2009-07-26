////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

	import by.blooddy.core.errors.ErrorsManager;
	import flash.errors.IllegalOperationError;

	import by.blooddy.core.database.Data;

	//--------------------------------------------------------------------------
	//
	//  Overriden methods: DataContainer
	//
	//--------------------------------------------------------------------------

	[Deprecated(message="метод запрещён")]
	/**
	 * @private
	 */
	public override function addChild(child:Data):Data {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}

	[Deprecated(message="метод запрещён")]
	/**
	 * @private
	 */
	public override function addChildAt(child:Data, index:int):Data {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}

	[Deprecated(message="метод запрещён")]
	/**
	 * @private
	 */
	public override function removeChild(child:Data):Data {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}

	[Deprecated(message="метод запрещён")]
	/**
	 * @private
	 */
	public override function removeChildAt(index:int):Data {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}