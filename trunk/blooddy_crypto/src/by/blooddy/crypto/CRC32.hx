////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto;

import by.blooddy.system.Memory;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	2.0
 */
class CRC32 {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function hash(bytes:ByteArray):UInt {
		return TMP.hash( bytes );
	}

}

/**
 * @private
 */
private class TMP {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function hash(bytes:ByteArray):UInt {

		var len:UInt = bytes.length;
		if ( len > 0 ) {

			var mem:ByteArray = Memory.memory;

			bytes.length += 256 * 4;

			Memory.memory = bytes;

			var c:UInt;
			var j:UInt;
			var i:UInt = 0;
			do {
				c = i;
				j = 0;
				do {
					if ( c & 1 == 1 ) {
						c = 0xEDB88320 ^ ( c >>> 1 );
					} else {
						c >>>= 1;
					}
				} while ( ++j < 8 );
				Memory.setI32( len + i * 4, c );
			} while ( ++i < 256 );

			c = 0xFFFFFFFF;

			i = 0;
			while ( i < len ) {
				c = Memory.getI32( len + ( ( ( c ^ Memory.getByte( i++ ) ) & 0xFF ) << 2 ) ) ^ ( c >>> 8 );
			}

			bytes.length = len;
			Memory.memory = mem;

			return c ^ 0xFFFFFFFF;

		} else {
			
			return 0;
			
		}
	}

}