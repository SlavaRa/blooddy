package by.blooddy.crypto;

import flash.Memory;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	2.0
 */
class CRC32 {

	public static function hash(bytes:ByteArray):UInt {
		return TMP.hash( bytes );
	}

}

private class TMP {

	public static inline function hash(bytes:ByteArray):UInt {

		var len:UInt = bytes.length;
		var pos:UInt = bytes.position;

		bytes.length += 256 * 4;

		Memory.select( bytes );

		var i:UInt;
		var j:UInt;
		var c:UInt;
		for ( i in 0...256 ) {
			c = i;
			for ( j in 0...8 ) {
				if ( c & 1 == 1 ) {
					c = 0xEDB88320 ^ ( c >>> 1 );
				} else {
					c >>>= 1;
				}
			}
			Memory.setI32( len + i * 4, c );
		}

		c = 0xFFFFFFFF;

		for ( i in 0...len ) {
			c = Memory.getI32( len + ( ( c ^ Memory.getByte( i ) ) & 0xFF ) * 4 ) ^ ( c >>> 8 );
		}

		bytes.length = len;
		bytes.position = pos;

		return c ^ 0xFFFFFFFF;
		
	}
	
}