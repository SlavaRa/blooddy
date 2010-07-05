////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image;

import by.blooddy.crypto.image.palette.IPalette;
import by.blooddy.crypto.image.palette.MedianCutPalette;
import by.blooddy.system.Memory;
import flash.display.BitmapData;
import flash.Error;
import flash.utils.ByteArray;
import flash.Vector;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class PNG8Encoder {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function encode(image:BitmapData, ?palette:IPalette=null, ?filter:UInt=0):ByteArray {
		if ( palette == null ) {
			palette = new MedianCutPalette( image );
		}
		return TMP.encode( image, palette, filter );
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

	public static inline function encode(image:BitmapData, palette:IPalette, filter:UInt):ByteArray {

		var mem:ByteArray = Memory.memory;

		var width:UInt = image.width;
		var height:UInt = image.height;

		var len:UInt = width * height + height;
		var len2:UInt = len + width;

		var colors:Vector<UInt> = palette.getColors();

		var bits:UInt;
		// Create output byte array
		var bytes:ByteArray = new ByteArray();
		var chunk:ByteArray = new ByteArray();

		// PNG signature
		PNGEncoderHelper.writeSignature( bytes );

		// IHDR
		PNGEncoderHelper.writeIHDR( bytes, chunk, width, height, 0x08, 0x03 );

		// PLTE
		// tRNS
		writeColors( bytes, chunk, colors );

		// IDAT
		if ( len2 < 1024 ) chunk.length = 1024;
		else chunk.length = len2;
		Memory.memory = chunk;
		if ( len < 17 ) Memory.fill( len, 17, 0x00 ); // если битмапка очень маленькая, то мы случайно могли наследить
		if ( image.transparent ) {
			switch ( filter ) {
				case PNGEncoderHelper.NONE:		writeNone( image, palette, len, true );
				case PNGEncoderHelper.SUB:		writeSub( image, palette, len, true );
				case PNGEncoderHelper.UP:		writeUp( image, palette, len, true );
				case PNGEncoderHelper.AVERAGE:	writeAverage( image, palette, len, true );
				case PNGEncoderHelper.PAETH:	writePaeth( image, palette, len, true );
				default:						Error.throwError( ArgumentError, 2008, 'filter' );
			}
		} else {
			switch ( filter ) {
				case PNGEncoderHelper.NONE:		writeNone( image, palette, len, false );
				case PNGEncoderHelper.SUB:		writeSub( image, palette, len, false );
				case PNGEncoderHelper.UP:		writeUp( image, palette, len, false );
				case PNGEncoderHelper.AVERAGE:	writeAverage( image, palette, len, false );
				case PNGEncoderHelper.PAETH:	writePaeth( image, palette, len, false );
				default:						Error.throwError( ArgumentError, 2008, 'filter' );
			}
		}
		Memory.memory = null;
		chunk.length = len;
		chunk.compress();
		chunk.position = 4;
		chunk.writeBytes( chunk );
		chunk.position = 0;
		chunk.writeUnsignedInt( 0x49444154 );
		PNGEncoderHelper.writeChunk( bytes, chunk );

		// tEXt
		//PNGEncoderHelper.writeTEXT( bytes, chunk, 'Software', 'by.blooddy.crypto.image.PNG8Encoder' );

		// IEND
		PNGEncoderHelper.writeIEND( bytes, chunk );

		Memory.memory = mem;

		chunk.clear();

		bytes.position = 0;

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
	private static inline function writeColors(bytes:ByteArray, chunk:ByteArray, colors:Vector<UInt>):Void {
		chunk.length = 1024 + 4;
		Memory.memory = chunk;
		var l:UInt = colors.length;

		var i:UInt = 4;
		var j:UInt = 4 + 3 * 256;
		var k:UInt = 0;
		var c:UInt;
		do {
			c = colors[ k ];
			// a
			Memory.setByte( j++, c >> 24 );
			// rgb
			Memory.setByte( i++, c >> 16 );
			Memory.setByte( i++, c >>  8 );
			Memory.setByte( i++, c       );
		} while ( ++k < l );
		Memory.memory = null;
		// PLTE
		chunk.position = 0;
		chunk.writeUnsignedInt( 0x504C5445 );
		chunk.length = 4 + 3 * l;
		PNGEncoderHelper.writeChunk( bytes, chunk );
		chunk.length = 1024 + 8;
		// tRNS
		chunk.position = 0;
		chunk.writeUnsignedInt( 0x74524E53 );
		chunk.writeBytes( chunk, 4 + 3 * 256, l );
		chunk.length = l + 4;
		PNGEncoderHelper.writeChunk( bytes, chunk );
	}
	

	/**
	 * @private
	 */
	private static inline function writeNone(image:BitmapData, palette:IPalette, offset:UInt, transparent:Bool):Void {
		var width:UInt = image.width;
		var height:UInt = image.height;
		var x:UInt, y:UInt = 0;
		var c:UInt;
		var hash:Array<Null<UInt>> = new Array<Null<UInt>>();
		var index;
		var i:UInt = 0;
		do {
			Memory.setByte( i++, PNGEncoderHelper.NONE );
			x = 0;
			do {
				c = ( transparent ? image.getPixel32( x, y ) : image.getPixel( x, y ) );
				index = hash[ c ];
				if ( index == null ) {
					hash[ c ] = index = palette.getIndexByColor( c );
				}
				Memory.setByte( i++, index );
			} while ( ++x < width );
		} while ( ++y < height );
	}

	/**
	 * @private
	 */
	private static inline function writeSub(image:BitmapData, palette:IPalette, offset:UInt, transparent:Bool):Void {
		var width:UInt = image.width;
		var height:UInt = image.height;
		var x:UInt, y:UInt = 0;
		var r:UInt, g:UInt, b:UInt;
		var r0:UInt, g0:UInt, b0:UInt;
		var a:UInt, a0:UInt = 0;
		var i:UInt = 0;
		do {
			Memory.setByte( i++, PNGEncoderHelper.SUB );
			if ( transparent ) {
				a0 = 0;
			}
			r0 = 0;
			g0 = 0;
			b0 = 0;
			x = 0;
			do {

				b = ( transparent ? image.getPixel32( x, y ) : image.getPixel( x, y ) );

				r = b >>> 16;
				Memory.setByte( i++, r - r0 );
				r0 = r;

				g = b >>>  8;
				Memory.setByte( i++, g - g0 );
				g0 = g;

				Memory.setByte( i++, b - b0 );
				b0 = b;

				if ( transparent ) {
					a = b >>> 24;
					Memory.setByte( i++, a - a0 );
					a0 = a;
				}

			} while ( ++x < width );
		} while ( ++y < height );
	}

	/**
	 * @private
	 */
	private static inline function writeUp(image:BitmapData, palette:IPalette, offset:UInt, transparent:Bool):Void {
		var width:UInt = image.width;
		var height:UInt = image.height;
		var x:UInt, y:UInt = 0;
		var c:UInt;
		var j:UInt;
		var i:UInt = 0;
		do {
			j = offset;
			Memory.setByte( i++, PNGEncoderHelper.UP );
			x = 0;
			do {
				c = ( transparent ? image.getPixel32( x, y ) : image.getPixel( x, y ) );
				Memory.setByte( i++, ( c >>> 16 ) - Memory.getByte( j + 2 ) );
				Memory.setByte( i++, ( c >>>  8 ) - Memory.getByte( j + 1 ) );
				Memory.setByte( i++,   c          - Memory.getByte( j     ) );
				if ( transparent ) {
					Memory.setByte( i++, ( c >>> 24 ) - Memory.getByte( j + 3 ) );
				}
				Memory.setI32( j, c );
				j += 4;
			} while ( ++x < width );
		} while ( ++y < height );
	}

	/**
	 * @private
	 */
	private static inline function writeAverage(image:BitmapData, palette:IPalette, offset:UInt, transparent:Bool):Void {
		var width:UInt = image.width;
		var height:UInt = image.height;
		var x:UInt, y:UInt = 0;
		var c:UInt;
		var r:UInt, g:UInt, b:UInt;
		var r0:UInt, g0:UInt, b0:UInt;
		var a:UInt, a0:UInt = 0;
		var j:UInt;
		var i:UInt = 0;
		do {
			j = offset;
			Memory.setByte( i++, PNGEncoderHelper.AVERAGE );
			if ( transparent ) {
				a0 = 0;
			}
			r0 = 0;
			g0 = 0;
			b0 = 0;
			x = 0;
			do {

				c = ( transparent ? image.getPixel32( x, y ) : image.getPixel( x, y ) );

				r = ( transparent ? ( c >> 16 ) & 0xFF : c >>> 16 );
				Memory.setByte( i++, r - ( ( r0 + Memory.getByte( j + 2 ) ) >>> 1 ) );
				r0 = r;

				g = ( c >>  8 ) & 0xFF;
				Memory.setByte( i++, g - ( ( g0 + Memory.getByte( j + 1 ) ) >>> 1 ) );
				g0 = g;

				b = ( c       ) & 0xFF;
				Memory.setByte( i++, b - ( ( b0 + Memory.getByte( j ) ) >>> 1 ) );
				b0 = b;

				if ( transparent ) {
					a =   c >>> 24;
					Memory.setByte( i++, a - ( ( a0 + Memory.getByte( j + 3 ) ) >>> 1 ) );
					a0 = a;
				}

				Memory.setI32( j, c );
				j += 4;

				
			} while ( ++x < width );
		} while ( ++y < height );
	}

	/**
	 * @private
	 */
	private static inline function writePaeth(image:BitmapData, palette:IPalette, offset:UInt, transparent:Bool):Void {
		var width:UInt = image.width;
		var height:UInt = image.height;
		var x:UInt, y:UInt = 0;
		var c:UInt, c0:UInt, c1:UInt;
		var r:UInt, g:UInt, b:UInt;
		var r0:UInt, g0:UInt, b0:UInt;
		var r1:UInt, g1:UInt, b1:UInt;
		var r2:UInt, g2:UInt, b2:UInt;
		var a:UInt, a0:UInt = 0, a1:UInt, a2:UInt = 0;
		var j:UInt;
		var i:UInt = 0;
		do {

			j = offset;
			Memory.setByte( i++, PNGEncoderHelper.PAETH );
			if ( transparent ) {
				a0 = 0;
				a2 = 0;
			}
			r0 = 0;
			r2 = 0;
			g0 = 0;
			g2 = 0;
			b0 = 0;
			b2 = 0;
			x = 0;
			do {

				c = ( transparent ? image.getPixel32( x, y ) : image.getPixel( x, y ) );

				r = ( transparent ? ( c >> 16 ) & 0xFF : c >>> 16 );
				r1 = Memory.getByte( j + 2 );
				Memory.setByte( i++, r - PNGEncoderHelper.paethPredictor( r0, r1, r2 ) );
				r0 = r;
				r2 = r1;

				g = ( c >> 8 ) & 0xFF;
				g1 = Memory.getByte( j + 1 );
				Memory.setByte( i++, g - PNGEncoderHelper.paethPredictor( g0, g1, g2 ) );
				g0 = g;
				g2 = g1;

				b = c & 0xFF;
				b1 = Memory.getByte( j     );
				Memory.setByte( i++, b - PNGEncoderHelper.paethPredictor( b0, b1, b2 ) );
				b0 = b;
				b2 = b1;

				if ( transparent ) {
					a = c >>> 24;
					a1 = Memory.getByte( j + 3 );
					Memory.setByte( i++, a - PNGEncoderHelper.paethPredictor( a0, a1, a2 ) );
					a0 = a;
					a2 = a1;
				}

				Memory.setI32( j, c );
				j += 4;

			} while ( ++x < width );
		} while ( ++y < height );
	}

}