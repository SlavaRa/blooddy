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

	public static function encode(image:BitmapData, quality:UInt):ByteArray {

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
				DCY = processDU( Z1 + 512 * 0, Z2 + 130,  DCY, Z2 + 1570,  Z2 + 1606 );
//				DCU = processDU( Z1 + 512 * 1, fdtbl_UV, DCU, UVDC_HT, UVAC_HT);
//				DCV = processDU( Z1 + 512 * 2, fdtbl_UV, DCV, UVDC_HT, UVAC_HT);
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
	private static function writeAPP0():Void {
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
	private static function writeDQT():Void {
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
	private static function writeDHT():Void {
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
	private static function writeSOS():Void {
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
	private static function rgb2yuv(img:BitmapData, xpos:UInt, ypos:UInt):Void {

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

				pos += 8;

			} while ( ++x < 8 );
		} while ( ++y < 8 );

	}

	//private static function processDU(CDU:Vector.<Number>, fdtbl:Vector.<Number>, DC:Number, HTDC:Vector.<BitString>, HTAC:Vector.<BitString>):Number {
	private static function processDU(CDU:UInt, fdtbl:UInt, DC:Float, HTDC:UInt, HTAC:UInt):Float {
		//var EOB:BitString = HTAC[0x00];
		//var M16zeroes:BitString = HTAC[0xF0];
		var pos:UInt;
		fDCTQuant( CDU, fdtbl );
		//var DU_DCT:Vector.<int> = fDCTQuant(CDU, fdtbl);
		//ZigZag reorder
/*		for (var j:int=0;j<I64;++j) {
			DU[ZigZag[j]]=DU_DCT[j];
		}
		var Diff:int = DU[0] - DC; DC = DU[0];
		//Encode DC
		if (Diff==0) {
			writeBits(HTDC[0]); // Diff might be 0
		} else {
			pos = int(32767+Diff);
			writeBits(HTDC[category[pos]]);
			writeBits(bitcode[pos]);
		}
		//Encode ACs
		const end0pos:int = 63;
		for (; (end0pos>0)&&(DU[end0pos]==0); end0pos--) {};
		//end0pos = first element in reverse order !=0
		if ( end0pos == 0) {
			writeBits(EOB);
			return DC;
		}
		var i:int = 1;
		var lng:int;
		while ( i <= end0pos ) {
			var startpos:int = i;
			for (; (DU[i]==0) && (i<=end0pos); ++i) {}
			var nrzeroes:int = i-startpos;
			if ( nrzeroes >= I16 ) {
				lng = nrzeroes>>4;
				for (var nrmarker:int=1; nrmarker <= lng; ++nrmarker)
					writeBits(M16zeroes);
				nrzeroes = int(nrzeroes&0xF);
			}
			pos = int(32767+DU[i]);
			writeBits(HTAC[int((nrzeroes<<4)+category[pos])]);
			writeBits(bitcode[pos]);
			i++;
		}
		if ( end0pos != I63 ) {
			writeBits(EOB);
		}*/
		return DC;
	}

	/**
	 * @private
	 * DCT & quantization core
	 */
	//private static function fDCTQuant(data:Vector.<Number>, fdtbl:Vector.<Number>):Vector.<int>
	private static function fDCTQuant(data:UInt, fdtbl:UInt):Void {

		var d0:Float, d1:Float, d2:Float, d3:Float, d4:Float, d5:Float, d6:Float, d7:Float;
		var tmp0:Float, tmp1:Float, tmp2:Float, tmp3:Float, tmp4:Float, tmp5:Float, tmp6:Float, tmp7:Float;
		var tmp10:Float, tmp11:Float, tmp12:Float, tmp13:Float;
		
		/* Pass 1: process rows. */
		var dataOff:UInt = 0;
		var i:UInt;
		i = 0;
		do {
			// phase 0
			d0 = Memory.getDouble( data + dataOff         );
			d1 = Memory.getDouble( data + dataOff + 1 * 8 );
			d2 = Memory.getDouble( data + dataOff + 2 * 8 );
			d3 = Memory.getDouble( data + dataOff + 3 * 8 );
			d4 = Memory.getDouble( data + dataOff + 4 * 8 );
			d5 = Memory.getDouble( data + dataOff + 5 * 8 );
			d6 = Memory.getDouble( data + dataOff + 6 * 8 );
			d7 = Memory.getDouble( data + dataOff + 7 * 8 );

			// phase 1
			tmp0 = d0 + d7;
			tmp7 = d0 - d7;
			tmp1 = d1 + d6;
			tmp6 = d1 - d6;
			tmp2 = d2 + d5;
			tmp5 = d2 - d5;
			tmp3 = d3 + d4;
			tmp4 = d3 - d4;
			
			// Even part
			// phase 2
			tmp10 = tmp0 + tmp3;
			tmp13 = tmp0 - tmp3;
			tmp11 = tmp1 + tmp2;
			tmp12 = tmp1 - tmp2;
			
			//data[int(dataOff)] = tmp10 + tmp11; /* phase 3 */
			//data[int(dataOff+4)] = tmp10 - tmp11;
			
			//var z1:Number = (tmp12 + tmp13) * 0.707106781; /* c4 */
			//data[int(dataOff+2)] = tmp13 + z1; /* phase 5 */
			//data[int(dataOff+6)] = tmp13 - z1;
			//
			///* Odd part */
			//tmp10 = tmp4 + tmp5; /* phase 2 */
			//tmp11 = tmp5 + tmp6;
			//tmp12 = tmp6 + tmp7;
			//
			///* The rotator is modified from fig 4-8 to avoid extra negations. */
			//var z5:Number = (tmp10 - tmp12) * 0.382683433; /* c6 */
			//var z2:Number = 0.541196100 * tmp10 + z5; /* c2-c6 */
			//var z4:Number = 1.306562965 * tmp12 + z5; /* c2+c6 */
			//var z3:Number = tmp11 * 0.707106781; /* c4 */
			//
			//var z11:Number = tmp7 + z3;	/* phase 5 */
			//var z13:Number = tmp7 - z3;
			
			//data[int(dataOff+5)] = z13 + z2;	/* phase 6 */
			//data[int(dataOff+3)] = z13 - z2;
			//data[int(dataOff+1)] = z11 + z4;
			//data[int(dataOff+7)] = z11 - z4;
			
			dataOff += 64; // advance pointer to next row
		} while ( ++i < 8 );
		
		///* Pass 2: process columns. */
		//dataOff = 0;
		//for (i=0; i<I8; ++i)
		//{
			//d0 = data[int(dataOff)];
			//d1 = data[int(dataOff + 8)];
			//d2 = data[int(dataOff + 16)];
			//d3 = data[int(dataOff + 24)];
			//d4 = data[int(dataOff + 32)];
			//d5 = data[int(dataOff + 40)];
			//d6 = data[int(dataOff + 48)];
			//d7 = data[int(dataOff + 56)];
			//
			//var tmp0p2:Number = d0 + d7;
			//var tmp7p2:Number = d0 - d7;
			//var tmp1p2:Number = d1 + d6;
			//var tmp6p2:Number = d1 - d6;
			//var tmp2p2:Number = d2 + d5;
			//var tmp5p2:Number = d2 - d5;
			//var tmp3p2:Number = d3 + d4;
			//var tmp4p2:Number = d3 - d4;
			//
			///* Even part */
			//var tmp10p2:Number = tmp0p2 + tmp3p2;	/* phase 2 */
			//var tmp13p2:Number = tmp0p2 - tmp3p2;
			//var tmp11p2:Number = tmp1p2 + tmp2p2;
			//var tmp12p2:Number = tmp1p2 - tmp2p2;
			//
			//data[int(dataOff)] = tmp10p2 + tmp11p2; /* phase 3 */
			//data[int(dataOff+32)] = tmp10p2 - tmp11p2;
			//
			//var z1p2:Number = (tmp12p2 + tmp13p2) * 0.707106781; /* c4 */
			//data[int(dataOff+16)] = tmp13p2 + z1p2; /* phase 5 */
			//data[int(dataOff+48)] = tmp13p2 - z1p2;
			//
			///* Odd part */
			//tmp10p2 = tmp4p2 + tmp5p2; /* phase 2 */
			//tmp11p2 = tmp5p2 + tmp6p2;
			//tmp12p2 = tmp6p2 + tmp7p2;
			//
			///* The rotator is modified from fig 4-8 to avoid extra negations. */
			//var z5p2:Number = (tmp10p2 - tmp12p2) * 0.382683433; /* c6 */
			//var z2p2:Number = 0.541196100 * tmp10p2 + z5p2; /* c2-c6 */
			//var z4p2:Number = 1.306562965 * tmp12p2 + z5p2; /* c2+c6 */
			//var z3p2:Number= tmp11p2 * 0.707106781; /* c4 */
			//
			//var z11p2:Number = tmp7p2 + z3p2;	/* phase 5 */
			//var z13p2:Number = tmp7p2 - z3p2;
			//
			//data[int(dataOff+40)] = z13p2 + z2p2; /* phase 6 */
			//data[int(dataOff+24)] = z13p2 - z2p2;
			//data[int(dataOff+ 8)] = z11p2 + z4p2;
			//data[int(dataOff+56)] = z11p2 - z4p2;
			//
			//dataOff++; /* advance pointer to next column */
		//}
		//
		// Quantize/descale the coefficients
		//var fDCTQuant:Number;
		//for (i=0; i<I64; ++i)
		//{
			// Apply the quantization and scaling factor & Round to nearest integer
			//fDCTQuant = data[int(i)]*fdtbl[int(i)];
			//outputfDCTQuant[int(i)] = (fDCTQuant > 0.0) ? int(fDCTQuant + 0.5) : int(fDCTQuant - 0.5);
		//}
		//return outputfDCTQuant;
	}

}