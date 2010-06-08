////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image;

import by.blooddy.system.Memory;
import flash.display.BitmapData;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class JPEGEncoder {

	public static function encode(image:BitmapData, ?quality:UInt=60):ByteArray {
		return TMP.encode( image, quality );
	}

}

/**
 * @private
 */
private class TMP {

	public static function encode(image:BitmapData, quality:UInt):ByteArray {

		var mem:ByteArray = Memory.memory;

		var quantTable:ByteArray = JPEGHelper.createQuantTable( quality );
		var huffmanTable:ByteArray = JPEGHelper.createHuffmanTable();

		var bytes:ByteArray = new ByteArray();
		var len:UInt = image.width * image.height * 4;

		bytes.length = 2048 * 2048;

		Memory.memory = bytes;

		//bytenew=0;
		//bytepos=7;
		
		// Add JPEG headers
		Memory.setI16( 0, 0xD8FF ); // SOI
		writeAPP0();
		writeDQT( quantTable );
		writeSOF0( image.width, image.height );
		writeDHT( huffmanTable );
		//writeSOS();
		//
		// Encode 8x8 macroblocks
		//var DCY:Number=0;
		//var DCU:Number=0;
		//var DCV:Number=0;
		//bytenew=0;
		//bytepos=7;
		//
		//var width:int = image.width;
		//var height:int = image.height;
		//
		//for (var ypos:int=0; ypos<height; ypos+=8)
		//{
			//for (var xpos:int=0; xpos<width; xpos+=8)
			//{
				//RGB2YUV(image, xpos, ypos);
				//DCY = processDU(YDU, fdtbl_Y, DCY, YDC_HT, YAC_HT);
				//DCU = processDU(UDU, fdtbl_UV, DCU, UVDC_HT, UVAC_HT);
				//DCV = processDU(VDU, fdtbl_UV, DCV, UVDC_HT, UVAC_HT);
			//}
		//}
		//
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
		bytes.length = 576;

		Memory.memory = mem;

		return bytes;
	}

	/**
	 * @private
	 */
	private static function writeAPP0():Void {
		Memory.setI16(	2,	0xE0FF		);	// marker
		Memory.setI16(	4,	0x1000		);	// length
		Memory.setI32(	6,	0x4649464A	);	// JFIF
		Memory.setByte( 10,	0x00		);	// 
		Memory.setI16(	11,	0x0101		);	// version
		Memory.setByte( 13,	0x00		);	// xyunits
		Memory.setI32(	14,	0x10001000	);	// density
		Memory.setI16(	18, 0x0000		);	// thumbn
	}

	/**
	 * @private
	 */
	private static function writeDQT(quantTable:ByteArray):Void {
		Memory.setI16(	20,	0xDBFF		);	// marker
		Memory.setI16(	22,	0x8400		);	// length
		Memory.setByte( 24,	0x00		);	// 

		var bytes:ByteArray = Memory.memory;

		bytes.position = 25;
		bytes.writeBytes( quantTable, 0, 64 );

		Memory.setByte( 89,	0x01		);	// 

		bytes.position = 90;
		bytes.writeBytes( quantTable, 64, 64 );
	}
	
	/**
	 * @private
	 */
	private static function writeSOF0(width:UInt, height:UInt):Void {
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
	private static function writeDHT(huffmanTable:ByteArray):Void {
		Memory.setI16(	173,	0xC4FF		);	// marker
		Memory.setI16(	175,	0xA201		);	// length

		var bytes:ByteArray = Memory.memory;
		bytes.position = 177;
		bytes.writeBytes( huffmanTable, 0, 416 );

		Memory.setByte(	177,	0x00		);	// HTYDCinfo
		Memory.setByte(	206,	0x10		);	// HTYACinfo
		Memory.setByte(	385,	0x01		);	// HTUDCinfo
		Memory.setByte(	414,	0x11		);	// HTUACinfo

	}

}