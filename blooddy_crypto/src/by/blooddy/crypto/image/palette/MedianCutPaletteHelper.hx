////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image.palette;

import by.blooddy.system.Memory;
import by.blooddy.utils.ByteArrayUtils;
import flash.display.BitmapData;
import flash.Error;
import flash.Lib;
import flash.utils.ByteArray;
import flash.Vector;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class MedianCutPaletteHelper {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function createTable(image:BitmapData, ?maxColors:UInt=256):ByteArray {
		if ( maxColors < 2 || maxColors > 256 ) Error.throwError( RangeError, 2006 );
		if ( image.transparent ) {
			return TMP.createTable( image, maxColors, true );
		} else {
			return TMP.createTable( image, maxColors, false );
		}
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

	/**
	 * @private
	 */
	private static var BLOCK:UInt = 21;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function createTable(image:BitmapData, maxColors:UInt, transparent:Bool):ByteArray {
		
		//maxColors--; // сдвиг для ускорения проверки

		var width:UInt = image.width;
		var height:UInt = image.height;

		var len:UInt = width * height * 4;

		var colorsList:Vector<ByteArray> = new Vector<ByteArray>();

		var blockCount:UInt = 0;
		var blocks:ByteArray = ByteArrayUtils.createByteArray( BLOCK * maxColors + BLOCK );
		if ( blocks.length < 1024 ) blocks.length = 1024;

		var colors:ByteArray = new ByteArray();
		if ( len < 1024 ) colors.length = 1024;
		else colors.length = len;
		Memory.memory = colors;

		var c:UInt;
		var cx:UInt = ( transparent ? image.getPixel32( 1, 1 ) : image.getPixel( 1, 1 ) );

		var t:UInt;
		var x:UInt;
		var y:UInt = 0;

		var lminA:UInt = 0xFF000000;
		var lmaxA:UInt = ( transparent ? 0x00000000 : 0xFF000000 );
		var lminR:UInt = 0x00FF0000;
		var lmaxR:UInt = 0x00000000;
		var lminG:UInt = 0x0000FF00;
		var lmaxG:UInt = 0x00000000;
		var lminB:UInt = 0x000000FF;
		var lmaxB:UInt = 0x00000000;

		var i:UInt = 0;
		do {
			x = 0;
			do {

				c = ( transparent ? image.getPixel32( x, y ) : image.getPixel( x, y ) );
				if ( c == cx ) continue;
				cx = c;

				if ( transparent ) {
					t = c & 0xFF000000;
					if		( t < lminA ) lminA = t;
					else if	( t > lmaxA ) lmaxA = t;
				}

				t = c & 0x00FF0000;
				if		( t < lminR ) lminR = t;
				else if	( t > lmaxR ) lmaxR = t;

				t = c & 0x0000FF00;
				if		( t < lminG ) lminG = t;
				else if	( t > lmaxG ) lmaxG = t;

				t = c & 0x000000FF;
				if		( t < lminB ) lminB = t;
				else if	( t > lmaxB ) lmaxB = t;

				Memory.setI32( i, c );
				i += 4;

			} while ( ++x < width );
		} while ( ++y < height );

		Lib.trace( lminA + ' ' + lminR + ' ' + lminG + ' ' + lminB );
		Lib.trace( lmaxA + ' ' + lmaxR + ' ' + lmaxG + ' ' + lmaxB );
		
		Memory.memory = blocks;

		colors.length = i;

		writeBlock(
			blocks,
			colorsList.length,
			lminA, lminR, lminG, lminB,
			lmaxA, lmaxR, lmaxG, lmaxB,
			blockCount++,
			transparent
		);
		colorsList.push( colors );

		if ( Memory.getByte( 0 ) > 0 ) {

			var rminA:UInt = 0xFF000000;
			var rmaxA:UInt = ( transparent ? 0x00000000 : 0xFF000000 );
			var rminR:UInt;
			var rmaxR:UInt;
			var rminG:UInt;
			var rmaxG:UInt;
			var rminB:UInt;
			var rmaxB:UInt;

			var mask:UInt;
			var mid:UInt;

			var lcolors:ByteArray;
			var rcolors:ByteArray;
			
			while ( blockCount < maxColors ) {

				blockCount--; // последний сплитим

				if ( transparent ) {
					lminA = 0xFF000000;
					lmaxA = 0x00000000;
					rminA = 0xFF000000;
					rmaxA = 0x00000000;
				}

				lminR = 0x00FF0000;
				lmaxR = 0x00000000;
				rminR = 0x00FF0000;
				rmaxR = 0x00000000;

				lminB = 0x000000FF;
				lmaxB = 0x00000000;
				rminB = 0x000000FF;
				rmaxB = 0x00000000;

				lminG = 0x0000FF00;
				lmaxG = 0x00000000;
				rminG = 0x0000FF00;
				rmaxG = 0x00000000;

				mid = Memory.getI32( blockCount * BLOCK + 1 );
				mask = Memory.getI32( blockCount * BLOCK + 5 );

				colors = colorsList[ Memory.getI32( blockCount * BLOCK + 21 ) ];
				len = colors.length;
				colors.length <<= 1; // увеличиваем буфер под дополнительную палитру
				if ( colors.length < 1024 ) colors.length = 1024;

				Memory.memory = colors;

				i = 0;
				x = len;
				y = ( len << 1 ) - 4;
				do {

					c = Memory.getI32( i );

					if ( c & mask <= mid ) {

						if ( transparent ) {
							t = c & 0xFF000000;
							if ( t < lminA ) lminA = t;
							else if ( t > lmaxA ) lmaxA = t;
						}

						t = c & 0x00FF0000;
						if ( t < lminR ) lminR = t;
						else if ( t > lmaxR ) lmaxR = t;

						t = c & 0x0000FF00;
						if ( t < lminG ) lminG = t;
						else if ( t > lmaxG ) lmaxG = t;

						t = c & 0x000000FF;
						if ( t < lminB ) lminB = t;
						else if ( t > lmaxB ) lmaxB = t;

						Memory.setI32( x, c );
						x += 4;

					} else {

						if ( transparent ) {
							t = c & 0xFF000000;
							if ( t < rminA ) rminA = t;
							else if ( t > rmaxA ) rmaxA = t;
						}

						t = c & 0x00FF0000;
						if ( t < rminR ) rminR = t;
						else if ( t > rmaxR ) rmaxR = t;

						t = c & 0x0000FF00;
						if ( t < rminG ) rminG = t;
						else if ( t > rmaxG ) rmaxG = t;

						t = c & 0x000000FF;
						if ( t < rminB ) rminB = t;
						else if ( t > rmaxB ) rmaxB = t;

						y -= 4;
						Memory.setI32( y, c );

					}

					i += 4;
				} while ( i < len );

				Memory.memory = blocks;

				writeBlock(
					blocks,
					colorsList.length,
					lminA, lminR, lminG, lminB,
					lmaxA, lmaxR, lmaxG, lmaxB,
					blockCount++,
					transparent
				);

				if ( len != x ) {
					lcolors = new ByteArray();
					lcolors.writeBytes( colors, len, x - len );
					colorsList.push( lcolors );
				}

				writeBlock(
					blocks,
					colorsList.length,
					rminA, rminR, rminG, rminB,
					rmaxA, rmaxR, rmaxG, rmaxB,
					blockCount++,
					transparent
				);

				rcolors = new ByteArray();
				rcolors.writeBytes( colors, y );
				colorsList.push( rcolors );

			}

			blockCount += 2;

		}
		
		return null;
	}

	/**
	 * @private
	 */
	private static function writeBlock(
		blocks:ByteArray,
		blockID:UInt,
		minA:UInt, minR:UInt, minG:UInt, minB:UInt,
		maxA:UInt, maxR:UInt, maxG:UInt, maxB:UInt,
		blockCount:UInt,
		transparent:Bool
	):Void {
		var midA:UInt = ( transparent ? ( ( maxA + minA ) / 2 ) & 0xFF000000 : 0xFF000000 );
		var midR:UInt = 0;
		var midG:UInt = 0;
		var midB:UInt = 0;
		var count:UInt = 0;
		var mid:UInt = 0;
		var mask:UInt = 0;
		if ( midA > 0 ) {
			midR = ( ( maxR + minR ) >>> 1 ) & 0xFF0000;
			midG = ( ( maxG + minG ) >>> 1 ) & 0xFF00;
			midB = ( ( maxB + minB ) >>> 1 ) & 0xFF;
			var t:UInt = maxB - minB;
			if ( t > count ) {
				count = t;
				mid = midB;
				mask = 0x000000FF;
			}
			t = ( maxG - minG ) >>> 8;
			if ( t > count ) {
				count = t;
				mid = midG;
				mask = 0x0000FF00;
			}
			t = ( maxR - minR ) >>> 16;
			if ( t > count ) {
				count = t;
				mid = midR;
				mask = 0x00FF0000;
			}
			if ( transparent ) {
				t = ( maxA - minA ) >>> 24;
				if ( t > count ) {
					count = t;
					mid = midA;
					mask = 0xFF000000;
				}
			}
		}

		var i:UInt = 0;
		var l:UInt = blockCount * BLOCK;
		while ( i < l ) {
			if ( count < Memory.getByte( i ) ) {
				blocks.position = i + BLOCK;
				blocks.writeBytes( blocks, i, l - i );
				break;
			}
			i += BLOCK;
		};
		
		Lib.trace( cast ( ( midA | midR | midG | midB ) >>> 0 ).toString ( 16 ) );
		
		Memory.setByte( i     , count );
		Memory.setI32(  i +  1, mid );
		Memory.setI32(  i +  5, mask );
		Memory.setI32(  i +  9, midA | midR | midG | midB );
		Memory.setI32(  i + 13, minA | minR | minG | minB );
		Memory.setI32(  i + 17, maxA | maxR | maxG | maxB );
		Memory.setByte( i + 21, blockID );
		
	}

}