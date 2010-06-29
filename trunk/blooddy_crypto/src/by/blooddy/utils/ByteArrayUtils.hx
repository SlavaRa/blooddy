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
class ByteArrayUtils {

	public static inline function createByteArray(?length:UInt=0):ByteArray {
		var result:ByteArray = new ByteArray();
		result.length = length;
		return result;
	}

}