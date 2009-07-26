////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

	import by.blooddy.core.errors.getErrorMessage;
	
	import flash.display.Graphics;
	import flash.errors.IllegalOperationError;

	//--------------------------------------------------------------------------
	//
	//  Override properties: Sprite
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  graphics
	//----------------------------------

	[Deprecated(message="свойство запрещено")]
	/**
	 * @private
	 */
	public override function get graphics():Graphics {
		throw new IllegalOperationError( getErrorMessage( 2071 ), 2071 );
	}

	[Deprecated(message="метод запрещён")]
	/**
	 * @private
	 */
	public override function startDrag(lockCenter:Boolean = false, bounds:Rectangle = null):void {
		throw new IllegalOperationError( getErrorMessage( 2071 ), 2071 );
	}

	[Deprecated(message="метод запрещён")]
	/**
	 * @private
	 */
	public override function stopDrag():void {
		throw new IllegalOperationError( getErrorMessage( 2071 ), 2071 );
	}