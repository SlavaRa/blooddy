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

	public static inline var memory( get_memory, set_memory ):ByteArray;

	private static inline function get_memory():ByteArray {
		return ApplicationDomain.currentDomain.domainMemory;
	}

	private static inline function set_memory(value:ByteArray):ByteArray {
		return ApplicationDomain.currentDomain.domainMemory = value;
	}

	public static inline function setByte(address:Int, value:Int):Void {
		untyped __vmem_set__( 0, address, value );
	}

	public static inline function setI16(address:Int, value:Int):Void {
		untyped __vmem_set__( 1, address, value );
	}

	public static inline function setI32(address:Int, value:Int):Void {
		untyped __vmem_set__( 2, address, value );
	}

	public static inline function setFloat(address:Int, value:Float):Void {
		untyped __vmem_set__( 3, address, value );
	}

	public static inline function setDouble(address:Int, value:Float):Void {
		untyped __vmem_set__( 4, address, value );
	}

	public static inline function getByte(address:Int):Int {
		return untyped __vmem_get__( 0, address );
	}

	public static inline function getUI16(address:Int):Int {
		return untyped __vmem_get__( 1, address );
	}

	public static inline function getI32(address:Int):Int {
		return untyped __vmem_get__( 2, address );
	}

	public static inline function getFloat(address:Int):Float {
		return untyped __vmem_get__( 3, address );
	}

	public static inline function getDouble(address:Int):Float {
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