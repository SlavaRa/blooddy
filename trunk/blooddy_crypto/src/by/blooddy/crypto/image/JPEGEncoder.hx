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

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Created a JPEG image from the specified BitmapData
	 *
	 * @param	image	The BitmapData that will be converted into the JPEG format.
	 * @param	quality	The quality level between 1 and 100 that detrmines the level of compression used in the generated JPEG
 	 * 
	 * @return a ByteArray representing the JPEG encoded image data.
	 */     
	public static function encode(image:BitmapData, ?quality:UInt=60):ByteArray {
		return TMP.encode( image, quality );
	}

}

/**
 * @private
 */
private class TMP {

	//--------------------------------------------------------------------------
	//
	//  Private class variables
	//
	//--------------------------------------------------------------------------

	private static inline var Z1:UInt = 12; // буфер под картинку
	private static inline var Z2:UInt = Z1 + 256 + 512 * 3;

	private static inline var Z0:UInt = Z2 + 199817;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function encode(image:BitmapData, quality:UInt):ByteArray {

		var mem:ByteArray = Memory.memory;

		var width:UInt = image.width;
		var height:UInt = image.height;

		var tmp:ByteArray = new ByteArray();

		var table:ByteArray = JPEGTable.getTable( quality );
		tmp.position = Z2;
		tmp.writeBytes( table );
		table.clear();

		tmp.length += 608;

		Memory.memory = tmp;

		// Add JPEG headers
		Memory.setI16( Z0, 0xD8FF ); // SOI
		writeAPP0();
		writeDQT();
		writeSOF0( image.width, image.height );
		writeDHT();
		writeSOS();

		Memory.setI32( 8,   0 ); // bytenew
		Memory.setI32( 4,   7 ); // bytepos
		Memory.setI32( 0, 607 ); // byteout

		// Encode 8x8 macroblocks
		var DCY:Int = 0;
		var DCU:Int = 0;
		var DCV:Int = 0;

		var x:UInt;
		var y:UInt;

		y = 0;
		do {
			x = 0;
			do {
				if ( tmp.length - Z0 - Memory.getI32( 0 ) < 2048 ) {
					tmp.length += 4096;
				}
				rgb2yuv( image, x, y );
				DCY = processDU( Z1 + 256 + 512 * 0, Z2 + 130, DCY, Z2 + 1218 + 416,  Z2 + 1218 + 452  );
				DCU = processDU( Z1 + 256 + 512 * 1, Z2 + 642, DCU, Z2 + 1218 + 1205, Z2 + 1218 + 1241 );
				DCV = processDU( Z1 + 256 + 512 * 2, Z2 + 642, DCV, Z2 + 1218 + 1205, Z2 + 1218 + 1241 );
				x += 8;
			} while ( x < width );
			y += 8;
		} while ( y < height );

		// Do the bit alignment of the EOI marker
		var bytepos:Int;
		if ( Memory.getI32( 4 ) >= 0 ) {
			bytepos = Memory.getI32( 4 ) + 1;
			writeBits( bytepos, ( 1 << bytepos ) - 1 );
		}

		var len:UInt = Memory.getI32( 0 );

		Memory.setI16( Z0 + len, 0xD9FF ); //EOI

		Memory.memory = mem;

		var bytes:ByteArray = new ByteArray();
		bytes.writeBytes( tmp, Z0, len + 2 );
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
	private static inline function writeAPP0():Void {
		Memory.setI16(	Z0 +  2,	0xE0FF		);	// marker
		Memory.setI16(	Z0 +  4,	0x1000		);	// length
		Memory.setI32(	Z0 +  6,	0x4649464A	);	// JFIF
		Memory.setByte( Z0 + 10,	0x00		);	//
		Memory.setI16(	Z0 + 11,	0x0101		);	// version
		Memory.setByte( Z0 + 13,	0x00		);	// xyunits
		Memory.setI32(	Z0 + 14,	0x01000100	);	// density
		Memory.setI16(	Z0 + 18,	0x0000		);	// thumbn
	}

	/**
	 * @private
	 */
	private static inline function writeDQT():Void {
		Memory.setI16(	Z0 + 20,	0xDBFF		);	// marker
		Memory.setI16(	Z0 + 22,	0x8400		);	// length

		var tmp:ByteArray = Memory.memory;
		tmp.position = Z0 + 24;
		tmp.writeBytes( tmp, Z2, 130 );

		Memory.setByte( Z0 + 24,	0x00		);
		Memory.setByte( Z0 + 89,	0x01		);
	}
	
	/**
	 * @private
	 */
	private static inline function writeSOF0(width:UInt, height:UInt):Void {
		Memory.setI16(	Z0 + 154,	0xC0FF		);	// marker
		Memory.setI16(	Z0 + 156,	0x1100		);	// length, truecolor YUV JPG
		Memory.setByte(	Z0 + 158,	0x08		);	// precision
		Memory.setI32(	Z0 + 159,					// height, width
			( ( ( height >> 8 ) & 0xFF )       ) |
			( ( ( height      ) & 0xFF ) << 8  ) |
			( ( ( width >> 8  ) & 0xFF ) << 16 ) |
			( ( ( width       ) & 0xFF ) << 24 )
		);
		Memory.setByte(	Z0 + 163,	0x03		);	// nrofcomponents
		Memory.setI32(	Z0 + 164,	0x00001101	);	// IdY, HVY, QTY
		Memory.setI32(	Z0 + 167,	0x00011102	);	// IdU, HVU, QTU
		Memory.setI32(	Z0 + 170,	0x00011103	);	// IdV, HVV, QTV
	}

	/**
	 * @private
	 */
	private static inline function writeDHT():Void {
		Memory.setI16(	Z0 + 173,	0xC4FF		);	// marker
		Memory.setI16(	Z0 + 175,	0xA201		);	// length

		var tmp:ByteArray = Memory.memory;
		tmp.position = Z0 + 177;
		tmp.writeBytes( tmp, Z2 + 1218, 416 );

		Memory.setByte(	Z0 + 177,	0x00		);	// HTYDCinfo
		Memory.setByte(	Z0 + 206,	0x10		);	// HTYACinfo
		Memory.setByte(	Z0 + 385,	0x01		);	// HTUDCinfo
		Memory.setByte(	Z0 + 414,	0x11		);	// HTUACinfo
	}

	/**
	 * @private
	 */
	private static inline function writeSOS():Void {
		Memory.setI16(	Z0 + 593,	0xDAFF		);	// marker
		Memory.setI16(	Z0 + 595,	0x0C00		);	// length
		Memory.setByte(	Z0 + 597,	0x03		);	// nrofcomponents
		Memory.setI16(	Z0 + 598,	0x0001		);	// IdY, HTY
		Memory.setI16(	Z0 + 600,	0x1102		);	// IdU, HTU
		Memory.setI16(	Z0 + 602,	0x1103		);	// IdV, HTV
		Memory.setI32(	Z0 + 604,	0x00003f00	);	// Ss, Se, Bf
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

				Memory.setDouble( Z1 + 256 + 512 * 0 + pos,   0.29900 * r + 0.58700 * g + 0.11400 * b - 0x80 ); // YDU
				Memory.setDouble( Z1 + 256 + 512 * 1 + pos, - 0.16874 * r - 0.33126 * g + 0.50000 * b        ); // UDU
				Memory.setDouble( Z1 + 256 + 512 * 2 + pos,   0.50000 * r - 0.41869 * g - 0.08131 * b        ); // VDU

				pos += 8;

			} while ( ++x < 8 );
		} while ( ++y < 8 );

	}

	/**
	 * @private
	 */
	private static inline function processDU(CDU:UInt, fdtbl:UInt, DC:Int, HTDC:UInt, HTAC:UInt):Int {
		
		fDCTQuant( CDU, fdtbl );

		var DU0:Int = Memory.getI32( Z1 );
		var diff:Int = DU0 - DC;
		DC = DU0;

		var pos:UInt;

		// Encode DC
		if ( diff == 0 ) {
			writeMBits( HTDC ); // Diff might be 0
		} else {
			pos = ( 32767 + diff ) * 3;
			writeMBits( HTDC + Memory.getByte( Z2 + 3212 + pos ) * 3 );
			writeMBits( Z2 + 3212 + pos );
		}

		// Encode ACs
		var end0pos:UInt = 63;
		while ( end0pos > 0 && Memory.getI32( Z1 + ( end0pos << 2 ) ) == 0 ) end0pos--;

		// end0pos = first element in reverse order !=0
		if ( end0pos != 0) {
			var i:UInt = 1;
			var lng:Int;
			var startpos:Int;
			var nrzeroes:Int;
			var nrmarker:Int;
			while ( i <= end0pos ) {
				startpos = i;
				while ( i <= end0pos && Memory.getI32( Z1 + ( i << 2 ) ) == 0 ) ++i;
				nrzeroes = i - startpos;
				if ( nrzeroes >= 16 ) {
					lng = nrzeroes >> 4;
					nrmarker = 1;
					while ( nrmarker <= lng ) {
						writeMBits( HTAC + 0xF0 * 3 );
						++nrmarker;
					}
					nrzeroes = nrzeroes & 0xF;
				}
				pos = ( 32767 + Memory.getI32( Z1 + ( i << 2 ) ) ) * 3;
				writeMBits( HTAC + ( nrzeroes << 4 ) * 3 + Memory.getByte( Z2 + 3212 + pos ) * 3 );
				writeMBits( Z2 + 3212 + pos );
				i++;
			}
		}
		if ( end0pos != 63 ) {
			writeMBits( HTAC );
		}
		return DC;
	}

	/**
	 * @private
	 * DCT & quantization core
	 */
	private static inline function fDCTQuant(data:UInt, fdtbl:UInt):Void {

		var dataOff:UInt;
		var d0:Float, d1:Float, d2:Float, d3:Float, d4:Float, d5:Float, d6:Float, d7:Float;
		var tmp0:Float, tmp1:Float, tmp2:Float, tmp3:Float, tmp4:Float, tmp5:Float, tmp6:Float, tmp7:Float;
		var tmp10:Float, tmp11:Float, tmp12:Float, tmp13:Float;
		var z1:Float, z2:Float, z3:Float, z4:Float, z5:Float;
		var z11:Float, z13:Float;
		
		/* Pass 1: process rows. */
		dataOff = 0;
		do {

			d0 = Memory.getDouble( data + dataOff + 0 * 8 );
			d1 = Memory.getDouble( data + dataOff + 1 * 8 );
			d2 = Memory.getDouble( data + dataOff + 2 * 8 );
			d3 = Memory.getDouble( data + dataOff + 3 * 8 );
			d4 = Memory.getDouble( data + dataOff + 4 * 8 );
			d5 = Memory.getDouble( data + dataOff + 5 * 8 );
			d6 = Memory.getDouble( data + dataOff + 6 * 8 );
			d7 = Memory.getDouble( data + dataOff + 7 * 8 );

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

			// phase 3
			Memory.setDouble( data + dataOff + 0 * 8, tmp10 + tmp11 );
			Memory.setDouble( data + dataOff + 4 * 8, tmp10 - tmp11 );
			
			// phase 5
			z1 = ( tmp12 + tmp13 ) * 0.707106781;	// c4
			Memory.setDouble( data + dataOff + 2 * 8, tmp13 + z1 );
			Memory.setDouble( data + dataOff + 6 * 8, tmp13 - z1 );
			
			// Odd part
			// phase 2
			tmp10 = tmp4 + tmp5;
			tmp11 = tmp5 + tmp6;
			tmp12 = tmp6 + tmp7;
			
			// The rotator is modified from fig 4-8 to avoid extra negations.
			z5 = ( tmp10 - tmp12 ) * 0.382683433;	// c6
			z2 = 0.541196100 * tmp10 + z5;			// c2-c6
			z4 = 1.306562965 * tmp12 + z5;			// c2+c6
			z3 = tmp11 * 0.707106781;				// c4

			//phase 5
			z11 = tmp7 + z3;
			z13 = tmp7 - z3;

			// phase 6
			Memory.setDouble( data + dataOff + 5 * 8, z13 + z2 );
			Memory.setDouble( data + dataOff + 3 * 8, z13 - z2 );
			Memory.setDouble( data + dataOff + 1 * 8, z11 + z4 );
			Memory.setDouble( data + dataOff + 7 * 8, z11 - z4 );
			
			dataOff += 64; // advance pointer to next row
		} while ( dataOff < 512 );

		// Pass 2: process columns.
		dataOff = 0;
		do {

			d0 = Memory.getDouble( data + dataOff +  0 * 8 );
			d1 = Memory.getDouble( data + dataOff +  8 * 8 );
			d2 = Memory.getDouble( data + dataOff + 16 * 8 );
			d3 = Memory.getDouble( data + dataOff + 24 * 8 );
			d4 = Memory.getDouble( data + dataOff + 32 * 8 );
			d5 = Memory.getDouble( data + dataOff + 40 * 8 );
			d6 = Memory.getDouble( data + dataOff + 48 * 8 );
			d7 = Memory.getDouble( data + dataOff + 56 * 8 );

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

			// phase 3
			Memory.setDouble( data + dataOff +  0 * 8, tmp10 + tmp11 );
			Memory.setDouble( data + dataOff + 32 * 8, tmp10 - tmp11 );

			// phase 5
			z1 = ( tmp12 + tmp13 ) * 0.707106781;	// c4
			Memory.setDouble( data + dataOff + 16 * 8, tmp13 + z1 );
			Memory.setDouble( data + dataOff + 48 * 8, tmp13 - z1 );

			// Odd part
			// phase 2
			tmp10 = tmp4 + tmp5;
			tmp11 = tmp5 + tmp6;
			tmp12 = tmp6 + tmp7;
			
			// The rotator is modified from fig 4-8 to avoid extra negations.
			z5 = ( tmp10 - tmp12 ) * 0.382683433;	// c6
			z2 = 0.541196100 * tmp10 + z5;			// c2-c6
			z4 = 1.306562965 * tmp12 + z5;			// c2+c6
			z3 = tmp11 * 0.707106781;				// c4

			// phase 5
			z11 = tmp7 + z3;
			z13 = tmp7 - z3;

			// phase 6
			Memory.setDouble( data + dataOff + 40 * 8, z13 + z2 );
			Memory.setDouble( data + dataOff + 24 * 8, z13 - z2 );
			Memory.setDouble( data + dataOff +  8 * 8, z11 + z4 );
			Memory.setDouble( data + dataOff + 56 * 8, z11 - z4 );
			
			dataOff += 8; // advance pointer to next column
		} while ( dataOff < 64 );

		// Quantize/descale the coefficients
		var fDCTQuant:Float;
		var i:UInt = 0;
		do {
			// Apply the quantization and scaling factor & Round to nearest integer
			fDCTQuant = Memory.getDouble( data + ( i << 3 ) ) * Memory.getDouble( fdtbl + ( i << 3 ) );
			Memory.setI32(
				Z1 + ( Memory.getByte( Z2 + 1154 + i ) << 2 ), // ZigZag reorder
				Std.int( fDCTQuant + ( fDCTQuant > 0.0 ? 0.5 : - 0.5 ) )
			);
		} while ( ++i < 64 );

	}

	/**
	 * @private
	 */
	private static inline function writeMBits(addres:UInt):Void {
		writeBits( Memory.getByte( addres ), Memory.getUI16( addres + 1 ) );
	}

	/**
	 * @private
	 */
	private static inline function writeBits(len:Int, val:Int):Void {
		var bytenew:Int = Memory.getI32( 8 );
		var bytepos:Int = Memory.getI32( 4 );
		var byteout:Int = Memory.getI32( 0 );

		while ( --len >= 0 ) {
			if ( val & ( 1 << len ) != 0 ) {
				bytenew |= 1 << bytepos;
			}
			bytepos--;
			if ( bytepos < 0 ) {
				if ( bytenew == 0xFF ) {
					Memory.setI16( Z0 + byteout, 0x00FF );
					byteout += 2;
				} else {
					Memory.setByte( Z0 + byteout, bytenew );
					byteout++;
				}
				bytepos = 7;
				bytenew = 0;
			}
		}

		Memory.setI32( 8, bytenew ); // bytenew
		Memory.setI32( 4, bytepos ); // bytepos
		Memory.setI32( 0, byteout ); // byteout
	}
	
}