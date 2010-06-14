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
	//  Class variables
	//
	//--------------------------------------------------------------------------

	private static inline var Z1:UInt = 64;
	private static inline var Z2:UInt = 128;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function encode(bytes:ByteArray, insertNewLines:Bool=false):String {

		var len:UInt = bytes.length;

		var mem:ByteArray = Memory.memory;

		var tmp:ByteArray = new ByteArray();
		tmp.writeUTFBytes( 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' );
		tmp.writeBytes( bytes );
		
		var rest:UInt = len % 3;
		var bytesLength:UInt = Z1 + len - rest;

		var resultLength:UInt = ( Std.int( len / 3 ) << 2 ) + ( rest > 0 ? 4 : 0 );
		tmp.length += resultLength + ( insertNewLines ? Std.int( resultLength / 76 ) : 0 );

		if ( tmp.length < 1024 ) tmp.length = 1024;
		Memory.memory = tmp;

		var i:UInt = Z1;
		var j:UInt = Z1 + len;
		var chunk:Int;

		while ( i < bytesLength ) {

			chunk =	Memory.getByte( i++ ) << 16 |
					Memory.getByte( i++ ) << 8  |
					Memory.getByte( i++ )       ;

			Memory.setI32( j,
				Memory.getByte(   chunk >>> 18          )       |
				Memory.getByte( ( chunk >>> 12 ) & 0x3F ) <<  8 |
				Memory.getByte( ( chunk >>> 6  ) & 0x3F ) << 16 |
				Memory.getByte(   chunk          & 0x3F ) << 24
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
					Memory.getByte(   chunk >>> 2      )      |
					Memory.getByte( ( chunk & 3 ) << 4 ) << 8 |
					15677 << 16
				);

			case 2:
				chunk =	Memory.getByte( i++ ) << 8 |
						Memory.getByte( i++ )      ;
				Memory.setI32( j,
					Memory.getByte(   chunk >>> 10          )       |
					Memory.getByte( ( chunk >>>  4 ) & 0x3F ) <<  8 |
					Memory.getByte( ( chunk & 15 ) << 2     ) << 16 |
					61 << 24
				);

		}

		tmp.position = Z1 + len;
		var result:String = tmp.readUTFBytes( tmp.bytesAvailable );

		Memory.memory = mem;

		tmp.clear();
		
		return result;

	}

	public static inline function decode(str:String):ByteArray {

		var len:UInt = Std.int( str.length * 0.75 );
		var mem:ByteArray = Memory.memory;

		var tmp:ByteArray = new ByteArray();
		tmp.writeUTFBytes( '\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x3e\x40\x40\x40\x3f\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x40\x40\x40\x40\x40\x40\x40\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x40\x40\x40\x40\x40\x40\x1a\x1b\x1c\x1d\x1e\x1f\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f\x30\x31\x32\x33\x40\x40\x40\x40\x40' );
		tmp.writeUTFBytes( str );

		var bytesLength:UInt = tmp.length - 4;

		if ( tmp.length < 1024 ) tmp.length = 1024;
		Memory.memory = tmp;

		var insertNewLines:Bool = Memory.getByte( Z2 + 76 ) == 10;

		var i:UInt = Z2;
		var j:UInt = Z2;

		var a:Int;
		var b:Int;
		var c:Int;
		var d:Int;

		while ( i < bytesLength ) {

			a = getByte( i++ );
			b = getByte( i++ );
			c = getByte( i++ );
			d = getByte( i++ );

			Memory.setByte( j++, ( a << 2 ) | ( b >> 4 ) );
			Memory.setByte( j++, ( b << 4 ) | ( c >> 2 ) );
			Memory.setByte( j++, ( c << 6 ) |   d        );
			
			if ( insertNewLines && j % 57 == 0 && Memory.getByte( i++ ) != 10 ) {
				throwError();
			}

		}

		if ( i != bytesLength ) throwError();

		a = getByte( i++ );
		b = getByte( i++ );
		Memory.setByte( j++, ( a << 2 ) | ( b >> 4 ) );

		c = getByte2( i++ );
		if ( c != -1 ) {
			Memory.setByte( j++, ( b << 4 ) | ( c >> 2 ) );
			d = getByte2( i++ );
			if ( d != -1 ) {
				Memory.setByte( j++, ( c << 6 ) | d );
			}
		} else {
			if ( getByte2( i++ ) != -1 ) throwError();
		}

		Memory.memory = mem;

		var bytes:ByteArray = new ByteArray();
		bytes.writeBytes( tmp, Z2, j - Z2 );
		bytes.position = 0;

		tmp.clear();

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
	private static inline function getByte(index:UInt):Int {
		var v:Int = Memory.getByte( index );
		if ( v & 0x80 != 0 ) throwError();
		v = Memory.getByte( v );
		if ( v == 0x40 ) throwError();
		return v;
	}

	/**
	 * @private
	 */
	private static inline function getByte2(index:UInt):Int {
		var v:Int = Memory.getByte( index );
		if ( v & 0x80 != 0 ) throwError();
		if ( v != 61 ) {
			v = Memory.getByte( v );
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