////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.system;

import flash.utils.ByteArray;
import flash.system.ApplicationDomain;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class Memory {

	//--------------------------------------------------------------------------
	//
	//  Class properties
	//
	//--------------------------------------------------------------------------

	public static inline var memory( get_memory, set_memory ):ByteArray;

	/**
	 * @private
	 */
	private static inline function get_memory():ByteArray {
		return ApplicationDomain.currentDomain.domainMemory;
	}

	/**
	 * @private
	 */
	private static inline function set_memory(value:ByteArray):ByteArray {
		return ApplicationDomain.currentDomain.domainMemory = value;
	}

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function setByte(address:UInt, value:Int):Void {
		untyped __vmem_set__( 0, address, value );
	}

	public static inline function setI16(address:UInt, value:Int):Void {
		untyped __vmem_set__( 1, address, value );
	}

	public static inline function setI32(address:UInt, value:Int):Void {
		untyped __vmem_set__( 2, address, value );
	}

	public static inline function setFloat(address:UInt, value:Float):Void {
		untyped __vmem_set__( 3, address, value );
	}

	public static inline function setDouble(address:UInt, value:Float):Void {
		untyped __vmem_set__( 4, address, value );
	}

	public static inline function getByte(address:UInt):UInt {
		return untyped __vmem_get__( 0, address );
	}

	public static inline function getUI16(address:UInt):UInt {
		return untyped __vmem_get__( 1, address );
	}

	public static inline function getI32(address:UInt):Int {
		return untyped __vmem_get__( 2, address );
	}

	public static inline function getFloat(address:UInt):Float {
		return untyped __vmem_get__( 3, address );
	}

	public static inline function getDouble(address:UInt):Float {
		return untyped __vmem_get__( 4, address );
	}

	public static inline function signExtend1(value:Int):Int {
		return untyped __vmem_sign__( 0, value );
	}

	public static inline function signExtend8(value:Int):Int {
		return untyped __vmem_sign__( 1, value );
	}

	public static inline function signExtend16(value:Int):Int {
		return untyped __vmem_sign__( 2, value );
	}

}