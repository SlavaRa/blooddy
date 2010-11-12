////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.utils;

import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class IntUtils {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * rotation is separate from addition to prevent recomputation
	 */
	public static inline function rol(a:Int, s:Int):Int {
		return ( a << s ) | ( a >>> ( 32 - s ) );
	}

	public static inline function ror(x:Int, n:Int):Int {
		return ( x << ( 32 - n ) ) | ( x >>> n );
	}

	public static inline function abs(x:Int):UInt {
		return ( x < 0 ? -x : x );
	}

}