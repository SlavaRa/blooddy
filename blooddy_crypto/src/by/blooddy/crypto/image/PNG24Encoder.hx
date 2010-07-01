////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image;

import by.blooddy.crypto.CRC32;
import by.blooddy.system.Memory;
import by.blooddy.utils.ByteArrayUtils;
import flash.display.BitmapData;
import flash.Error;
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
	public static function encode(image:BitmapData, ?filter:UInt=0):ByteArray {
		return TMP.encode( image, filter );
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

	public static inline var NONE:UInt =	0;

	public static inline var SUB:UInt =		1;

	public static inline var UP:UInt =		2;

	public static inline var AVERAGE:UInt =	3;

	public static inline var PAETH:UInt =	4;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function encode(image:BitmapData, filter:UInt):ByteArray {

		var mem:ByteArray = Memory.memory;

		var width:UInt = image.width;
		var height:UInt = image.height;

		var len:UInt = ( ( width * height ) * ( image.transparent ? 4 : 3 ) ) + height;
		var len2:UInt = len + width * 4;

		// Create output byte array
		var bytes:ByteArray = new ByteArray();

		// PNG signature
		bytes.writeUnsignedInt( 0x89504e47 );
		bytes.writeUnsignedInt( 0x0D0A1A0A );

		var chunk:ByteArray = ByteArrayUtils.createByteArray( len2 );

		// IHDR
		chunk.writeUnsignedInt( 0x49484452 );
		chunk.writeUnsignedInt( width );
		chunk.writeUnsignedInt( height );
		chunk.writeByte( 0x08 );     // Bit depth
		chunk.writeByte( image.transparent ? 0x06 : 0x02 );     // Colour type
		//chunk.writeByte( 0x00 );     // Compression method
		//chunk.writeByte( 0x00 );     // Filter method
		//chunk.writeByte( 0x00 );     // Interlace method
		chunk.length = 17;
		writeChunk( bytes, chunk );

		// IDAT
		if ( len2 < 1024 ) chunk.length = 1024;
		else chunk.length = len2;
		Memory.memory = chunk;
		if ( len < 17 ) Memory.fill( len, 17, 0x00 ); // если битмапка очень маленькая, то мы случайно могли наследить
		switch ( filter ) {
			case NONE:		writeNone( image );
			case SUB:		writeSub( image );
			case UP:		writeUp( image, len );
			case AVERAGE:	writeAverage( image, len );
			case PAETH:		writePaeth( image, len );
			default:
				Error.throwError( ArgumentError, 2008, 'filter' );
		}
		Memory.memory = null;
		chunk.length = len;
		chunk.compress();
		chunk.position = 4;
		chunk.writeBytes( chunk );
		chunk.position = 0;
		chunk.writeUnsignedInt( 0x49444154 );
		writeChunk( bytes, chunk );

		// tEXt
		writeTextChunk( bytes, chunk, 'Software', 'by.blooddy.crypto.image.PNG24Encoder' );

		// IEND
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
	private static inline function writeChunk(bytes:ByteArray, chunk:ByteArray):Void {
		bytes.writeUnsignedInt( chunk.length - 4 );
		bytes.writeBytes( chunk, 0 );
		bytes.writeUnsignedInt( CRC32.hash( chunk ) );
	}

	/**
	 * @private
	 */
	private static inline function writeTextChunk(bytes:ByteArray, chunk:ByteArray, keyword:String, text:String):Void {
		chunk.length = 0;
		chunk.writeUnsignedInt( 0x74455874 );
		chunk.writeMultiByte( keyword, 'latin-1' );
		chunk.writeByte( 0 );
		chunk.writeMultiByte( text, 'latin-1' );
		writeChunk( bytes, chunk );
	}

	/**
	 * @private
	 */
	private static inline function writeNone(image:BitmapData):Void {
		var width:UInt = image.width;
		var height:UInt = image.height;
		var x:UInt, y:UInt = 0;
		var c:UInt;
		var i:UInt = 0;
		if ( image.transparent ) {
			if ( width >= 64 ) { // для широких картинок быстрее копировать целиком ряды байтов
				width <<= 2;
				var bmp:ByteArray = image.getPixels( image.rect );
				var tmp:ByteArray = Memory.memory;
				tmp.position = 0;
				x = 0;
				do {
					tmp.writeBytes( bmp, y * width, width );
					i = x + width;
					do {
						Memory.setByte( i, Memory.getByte( i - 4 ) );
						i -= 4;
					} while ( i > x );
					Memory.setByte( x, NONE );
					x += width + 1;
					++tmp.position;
				} while ( ++y < height );
			} else {
				do {
					Memory.setByte( i++, NONE );
					x = 0;
					do {
						c = image.getPixel32( x, y );
						Memory.setByte( i++, c >> 16 );
						Memory.setByte( i++, c >>  8 );
						Memory.setByte( i++, c       );
						Memory.setByte( i++, c >> 24 );
					} while ( ++x < width );
				} while ( ++y < height );
			}
		} else {
			do {
				Memory.setByte( i++, NONE );
				x = 0;
				do {
					c = image.getPixel( x, y );
					Memory.setByte( i++, c >> 16 );
					Memory.setByte( i++, c >>  8 );
					Memory.setByte( i++, c       );
				} while ( ++x < width );
			} while ( ++y < height );
		}
	}

	/**
	 * @private
	 */
	private static inline function writeSub(image:BitmapData):Void {
		var width:UInt = image.width;
		var height:UInt = image.height;
		var x:UInt, y:UInt = 0;
		var r:UInt, g:UInt, b:UInt;
		var r0:UInt, g0:UInt, b0:UInt;
		var i:UInt = 0;
		if ( image.transparent ) {
			var a:UInt, a0:UInt;
			do {
				Memory.setByte( i++, SUB );
				a0 = 0;
				r0 = 0;
				g0 = 0;
				b0 = 0;
				x = 0;
				do {

					b = image.getPixel32( x, y );

					a = b >>> 24;
					r = b >>> 16;
					g = b >>>  8;
					
					Memory.setByte( i++, r - r0 );
					Memory.setByte( i++, g - g0 );
					Memory.setByte( i++, b - b0 );
					Memory.setByte( i++, a - a0 );

					a0 = a;
					r0 = r;
					g0 = g;
					b0 = b;
					
				} while ( ++x < width );
			} while ( ++y < height );
		} else {
			do {
				Memory.setByte( i++, SUB );
				r0 = 0;
				g0 = 0;
				b0 = 0;
				x = 0;
				do {

					b = image.getPixel( x, y );

					r = b >>> 16;
					g = b >>>  8;
					
					Memory.setByte( i++, r - r0 );
					Memory.setByte( i++, g - g0 );
					Memory.setByte( i++, b - b0 );

					r0 = r;
					g0 = g;
					b0 = b;
					
				} while ( ++x < width );
			} while ( ++y < height );
		}
	}

	/**
	 * @private
	 */
	private static inline function writeUp(image:BitmapData, offset:UInt):Void {
		var width:UInt = image.width;
		var height:UInt = image.height;
		var x:UInt, y:UInt = 0;
		var c:UInt;
		var j:UInt;
		var i:UInt = 0;
		if ( image.transparent ) {
			do {
				j = offset;
				Memory.setByte( i++, UP );
				x = 0;
				do {
					c = image.getPixel32( x, y );
					Memory.setByte( i++, ( c >>> 16 ) - Memory.getByte( j + 2 ) );
					Memory.setByte( i++, ( c >>>  8 ) - Memory.getByte( j + 1 ) );
					Memory.setByte( i++,   c          - Memory.getByte( j     ) );
					Memory.setByte( i++, ( c >>> 24 ) - Memory.getByte( j + 3 ) );
					Memory.setI32( j, c );
					j += 4;
				} while ( ++x < width );
			} while ( ++y < height );
		} else {
			do {
				j = offset;
				Memory.setByte( i++, UP );
				x = 0;
				do {
					c = image.getPixel( x, y );
					Memory.setByte( i++, ( c >>> 16 ) - Memory.getByte( j + 2 ) );
					Memory.setByte( i++, ( c >>>  8 ) - Memory.getByte( j + 1 ) );
					Memory.setByte( i++,   c          - Memory.getByte( j     ) );
					Memory.setI32( j, c );
					j += 4;
				} while ( ++x < width );
			} while ( ++y < height );
		}
	}

	/**
	 * @private
	 */
	private static inline function writeAverage(image:BitmapData, offset:UInt):Void {
		var width:UInt = image.width;
		var height:UInt = image.height;
		var x:UInt, y:UInt = 0;
		var c:UInt;
		var r:UInt, g:UInt, b:UInt;
		var r0:UInt, g0:UInt, b0:UInt;
		var j:UInt;
		var i:UInt = 0;
		if ( image.transparent ) {
			var a:UInt, a0:UInt;
			do {
				j = offset;
				Memory.setByte( i++, AVERAGE );
				a0 = 0;
				r0 = 0;
				g0 = 0;
				b0 = 0;
				x = 0;
				do {

					c = image.getPixel32( x, y );

					a =   c >>> 24        ;
					r = ( c >> 16 ) & 0xFF;
					g = ( c >>  8 ) & 0xFF;
					b = ( c       ) & 0xFF;

					Memory.setByte( i++, r - ( ( r0 + Memory.getByte( j + 2 ) ) >>> 1 ) );
					Memory.setByte( i++, g - ( ( g0 + Memory.getByte( j + 1 ) ) >>> 1 ) );
					Memory.setByte( i++, b - ( ( b0 + Memory.getByte( j     ) ) >>> 1 ) );
					Memory.setByte( i++, a - ( ( a0 + Memory.getByte( j + 3 ) ) >>> 1 ) );

					Memory.setI32( j, c );
					j += 4;

					a0 = a;
					r0 = r;
					g0 = g;
					b0 = b;
					
				} while ( ++x < width );
			} while ( ++y < height );
		} else {
			do {
				j = offset;
				Memory.setByte( i++, AVERAGE );
				r0 = 0;
				g0 = 0;
				b0 = 0;
				x = 0;
				do {

					c = image.getPixel( x, y );

					r =   c >>> 16         ;
					g = ( c >>   8 ) & 0xFF;
					b = ( c        ) & 0xFF;

					Memory.setByte( i++, r - ( ( r0 + Memory.getByte( j + 2 ) ) >>> 1 ) );
					Memory.setByte( i++, g - ( ( g0 + Memory.getByte( j + 1 ) ) >>> 1 ) );
					Memory.setByte( i++, b - ( ( b0 + Memory.getByte( j     ) ) >>> 1 ) );

					Memory.setI32( j, c );
					j += 4;

					r0 = r;
					g0 = g;
					b0 = b;
					
				} while ( ++x < width );
			} while ( ++y < height );
		}
	}

	/**
	 * @private
	 */
	private static inline function writePaeth(image:BitmapData, offset:UInt):Void {
		var width:UInt = image.width;
		var height:UInt = image.height;
		var x:UInt, y:UInt = 0;
		var c:UInt, c0:UInt, c1:UInt;
		var r:UInt, g:UInt, b:UInt;
		var r0:UInt, g0:UInt, b0:UInt;
		var r1:UInt, g1:UInt, b1:UInt;
		var r2:UInt, g2:UInt, b2:UInt;
		var j:UInt;
		var i:UInt = 0;
		if ( image.transparent ) {
			var a:UInt, a0:UInt, a1:UInt, a2:UInt;
			do {

				j = offset;
				Memory.setByte( i++, PAETH );
				a0 = 0;
				r0 = 0;
				g0 = 0;
				b0 = 0;
				a2 = 0;
				r2 = 0;
				g2 = 0;
				b2 = 0;
				x = 0;
				do {

					c = image.getPixel32( x, y );

					a =   c >>> 24         ;
					r = ( c >>  16 ) & 0xFF;
					g = ( c >>   8 ) & 0xFF;
					b =   c          & 0xFF;

					a1 = Memory.getByte( j + 3 );
					r1 = Memory.getByte( j + 2 );
					g1 = Memory.getByte( j + 1 );
					b1 = Memory.getByte( j     );
					
					Memory.setByte( i++, r - paethPredictor( r0, r1, r2 ) );
					Memory.setByte( i++, g - paethPredictor( g0, g1, g2 ) );
					Memory.setByte( i++, b - paethPredictor( b0, b1, b2 ) );
					Memory.setByte( i++, a - paethPredictor( a0, a1, a2 ) );

					Memory.setI32( j, c );
					j += 4;

					a0 = a;
					r0 = r;
					g0 = g;
					b0 = b;
					a2 = a1;
					r2 = r1;
					g2 = g1;
					b2 = b1;
					
				} while ( ++x < width );
			} while ( ++y < height );
		} else {
			do {
				j = offset;
				Memory.setByte( i++, PAETH );
				r0 = 0;
				g0 = 0;
				b0 = 0;
				r2 = 0;
				g2 = 0;
				b2 = 0;
				x = 0;
				do {

					c = image.getPixel( x, y );

					r =   c >>> 16         ;
					g = ( c >>   8 ) & 0xFF;
					b =   c          & 0xFF;

					r1 = Memory.getByte( j + 2 );
					g1 = Memory.getByte( j + 1 );
					b1 = Memory.getByte( j     );
					
					Memory.setByte( i++, r - paethPredictor( r0, r1, r2 ) );
					Memory.setByte( i++, g - paethPredictor( g0, g1, g2 ) );
					Memory.setByte( i++, b - paethPredictor( b0, b1, b2 ) );

					Memory.setI32( j, c );
					j += 4;

					r0 = r;
					g0 = g;
					b0 = b;
					r2 = r1;
					g2 = g1;
					b2 = b1;
					
				} while ( ++x < width );
			} while ( ++y < height );
		}
	}

	/**
	 * @private
	 */
	private static inline function paethPredictor(a:UInt, b:UInt, c:UInt):UInt {
		var p:Int = a + b - c;
		var pa:UInt = abs( p - a );
		var pb:UInt = abs( p - b );
		var pc:UInt = abs( p - c );
		if ( pa <= pb && pa <= pc ) {
			return a;
		} else if ( pb <= pc ) {
			return b;
		} else {
			return c;
		}
	}

	/**
	 * @private
	 */
	private static inline function abs(v:Int):UInt {
		return ( v < 0 ? -v : v );
	}

}