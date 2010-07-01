////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image.palette;
import by.blooddy.system.Memory;
import flash.display.BitmapData;
import flash.Error;
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
		return TMP.createTable( image, maxColors );
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
	private static inline var BLOCK:UInt = 21;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function createTable(image:BitmapData, maxColors:UInt):ByteArray {
		if ( maxColors < 2 || maxColors > 256 ) Error.throwError( RangeError, 2006 );
		
		//maxColors--; // сдвиг для ускорения проверки

		var width:UInt = image.width;
		var height:UInt = image.height;

		var len:UInt = width * height * 4;

		var blockList:Vector<ByteArray> = new Vector<ByteArray>();
		var blockCount:UInt = 0;
		var blocks:ByteArray = new ByteArray();
		blocks.length = BLOCK * maxColors;

		var tmp:ByteArray = new ByteArray();
		if ( len < 1024 ) tmp.length = 1024;
		else tmp.length = len;
		Memory.memory = tmp;

		var c:UInt;
		var cx:UInt = image.getPixel32( 1, 1 );

		var t:UInt;
		var x:UInt;
		var y:UInt = 0;

		var lminA:UInt = 0xFF000000;
		var lminR:UInt = 0x00FF0000;
		var lminG:UInt = 0x0000FF00;
		var lminB:UInt = 0x000000FF;

		var lmaxA:UInt = 0x00000000;
		var lmaxR:UInt = 0x00000000;
		var lmaxG:UInt = 0x00000000;
		var lmaxB:UInt = 0x00000000;

		var i:UInt = 0;
		do {
			x = 0;
			do {

				c = image.getPixel32( x, y );
				if ( c == cx ) continue;
				cx = c;

				t = c & 0xFF000000;
				if ( t < lminA ) lminA = t;
				if ( t > lmaxA ) lmaxA = t;

				t = c & 0x00FF0000;
				if ( t < lminR ) lminR = t;
				if ( t > lmaxR ) lmaxR = t;

				t = c & 0x0000FF00;
				if ( t < lminG ) lminG = t;
				if ( t > lmaxG ) lmaxG = t;

				t = c & 0x000000FF;
				if ( t < lminB ) lminB = t;
				if ( t > lmaxB ) lmaxB = t;

				Memory.setI32( i, c );
				i += 4;

			} while ( ++x < width );
		} while ( ++y < height );

		
		Memory.memory = blocks;

		writeBlock(
			blockCount++,
			lminA, lminR, lminG, lminB,
			lmaxA, lmaxR, lmaxG, lmaxB
		);

		
		
		
		return null;
	}

	/**
	 * @private
	 */
	private static inline function writeBlock(
		blockCount:UInt,
		minA:UInt, minR:UInt, minG:UInt, minB:UInt,
		maxA:UInt, maxR:UInt, maxG:UInt, maxB:UInt
	):Void {
		var midA:UInt = Std.int( ( maxA + minA ) / 2 ) & 0xFF000000;
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
			t = ( maxA - minA ) >>> 24;
			if ( t > count ) {
				count = t;
				mid = midA;
				mask = 0xFF000000;
			}
		}

		var i:UInt = 0;
		var l:UInt = blockCount * BLOCK;
		do {
			if ( count < Memory.getByte( i ) ) {
				break;
			}
			i += BLOCK;
		} while ( i < l );

		Memory.setByte( i     , count );
		Memory.setI32(  i +  1, mid );
		Memory.setI32(  i +  5, mask );
		Memory.setI32(  i +  9, midA | midR | midG | midB );
		Memory.setI32(  i + 13, minA | minR | minG | minB );
		Memory.setI32(  i + 17, maxA | maxR | maxG | maxB );
		
	}

}