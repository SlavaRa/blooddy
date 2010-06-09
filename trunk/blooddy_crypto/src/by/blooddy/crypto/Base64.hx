////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto;

import by.blooddy.system.Memory;
import flash.Error;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class Base64 {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function encode(bytes:ByteArray, insertNewLines:Bool=false):String {
		return TMP.encode( bytes, insertNewLines );
	}

	public static function decode(str:String):ByteArray {
		return TMP.decode( str );
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

	public static inline function encode(bytes:ByteArray, insertNewLines:Bool=false):String {

		var len:UInt = bytes.length;
		var pos:UInt = bytes.position;
		var mem:ByteArray = Memory.memory;

		var rest:UInt = len % 3;
		var bytesLength:UInt = len - 3;

		bytes.position = len;
		bytes.writeUTFBytes( 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' );

		var resultLength:UInt = Std.int( len / 3 ) * 4 + ( rest > 0 ? 4 : 0 );
		bytes.length += resultLength + ( insertNewLines ? Std.int( resultLength / 76 ) : 0 );

		if ( bytes.length < 1024 ) bytes.length = 1024;
		Memory.memory = bytes;

		var i:UInt = 0;
		var j:UInt = len + 64;
		var chunk:Int;

		while ( i < bytesLength ) {

			chunk =	Memory.getByte( i++ ) << 16 |
					Memory.getByte( i++ ) << 8  |
					Memory.getByte( i++ )       ;

			Memory.setI32( j,
				Memory.getByte( len + (   chunk >>> 18          ) )       |
				Memory.getByte( len + ( ( chunk >>> 12 ) & 0x3F ) ) <<  8 |
				Memory.getByte( len + ( ( chunk >>> 6  ) & 0x3F ) ) << 16 |
				Memory.getByte( len + (   chunk          & 0x3F ) ) << 24
			);
			j += 4;

			if ( insertNewLines && i % 57 == 0 ) {
				Memory.setByte( j, 10 );
				j++;
			}

		}

		switch ( rest ) {

			case 1:
				chunk = Memory.getByte( i++ );
				Memory.setI32( j,
					Memory.getByte( len + (   chunk >>> 2      ) )      |
					Memory.getByte( len + ( ( chunk & 3 ) << 4 ) ) << 8 |
					15677 << 16
				);

			case 2:
				chunk =	Memory.getByte( i++ ) << 8 |
						Memory.getByte( i++ )      ;
				Memory.setI32( j,
					Memory.getByte( len + (   chunk >>> 10 )          )       |
					Memory.getByte( len + ( ( chunk >>>  4 ) & 0x3F ) ) <<  8 |
					Memory.getByte( len + ( ( chunk & 15 ) << 2 )     ) << 16 |
					61 << 24
				);

		}

		bytes.position = len + 64;
		var result:String = bytes.readUTFBytes( bytes.bytesAvailable );

		bytes.length = len;
		bytes.position = pos;
		Memory.memory = mem;
		
		return result;

	}

	public static inline function decode(str:String):ByteArray {

		var len:UInt = Std.int( str.length * 0.75 );
		var mem:ByteArray = Memory.memory;

		var bytes:ByteArray = new ByteArray();
		bytes.position = len;
		bytes.writeUTFBytes( '\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x3e\x40\x40\x40\x3f\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x40\x40\x40\x40\x40\x40\x40\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x40\x40\x40\x40\x40\x40\x1a\x1b\x1c\x1d\x1e\x1f\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f\x30\x31\x32\x33\x40\x40\x40\x40\x40' );
		bytes.writeUTFBytes( str );

		var bytesLength:UInt = bytes.length - 4;

		if ( bytes.length < 1024 ) bytes.length = 1024;
		Memory.memory = bytes;

		var i:UInt = len + 128;
		var j:UInt = 0;

		var insertNewLines:Bool = Memory.getByte( i + 76 ) == 10;

		var a:Int;
		var b:Int;
		var c:Int;
		var d:Int;

		while ( i < bytesLength ) {

			a = getByte( i++, len );
			b = getByte( i++, len );
			c = getByte( i++, len );
			d = getByte( i++, len );

			Memory.setByte( j++, ( a << 2 ) | ( b >> 4 ) );
			Memory.setByte( j++, ( b << 4 ) | ( c >> 2 ) );
			Memory.setByte( j++, ( c << 6 ) |   d        );
			
			if ( insertNewLines && j % 57 == 0 && Memory.getByte( i++ ) != 10 ) {
				throwError();
			}

		}

		if ( i != bytesLength ) throwError();

		a = getByte( i++, len );
		b = getByte( i++, len );
		Memory.setByte( j++, ( a << 2 ) | ( b >> 4 ) );

		c = getByte2( i++, len );
		if ( c != -1 ) {
			Memory.setByte( j++, ( b << 4 ) | ( c >> 2 ) );
			d = getByte2( i++, len );
			if ( d != -1 ) {
				Memory.setByte( j++, ( c << 6 ) | d );
			}
		} else {
			if ( getByte2( i++, len ) != -1 ) throwError();
		}

		bytes.length = j;
		bytes.position = 0;
		Memory.memory = mem;
		
		return bytes;
	}

	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static inline function getByte(index:UInt, offset:UInt):Int {
		var v:Int = Memory.getByte( index );
		if ( v & 0x80 != 0 ) throwError();
		v = Memory.getByte( offset + v );
		if ( v == 0x40 ) throwError();
		return v;
	}

	/**
	 * @private
	 */
	private static inline function getByte2(index:UInt, offset:UInt):Int {
		var v:Int = Memory.getByte( index );
		if ( v & 0x80 != 0 ) throwError();
		if ( v != 61 ) {
			v = Memory.getByte( offset + v );
			if ( v == 0x40 ) throwError();
		} else {
			v = -1;
		}
		return v;
	}

	/**
	 * @private
	 */
	private static inline function throwError():Void {
		Error.throwError( Error, 0 );
	}

}