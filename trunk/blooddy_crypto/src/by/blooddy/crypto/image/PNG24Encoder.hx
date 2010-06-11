////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image;

import by.blooddy.crypto.CRC32;
import by.blooddy.system.Memory;
import flash.display.BitmapData;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class PNG24Encoder {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Created a PNG image from the specified BitmapData
	 *
	 * @param	image	The BitmapData that will be converted into the PNG format.
	 * @return			a ByteArray representing the PNG encoded image data.
	 */			
	public static function encode(image:BitmapData):ByteArray {
		return TMP.encode( image );
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

	public static inline function encode(image:BitmapData):ByteArray {

		var mem:ByteArray = Memory.memory;

		var width:UInt = image.width;
		var height:UInt = image.height;

		// Create output byte array
		var bytes:ByteArray = new ByteArray();

		// Write PNG signature
		bytes.writeUnsignedInt( 0x89504e47 );
		bytes.writeUnsignedInt( 0x0D0A1A0A );

		var chunk:ByteArray = new ByteArray();

		// Build IHDR chunk
		chunk.length = 1024;
		Memory.memory = chunk;
		Memory.setI32( 0, 0x52444849 );
		setI32( 4, width );
		setI32( 8, height );
		Memory.setI32( 12, 0x00000608 ); // 32bit RGBA
		Memory.setByte( 16, 0 );
		Memory.memory = null;
		chunk.length = 17;
		writeChunk( bytes, chunk );

		// Build IDAT chunk
		var len:UInt = width * height * 4 + height;
		chunk.length = len;
		if ( len < 1024 ) chunk.length = 1024;
		else chunk.length = len;
		Memory.memory = chunk;
		var x:UInt, y:UInt, c:UInt;
		var i:UInt = 0;
		if ( image.transparent ) {
			y = 0;
			do {
				Memory.setByte( i++, 0 ); // no filter
				x = 0;
				do {
					c = image.getPixel32( x, y );
					Memory.setByte( i++, c >> 16 );
					Memory.setByte( i++, c >>  8 );
					Memory.setByte( i++, c       );
					Memory.setByte( i++, c >> 24 );
				} while ( ++x < width );
			} while ( ++y < height );
		} else {
			y = 0;
			do {
				Memory.setByte( i++, 0 ); // no filter
				x = 0;
				do {
					c = image.getPixel( x, y );
					Memory.setByte( i++, c >> 16 );
					Memory.setByte( i++, c >>  8 );
					Memory.setByte( i++, c       );
					Memory.setByte( i++, 0xFF    );
				} while ( ++x < width );
			} while ( ++y < height );
		}
		Memory.memory = null;
		chunk.length = len;
		chunk.compress();
		chunk.position = 4;
		chunk.writeBytes( chunk );
		chunk.position = 0;
		chunk.writeUnsignedInt( 0x49444154 );
		writeChunk( bytes, chunk );

		// Build IEND chunk
		chunk.length = 0;
		chunk.writeUnsignedInt( 0x49454E44 );
		writeChunk( bytes, chunk );

		Memory.memory = mem;

		chunk.clear();

		bytes.position = 0;

		return bytes;
	}

	/**
	 * @private
	 */
	private static inline function writeChunk(png:ByteArray, chunk:ByteArray):Void {
		png.writeUnsignedInt( chunk.length - 4 );
		png.writeBytes( chunk, 0 );
		png.writeUnsignedInt( CRC32.hash( chunk ) );

	}

	private static inline function setI32(address:UInt, value:Int):Void {
		Memory.setByte( address,     value >> 24 );
		Memory.setByte( address + 1, value >> 16 );
		Memory.setByte( address + 2, value >>  8 );
		Memory.setByte( address + 3, value       );
	}
	
}