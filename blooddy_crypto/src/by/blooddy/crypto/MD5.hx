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
 * @version	2.0
 */
class MD5 {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * Performs the MD5 hash algorithm on a String.
	 *
	 * @param		s			The string to hash
	 *
	 * @return					A string containing the hash value of s
	 *
	 * @keyword					md5.hash, hash
	 */
	public static function hash(s:String):String {
		var bytes:ByteArray = new ByteArray();
		bytes.writeUTFBytes( s );
		var result:String = hashBytes( bytes );
		bytes.clear();
		return result;
	}

	/**
	 * Performs the MD5 hash algorithm on a ByteArray.
	 *
	 * @param	data			The ByteArray data to hash
	 *
	 * @return					A string containing the hash value of data
	 *
	 * @keyword					md5.hash, hash
	 */
	public static function hashBytes(data:ByteArray):String {
		return TMP.hashBytes( data );
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
	 * Constants for MD5Transform routine.
	 */
	private static inline var S11:UInt =  7;
	private static inline var S12:UInt = 12;
	private static inline var S13:UInt = 17;
	private static inline var S14:UInt = 22;
	private static inline var S21:UInt =  5;
	private static inline var S22:UInt =  9;
	private static inline var S23:UInt = 14;
	private static inline var S24:UInt = 20;
	private static inline var S31:UInt =  4;
	private static inline var S32:UInt = 11;
	private static inline var S33:UInt = 16;
	private static inline var S34:UInt = 23;
	private static inline var S41:UInt =  6;
	private static inline var S42:UInt = 10;
	private static inline var S43:UInt = 15;
	private static inline var S44:UInt = 21;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function hashBytes(bytes:ByteArray):String {

		var len:UInt = bytes.length;
		var mem:ByteArray = Memory.memory;

		var i:UInt = len << 3;
		var bytesLength:UInt = ( ( ( ( i + 64 ) >>> 9 ) << 4 ) + 15 ) << 2; // длинна для подсчёта в блоков

		// копируем массив
		var tmp:ByteArray = ByteArrayUtils.createByteArray( bytesLength + 4 );
		tmp.writeBytes( bytes );

		// помещаем в пямять
		if ( tmp.length < 1024 ) tmp.length = 1024;
		Memory.memory = tmp;

		Memory.setI32( ( i >> 5 ) << 2, Memory.getI32( ( i >> 5 ) << 2 ) | ( 0x80 << ( i % 32 ) ) );
		Memory.setI32( bytesLength - 4, i );

		var a:Int =   1732584193;
		var b:Int = -  271733879;
		var c:Int = - 1732584194;
		var d:Int =    271733878;

		var aa:Int = a;
		var bb:Int = b;
		var cc:Int = c;
		var dd:Int = d;

		i = 0;

		do {

			aa = a;
			bb = b;
			cc = c;
			dd = d;

			a = FF( a, b, c, d, Memory.getI32( i +  0 * 4 ), S11, -  680876936 );
			d = FF( d, a, b, c, Memory.getI32( i +  1 * 4 ), S12, -  389564586 );
			c = FF( c, d, a, b, Memory.getI32( i +  2 * 4 ), S13,    606105819 );
			b = FF( b, c, d, a, Memory.getI32( i +  3 * 4 ), S14, - 1044525330 );
			a = FF( a, b, c, d, Memory.getI32( i +  4 * 4 ), S11, -  176418897 );
			d = FF( d, a, b, c, Memory.getI32( i +  5 * 4 ), S12,   1200080426 );
			c = FF( c, d, a, b, Memory.getI32( i +  6 * 4 ), S13, - 1473231341 );
			b = FF( b, c, d, a, Memory.getI32( i +  7 * 4 ), S14, -   45705983 );
			a = FF( a, b, c, d, Memory.getI32( i +  8 * 4 ), S11,   1770035416 );
			d = FF( d, a, b, c, Memory.getI32( i +  9 * 4 ), S12, - 1958414417 );
			c = FF( c, d, a, b, Memory.getI32( i + 10 * 4 ), S13, -      42063 );
			b = FF( b, c, d, a, Memory.getI32( i + 11 * 4 ), S14, - 1990404162 );
			a = FF( a, b, c, d, Memory.getI32( i + 12 * 4 ), S11,   1804603682 );
			d = FF( d, a, b, c, Memory.getI32( i + 13 * 4 ), S12, -   40341101 );
			c = FF( c, d, a, b, Memory.getI32( i + 14 * 4 ), S13, - 1502002290 );
			b = FF( b, c, d, a, Memory.getI32( i + 15 * 4 ), S14,   1236535329 );
			a = GG( a, b, c, d, Memory.getI32( i +  1 * 4 ), S21, -  165796510 );
			d = GG( d, a, b, c, Memory.getI32( i +  6 * 4 ), S22, - 1069501632 );
			c = GG( c, d, a, b, Memory.getI32( i + 11 * 4 ), S23,    643717713 );
			b = GG( b, c, d, a, Memory.getI32( i +  0 * 4 ), S24, -  373897302 );
			a = GG( a, b, c, d, Memory.getI32( i +  5 * 4 ), S21, -  701558691 );
			d = GG( d, a, b, c, Memory.getI32( i + 10 * 4 ), S22,     38016083 );
			c = GG( c, d, a, b, Memory.getI32( i + 15 * 4 ), S23, -  660478335 );
			b = GG( b, c, d, a, Memory.getI32( i +  4 * 4 ), S24, -  405537848 );
			a = GG( a, b, c, d, Memory.getI32( i +  9 * 4 ), S21,    568446438 );
			d = GG( d, a, b, c, Memory.getI32( i + 14 * 4 ), S22, - 1019803690 );
			c = GG( c, d, a, b, Memory.getI32( i +  3 * 4 ), S23, -  187363961 );
			b = GG( b, c, d, a, Memory.getI32( i +  8 * 4 ), S24,   1163531501 );
			a = GG( a, b, c, d, Memory.getI32( i + 13 * 4 ), S21, - 1444681467 );
			d = GG( d, a, b, c, Memory.getI32( i +  2 * 4 ), S22, -   51403784 );
			c = GG( c, d, a, b, Memory.getI32( i +  7 * 4 ), S23,   1735328473 );
			b = GG( b, c, d, a, Memory.getI32( i + 12 * 4 ), S24, - 1926607734 );
			a = HH( a, b, c, d, Memory.getI32( i +  5 * 4 ), S31, -     378558 );
			d = HH( d, a, b, c, Memory.getI32( i +  8 * 4 ), S32, - 2022574463 );
			c = HH( c, d, a, b, Memory.getI32( i + 11 * 4 ), S33,   1839030562 );
			b = HH( b, c, d, a, Memory.getI32( i + 14 * 4 ), S34, -   35309556 );
			a = HH( a, b, c, d, Memory.getI32( i +  1 * 4 ), S31, - 1530992060 );
			d = HH( d, a, b, c, Memory.getI32( i +  4 * 4 ), S32,   1272893353 );
			c = HH( c, d, a, b, Memory.getI32( i +  7 * 4 ), S33, -  155497632 );
			b = HH( b, c, d, a, Memory.getI32( i + 10 * 4 ), S34, - 1094730640 );
			a = HH( a, b, c, d, Memory.getI32( i + 13 * 4 ), S31,    681279174 );
			d = HH( d, a, b, c, Memory.getI32( i +  0 * 4 ), S32, -  358537222 );
			c = HH( c, d, a, b, Memory.getI32( i +  3 * 4 ), S33, -  722521979 );
			b = HH( b, c, d, a, Memory.getI32( i +  6 * 4 ), S34,     76029189 );
			a = HH( a, b, c, d, Memory.getI32( i +  9 * 4 ), S31, -  640364487 );
			d = HH( d, a, b, c, Memory.getI32( i + 12 * 4 ), S32, -  421815835 );
			c = HH( c, d, a, b, Memory.getI32( i + 15 * 4 ), S33,    530742520 );
			b = HH( b, c, d, a, Memory.getI32( i +  2 * 4 ), S34, -  995338651 );
			a = II( a, b, c, d, Memory.getI32( i +  0 * 4 ), S41, -  198630844 );
			d = II( d, a, b, c, Memory.getI32( i +  7 * 4 ), S42,   1126891415 );
			c = II( c, d, a, b, Memory.getI32( i + 14 * 4 ), S43, - 1416354905 );
			b = II( b, c, d, a, Memory.getI32( i +  5 * 4 ), S44, -   57434055 );
			a = II( a, b, c, d, Memory.getI32( i + 12 * 4 ), S41,   1700485571 );
			d = II( d, a, b, c, Memory.getI32( i +  3 * 4 ), S42, - 1894986606 );
			c = II( c, d, a, b, Memory.getI32( i + 10 * 4 ), S43, -    1051523 );
			b = II( b, c, d, a, Memory.getI32( i +  1 * 4 ), S44, - 2054922799 );
			a = II( a, b, c, d, Memory.getI32( i +  8 * 4 ), S41,   1873313359 );
			d = II( d, a, b, c, Memory.getI32( i + 15 * 4 ), S42, -   30611744 );
			c = II( c, d, a, b, Memory.getI32( i +  6 * 4 ), S43, - 1560198380 );
			b = II( b, c, d, a, Memory.getI32( i + 13 * 4 ), S44,   1309151649 );
			a = II( a, b, c, d, Memory.getI32( i +  4 * 4 ), S41, -  145523070 );
			d = II( d, a, b, c, Memory.getI32( i + 11 * 4 ), S42, - 1120210379 );
			c = II( c, d, a, b, Memory.getI32( i +  2 * 4 ), S43,    718787259 );
			b = II( b, c, d, a, Memory.getI32( i +  9 * 4 ), S44, -  343485551 );

			a += aa;
			b += bb;
			c += cc;
			d += dd;

			i += 64;

		} while ( i < bytesLength );

		bytesLength += 4;

		tmp.position = 0;
		tmp.writeUTFBytes( '0123456789abcdef' );
		
		Memory.setI32( 16, a );
		Memory.setI32( 20, b );
		Memory.setI32( 24, c );
		Memory.setI32( 28, d );

		b = 32;
		i = 16;
		do {
			a = Memory.getByte( i );
			Memory.setByte( b++, Memory.getByte( ( a >> 4 ) & 0xF ) );
			Memory.setByte( b++, Memory.getByte(   a        & 0xF ) );
		} while ( ++i < 32 );

		tmp.position = 32;

		var result:String = tmp.readUTFBytes( 32 );

		Memory.memory = mem;

		tmp.clear();

		return result;
	}

	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * rotation is separate from addition to prevent recomputation
	 */
	private static inline function rol(num:Int, cnt:Int):Int {
		return ( num << cnt ) | ( num >>> ( 32 - cnt ) );
	}

	/**
	 * @private
	 * transformations for round 1
	 */
	private static inline function FF(a:Int, b:Int, c:Int, d:Int, x:Int, s:Int, t:Int):Int {
		a += ( ( b & c ) | ( ( ~b ) & d ) ) + x + t;
		return rol( a, s ) +  b;
	}

	/**
	 * @private
	 * transformations for round 2
	 */
	private static inline function GG(a:Int, b:Int, c:Int, d:Int, x:Int, s:Int, t:Int):Int {
		a += ( ( b & d ) | ( c & ( ~d ) ) ) + x + t;
		return rol( a, s ) +  b;
	}

	/**
	 * @private
	 * transformations for round 3
	 */
	private static inline function HH(a:Int, b:Int, c:Int, d:Int, x:Int, s:Int, t:Int):Int {
		a += ( b ^ c ^ d ) + x + t;
		return rol( a, s ) +  b;
	}

	/**
	 * @private
	 * transformations for round 4
	 */
	private static inline function II(a:Int, b:Int, c:Int, d:Int, x:Int, s:Int, t:Int):Int {
		a += ( c ^ ( b | ( ~d ) ) ) + x + t;
		return rol( a, s ) +  b;
	}

}