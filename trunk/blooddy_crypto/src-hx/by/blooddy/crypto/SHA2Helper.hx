////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto;

import by.blooddy.system.Memory;
import by.blooddy.utils.ByteArrayUtils;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class SHA2Helper {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function hashBytes(bytes:ByteArray, h0:Int, h1:Int, h2:Int, h3:Int, h4:Int, h5:Int, h6:Int, h7:Int):String {

		var mem:ByteArray = Memory.memory;

		var i:UInt = bytes.length << 3;
		var bytesLength:UInt = TMP.Z0 + ( ( ( ( ( i + 64 ) >>> 9 ) << 4 ) + 15 ) << 2 ); // длинна для подсчёта в блоках

		// копируем массив
		var tmp:ByteArray = ByteArrayUtils.createByteArray( bytesLength + 4 );
		tmp.position = TMP.Z0;
		tmp.writeBytes( bytes );

		// помещаем в пямять
		if ( tmp.length < 1024 ) tmp.length = 1024;
		Memory.memory = tmp;

		Memory.setI32( TMP.Z0 + ( ( i >>> 5 ) << 2 ), Memory.getI32( TMP.Z0 + ( ( i >>> 5 ) << 2 ) ) | ( 0x80 << ( i % 32 ) ) );
		Memory.setBI32( bytesLength, i );

		var k:Array<Int> = [ 0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2 ];

		var h0:Int = 0x6a09e667;
		var h1:Int = 0xbb67ae85;
		var h2:Int = 0x3c6ef372;
		var h3:Int = 0xa54ff53a;
		var h4:Int = 0x510e527f;
		var h5:Int = 0x9b05688c;
		var h6:Int = 0x1f83d9ab;
		var h7:Int = 0x5be0cd19;

		var a:Int;
		var b:Int;
		var c:Int;
		var d:Int;
		var e:Int;
		var f:Int;
		var g:Int;
		var h:Int;

		i = TMP.Z0;
		do {

			i += 16 * 4;

		} while ( i < bytesLength );

		tmp.position = 0;
		tmp.writeUTFBytes( '0123456789abcdef' );

		Memory.setBI32( 16, h0 );
		Memory.setBI32( 20, h1 );
		Memory.setBI32( 24, h2 );
		Memory.setBI32( 28, h3 );
		Memory.setBI32( 32, h4 );

		b = 36 - 1;
		i = 16;
		do {
			a = Memory.getByte( i );
			Memory.setByte( ++b, Memory.getByte( a >>> 4 ) );
			Memory.setByte( ++b, Memory.getByte( a & 0xF ) );
		} while ( ++i < 36 );

		tmp.position = 36;

		var result:String = tmp.readUTFBytes( 40 );

		Memory.memory = mem;

		//tmp.clear();

		return result;

	}
	
}

/**
 * @private
 */
private class TMP {

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	public static inline var Z0:UInt = 80 * 4;

}