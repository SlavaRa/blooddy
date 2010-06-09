////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image;

import by.blooddy.system.Memory;
import flash.display.BitmapData;
import flash.Lib;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class JPEGEncoder {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function encode(image:BitmapData, ?quality:UInt=60):ByteArray {
		return TMP.encode( image, quality );
	}

}

/**
 * @private
 */
private class TMP {

	private static inline var Z1:UInt = 4096;
	private static inline var Z2:UInt = Z1 + 512 * 3;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function encode(image:BitmapData, quality:UInt):ByteArray {

		var mem:ByteArray = Memory.memory;

		var width:UInt = image.width;
		var height:UInt = image.height;

		var bytes:ByteArray = new ByteArray();
		var len:UInt = width * height * 3;

		bytes.position = Z2;

		bytes.writeBytes( JPEGTable.getTable( quality ) );
		
		Memory.memory = bytes;

		// Add JPEG headers
		Memory.setI16( 0, 0xD8FF ); // SOI
		writeAPP0();
		writeDQT();
		writeSOF0( image.width, image.height );
		writeDHT();
		writeSOS();
		
		// Encode 8x8 macroblocks
		var DCY:Float = 0;
		var DCU:Float = 0;
		var DCV:Float = 0;

		var x:UInt;
		var y:UInt;
		
		y = 0;
		do {
			x = 0;
			do {
				rgb2yuv( image, x, y );
				//DCY = processDU(YDU, fdtbl_Y, DCY, YDC_HT, YAC_HT);
				//DCU = processDU(UDU, fdtbl_UV, DCU, UVDC_HT, UVAC_HT);
				//DCV = processDU(VDU, fdtbl_UV, DCV, UVDC_HT, UVAC_HT);
				x += 8;
			} while ( x < width );
			y += 8;
		} while ( y < height );

		// Do the bit alignment of the EOI marker
		//if ( bytepos >= 0 )
		//{
			//var fillbits:BitString = new BitString();
			//fillbits.len = bytepos+1;
			//fillbits.val = (1<<(bytepos+1))-1;
			//writeBits(fillbits);
		//}
		//bytes.writeShort(0xFFD9); //EOI
//
		bytes.length = 607;

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
	private static inline function writeAPP0():Void {
		Memory.setI16(	2,	0xE0FF		);	// marker
		Memory.setI16(	4,	0x1000		);	// length
		Memory.setI32(	6,	0x4649464A	);	// JFIF
		Memory.setByte( 10,	0x00		);	//
		Memory.setI16(	11,	0x0101		);	// version
		Memory.setByte( 13,	0x00		);	// xyunits
		Memory.setI32(	14,	0x01000100	);	// density
		Memory.setI16(	18, 0x0000		);	// thumbn
	}

	/**
	 * @private
	 */
	private static inline function writeDQT():Void {
		Memory.setI16(	20,	0xDBFF		);	// marker
		Memory.setI16(	22,	0x8400		);	// length

		var bytes:ByteArray = Memory.memory;
		bytes.position = 24;
		bytes.writeBytes( bytes, Z2, 130 );

		Memory.setByte( 24,	0x00		);
		Memory.setByte( 89,	0x01		);
	}
	
	/**
	 * @private
	 */
	private static inline function writeSOF0(width:UInt, height:UInt):Void {
		Memory.setI16(	154,	0xC0FF		);	// marker
		Memory.setI16(	156,	0x1100		);	// length, truecolor YUV JPG
		Memory.setByte(	158,	0x08		);	// precision
		Memory.setI32(	159,					// height, width
			( ( ( height >> 8 ) & 0xFF )       ) |
			( ( ( height      ) & 0xFF ) << 8  ) |
			( ( ( width >> 8  ) & 0xFF ) << 16 ) |
			( ( ( width       ) & 0xFF ) << 24 )
		);
		Memory.setByte(	163,	0x03		);	// nrofcomponents
		Memory.setI32(	164,	0x00001101	);	// IdY, HVY, QTY
		Memory.setI32(	167,	0x00011102	);	// IdU, HVU, QTU
		Memory.setI32(	170,	0x00011103	);	// IdV, HVV, QTV
	}

	/**
	 * @private
	 */
	private static inline function writeDHT():Void {
		Memory.setI16(	173,	0xC4FF		);	// marker
		Memory.setI16(	175,	0xA201		);	// length

		var bytes:ByteArray = Memory.memory;
		bytes.position = 177;
		bytes.writeBytes( bytes, Z2 + 1154, 416 );

		Memory.setByte(	177,	0x00		);	// HTYDCinfo
		Memory.setByte(	206,	0x10		);	// HTYACinfo
		Memory.setByte(	385,	0x01		);	// HTUDCinfo
		Memory.setByte(	414,	0x11		);	// HTUACinfo
	}

	/**
	 * @private
	 */
	private static inline function writeSOS():Void {
		Memory.setI16(	593,	0xDAFF		);	// marker
		Memory.setI16(	595,	0x0C00		);	// length
		Memory.setByte(	597,	0x03		);	// nrofcomponents
		Memory.setI16(	598,	0x0001		);	// IdY, HTY
		Memory.setI16(	600,	0x1102		);	// IdU, HTU
		Memory.setI16(	602,	0x1103		);	// IdV, HTV
		Memory.setI32(	604,	0x00003f00	);	// Ss, Se, Bf
	}

	/**
	 * @private
	 */
	private static inline function rgb2yuv(img:BitmapData, xpos:UInt, ypos:UInt):Void {

		var pos:UInt = 0;

		var x:UInt;
		var y:UInt;

		var c:UInt;
		var r:UInt;
		var g:UInt;
		var b:UInt;

		y = 0;
		do {
			x = 0;
			do {

				c = img.getPixel( xpos + x, ypos + y );

				r = ( c >> 16 ) & 0xFF;
				g = ( c >>  8 ) & 0xFF;
				b = ( c       ) & 0xFF;

				Memory.setDouble( Z1 + 512 * 0 + pos,   0.29900 * r + 0.58700 * g + 0.11400 * b - 0x80 ); // YDU
				Memory.setDouble( Z1 + 512 * 1 + pos, - 0.16874 * r - 0.33126 * g + 0.50000 * b        ); // UDU
				Memory.setDouble( Z1 + 512 * 2 + pos,   0.50000 * r - 0.41869 * g - 0.08131 * b        ); // VDU

				++pos;

			} while ( ++x < 8 );
		} while ( ++y < 8 );

		var arr:Array<Float> = [];
		var i:Int;
		for ( i in 0...64 ) {
			arr.push( Memory.getDouble( Z1 + 512 * 0 + i ) );
		}
		Lib.trace( arr );
	}

}