////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

	import platform.errors.ErrorsManager;
	import flash.errors.IllegalOperationError;

	import flash.geom.Point;

	import flash.text.TextSnapshot;

	import flash.display.DisplayObject;

	//--------------------------------------------------------------------------
	//
	//  Override properties: DisplayObjectContainer
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  mouseChildren
	//----------------------------------

	/**
	 * @private
	 */
	public override function set mouseChildren(enable:Boolean):void {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}

	//----------------------------------
	//  tabChildren
	//----------------------------------

	/**
	 * @private
	 */
	public override function set tabChildren(enable:Boolean):void {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}

	//----------------------------------
	//  numChildren
	//----------------------------------

	/**
	 * @private
	 */
	public override function get numChildren():int {
		return 0;
	}

	//----------------------------------
	//  textSnapshot
	//----------------------------------

	/**
	 * @private
	 */
	public override function get textSnapshot():TextSnapshot {
		throw new TextSnapshot();
	}

	//--------------------------------------------------------------------------
	//
	//  Override methods: DisplayObjectContainer
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public override function addChild(child:DisplayObject):DisplayObject {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}

	/**
	 * @private
	 */
	public override function addChildAt(child:DisplayObject, index:int):DisplayObject {
		throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
	}

	/**
	 * @private
	 */
	public override function contains(child:DisplayObject):Boolean {
		return false;
	}

	/**
	 * @private
	 */
	public override function getChildAt(index:int):DisplayObject {
		return super.getChildAt(-1);
	}

	/**
	 * @private
	 */
	public override function getChildByName(name:String):DisplayObject {
		return null;
	}

	/**
	 * @private
	 */
	public override function getChildIndex(child:DisplayObject):int {
		return super.getChildIndex(this);
	}

	/**
	 * @private
	 */
	public override function getObjectsUnderPoint(point:Point):Array {
		return new Array();
	}

	/**
	 * @private
	 */
	public override function removeChild(child:DisplayObject):DisplayObject {
		return super.removeChild( child ? this : null );
	}

	/**
	 * @private
	 */
	public override function removeChildAt(index:int):DisplayObject {
		return super.removeChildAt(-1);
	}

	/**
	 * @private
	 */
	public override function setChildIndex(child:DisplayObject, index:int):void {
		super.setChildIndex(this, -1);
	}

	/**
	 * @private
	 */
	public override function swapChildren(child1:DisplayObject, child2:DisplayObject):void {
		super.swapChildren(this, this);
	}

	/**
	 * @private
	 */
	public override function swapChildrenAt(index1:int, index2:int):void {
		super.swapChildrenAt(-1, -1);
	}