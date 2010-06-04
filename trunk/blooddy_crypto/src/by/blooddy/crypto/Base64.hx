package by.blooddy.crypto;

import flash.Memory;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class Base64 {

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

	public static inline function encode(bytes:ByteArray, insertNewLines:Bool=false):String {

		var len:UInt = bytes.length;

		var rest:UInt = len % 3;
		var bytesLength:UInt = len - 3;

		bytes.position = len;
		bytes.writeMultiByte( 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/', 'us-ascii' );

		var resultLength:UInt = Std.int( len / 3 ) * 4 + ( rest > 0 ? 4 : 0 );
		bytes.length += resultLength + ( insertNewLines ? Std.int( resultLength / 76 ) : 0 );

		if ( bytes.length < 1024 ) bytes.length = 1024;
		Memory.select( bytes );

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
		
		return result;

	}

	public static inline function decode(str:String):ByteArray {
		return null;
	}

}