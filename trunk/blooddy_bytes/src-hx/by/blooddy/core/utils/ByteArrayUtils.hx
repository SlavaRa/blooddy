////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils;

import by.blooddy.system.Memory;
import flash.Error;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class ByteArrayUtils {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function createByteArray(?length:UInt=0):ByteArray {
		var result:ByteArray = new ByteArray();
		if ( length != 0 ) result.length = length;
		return result;
	}

	public static inline function equals(b1:ByteArray, b2:ByteArray):Bool {
		var l:UInt = b1.length;
		var result:Bool = true;
		if ( l == b2.length ) {
			var mem:ByteArray = Memory.memory;
			var tmp:ByteArray = new ByteArray();
			tmp.writeBytes( b1 );
			tmp.writeBytes( b2 );
			if ( l + l < Memory.MIN_SIZE ) {
				tmp.length = Memory.MIN_SIZE;
			}
			Memory.memory = tmp;
			var e:UInt = l - ( l & 3 );
			var i:UInt = 0;
			do {
				if ( Memory.getI32( i ) != Memory.getI32( l + i ) ) {
					result = false;
					break;
				}
				i += 4;
			} while ( i < e );
			if ( result ) {
				while ( i < l ) {
					if ( Memory.getByte( i ) != Memory.getByte( l + i ) ) {
						result = false;
						break;
					}
					++i;
				}
			}
			Memory.memory = mem;
		} else {
			result = false;
		}
		return result;
	}

	public static inline function indexOfByte(bytes:ByteArray, value:UInt, ?startIndex:UInt=0):Int {
		if ( value > 0xFF ) {
			Error.throwError( RangeError, 0 );
		}
		var l:UInt = bytes.length;
		var result:Int = -1;
		if ( l - startIndex > 0 ) {
			var mem:ByteArray = Memory.memory;
			if ( l < Memory.MIN_SIZE ) {
				var tmp:ByteArray = new ByteArray();
				tmp.writeBytes( bytes );
				tmp.length = Memory.MIN_SIZE;
				Memory.memory = tmp;
			} else {
				Memory.memory = bytes;
			}
			var i:UInt = startIndex;
			do {
				if ( Memory.getByte( i ) == value ) {
					result = i;
					break;
				}
			} while ( ++i < l );
			Memory.memory = mem;
		}
		return result;
	}

	public static inline function indexOfBytes(bytes:ByteArray, value:ByteArray, ?startIndex:UInt=0):Int {
		var result:Int = -1;
		var l:UInt = bytes.length;
		var m:UInt = value.length;
		if ( m > 0 && l - m - startIndex > 0 ) {
			if ( m == 1 ) {
				result = indexOfByte( bytes, value[ 0 ], startIndex );
			} else {
				var mem:ByteArray = Memory.memory;
				var tmp:ByteArray = new ByteArray();
				tmp.writeBytes( value );
				tmp.writeBytes( bytes );
				if ( tmp.length < Memory.MIN_SIZE ) {
					tmp.length = Memory.MIN_SIZE;
				}
				Memory.memory = tmp;
				var i:UInt = m + startIndex;
				var j:UInt;
				var byte:UInt = Memory.getByte( 0 );
				do {
					if ( Memory.getByte( i ) == byte ) {
						j = 1;
						do {
							if ( Memory.getByte( i + j ) == Memory.getByte( j ) ) break;
						} while ( ++j < m );
						if ( j == m ) {
							result = i - j;
							break;
						}
					}
				} while ( ++i < l );
				Memory.memory = mem;
			}
		}
		return result;
	}

	public static inline function isUTFString(bytes:ByteArray):Bool {
		var l:UInt = bytes.length;
		var result:Bool = true;
		if ( l > 0 ) {
			var mem:ByteArray = Memory.memory;
			if ( l < Memory.MIN_SIZE ) {
				var tmp:ByteArray = new ByteArray();
				tmp.writeBytes( bytes );
				tmp.length = Memory.MIN_SIZE;
				Memory.memory = tmp;
			} else {
				Memory.memory = bytes;
			}
			var c:UInt;
			var i:UInt = (
				Memory.getByte( 0 ) == 0xEF &&
				Memory.getByte( 1 ) == 0xBB &&
				Memory.getByte( 2 ) == 0xBF
				?	3
				:	0
			);
			do {
				c = Memory.getByte( i );
				if (
					c == 0x00 ||
					c >= 0xF5 ||
					c == 0xC0 ||
					c == 0xC1
				) {
					result = false;
					break;
				}
			} while ( ++i < l );
			Memory.memory = mem;
		}
		return result;
	}

}