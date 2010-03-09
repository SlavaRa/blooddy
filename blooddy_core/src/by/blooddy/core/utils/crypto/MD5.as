////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.crypto {

	import by.blooddy.core.utils.math.NumberUtils;
	
	import flash.utils.ByteArray;

	/**
	 * The MD5 Message-Digest Algorithm.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					md5, crypto, hash
	 * 
	 * @see						http://www.faqs.org/rfcs/rfc1321.html
	 */
	public final class MD5 {

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
			return hashBlocks( createBlocksFromString(s) );
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
			return hashBlocks( createBlocksFromByteArray(data) );
		}

		//--------------------------------------------------------------------------
		//
		//  Private class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Constants for MD5Transform routine.
		 */
		private static const S11:uint = 7;
		private static const S12:uint = 12;
		private static const S13:uint = 17;
		private static const S14:uint = 22;
		private static const S21:uint = 5;
		private static const S22:uint = 9;
		private static const S23:uint = 14;
		private static const S24:uint = 20;
		private static const S31:uint = 4;
		private static const S32:uint = 11;
		private static const S33:uint = 16;
		private static const S34:uint = 23;
		private static const S41:uint = 6;
		private static const S42:uint = 10;
		private static const S43:uint = 15;
		private static const S44:uint = 21;

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Performs the MD5 hash algorithm on a blocks.
		 */
		private static function hashBlocks(x:Array):String {
			// initialize the md buffers
			var a:uint = 0x67452301;
			var b:uint = 0xEFCDAB89;
			var c:uint = 0x98BADCFE;
			var d:uint = 0x10325476;

			// variables to store previous values
			var aa:uint;
			var bb:uint;
			var cc:uint;
			var dd:uint;

			var len:uint = x.length;

			// loop over all of the blocks
			for (var i:uint = 0; i < len; i += 16) {
				// save previous values
				aa = a;
				bb = b;
				cc = c;
				dd = d;

				// Round 1
				a = FF(a, b, c, d, x[i+ 0], S11, 0xD76AA478); // 1
				d = FF(d, a, b, c, x[i+ 1], S12, 0xE8C7B756); // 2
				c = FF(c, d, a, b, x[i+ 2], S13, 0x242070DB); // 3
				b = FF(b, c, d, a, x[i+ 3], S14, 0xC1BDCEEE); // 4
				a = FF(a, b, c, d, x[i+ 4], S11, 0xF57C0FAF); // 5
				d = FF(d, a, b, c, x[i+ 5], S12, 0x4787C62A); // 6
				c = FF(c, d, a, b, x[i+ 6], S13, 0xA8304613); // 7
				b = FF(b, c, d, a, x[i+ 7], S14, 0xFD469501); // 8
				a = FF(a, b, c, d, x[i+ 8], S11, 0x698098D8); // 9
				d = FF(d, a, b, c, x[i+ 9], S12, 0x8B44F7AF); // 10
				c = FF(c, d, a, b, x[i+10], S13, 0xFFFF5BB1); // 11
				b = FF(b, c, d, a, x[i+11], S14, 0x895CD7BE); // 12
				a = FF(a, b, c, d, x[i+12], S11, 0x6B901122); // 13
				d = FF(d, a, b, c, x[i+13], S12, 0xFD987193); // 14
				c = FF(c, d, a, b, x[i+14], S13, 0xA679438E); // 15
				b = FF(b, c, d, a, x[i+15], S14, 0x49B40821); // 16

				// Round 2
				a = GG(a, b, c, d, x[i+ 1], S21, 0xF61E2562); // 17
				d = GG(d, a, b, c, x[i+ 6], S22, 0xC040B340); // 18
				c = GG(c, d, a, b, x[i+11], S23, 0x265E5A51); // 19
				b = GG(b, c, d, a, x[i+ 0], S24, 0xE9B6C7AA); // 20
				a = GG(a, b, c, d, x[i+ 5], S21, 0xD62F105D); // 21
				d = GG(d, a, b, c, x[i+10], S22,  0x2441453); // 22
				c = GG(c, d, a, b, x[i+15], S23, 0xD8A1E681); // 23
				b = GG(b, c, d, a, x[i+ 4], S24, 0xE7D3FBC8); // 24
				a = GG(a, b, c, d, x[i+ 9], S21, 0x21E1CDE6); // 25
				d = GG(d, a, b, c, x[i+14], S22, 0xC33707D6); // 26
				c = GG(c, d, a, b, x[i+ 3], S23, 0xF4D50D87); // 27
				b = GG(b, c, d, a, x[i+ 8], S24, 0x455A14ED); // 28
				a = GG(a, b, c, d, x[i+13], S21, 0xA9E3E905); // 29
				d = GG(d, a, b, c, x[i+ 2], S22, 0xFCEFA3F8); // 30
				c = GG(c, d, a, b, x[i+ 7], S23, 0x676F02D9); // 31
				b = GG(b, c, d, a, x[i+12], S24, 0x8D2A4C8A); // 32

				// Round 3
				a = HH(a, b, c, d, x[i+ 5], S31, 0xFFFA3942); // 33
				d = HH(d, a, b, c, x[i+ 8], S32, 0x8771F681); // 34
				c = HH(c, d, a, b, x[i+11], S33, 0x6D9D6122); // 35
				b = HH(b, c, d, a, x[i+14], S34, 0xFDE5380C); // 36
				a = HH(a, b, c, d, x[i+ 1], S31, 0xA4BEEA44); // 37
				d = HH(d, a, b, c, x[i+ 4], S32, 0x4BDECFA9); // 38
				c = HH(c, d, a, b, x[i+ 7], S33, 0xF6BB4B60); // 39
				b = HH(b, c, d, a, x[i+10], S34, 0xBEBFBC70); // 40
				a = HH(a, b, c, d, x[i+13], S31, 0x289B7EC6); // 41
				d = HH(d, a, b, c, x[i+ 0], S32, 0xEAA127FA); // 42
				c = HH(c, d, a, b, x[i+ 3], S33, 0xD4EF3085); // 43
				b = HH(b, c, d, a, x[i+ 6], S34, 0x04881D05); // 44
				a = HH(a, b, c, d, x[i+ 9], S31, 0xD9D4D039); // 45
				d = HH(d, a, b, c, x[i+12], S32, 0xE6DB99E5); // 46
				c = HH(c, d, a, b, x[i+15], S33, 0x1FA27CF8); // 47
				b = HH(b, c, d, a, x[i+ 2], S34, 0xC4AC5665); // 48

				// Round 4
				a = II(a, b, c, d, x[i+ 0], S41, 0xF4292244); // 49
				d = II(d, a, b, c, x[i+ 7], S42, 0x432AFF97); // 50
				c = II(c, d, a, b, x[i+14], S43, 0xAB9423A7); // 51
				b = II(b, c, d, a, x[i+ 5], S44, 0xFC93A039); // 52
				a = II(a, b, c, d, x[i+12], S41, 0x655B59C3); // 53
				d = II(d, a, b, c, x[i+ 3], S42, 0x8F0CCC92); // 54
				c = II(c, d, a, b, x[i+10], S43, 0xFFEFF47D); // 55
				b = II(b, c, d, a, x[i+ 1], S44, 0x85845DD1); // 56
				a = II(a, b, c, d, x[i+ 8], S41, 0x6FA87E4F); // 57
				d = II(d, a, b, c, x[i+15], S42, 0xFE2CE6E0); // 58
				c = II(c, d, a, b, x[i+ 6], S43, 0xA3014314); // 59
				b = II(b, c, d, a, x[i+13], S44, 0x4E0811A1); // 60
				a = II(a, b, c, d, x[i+ 4], S41, 0xF7537E82); // 61
				d = II(d, a, b, c, x[i+11], S42, 0xBD3AF235); // 62
				c = II(c, d, a, b, x[i+ 2], S43, 0x2AD7D2BB); // 63
				b = II(b, c, d, a, x[i+ 9], S44, 0xEB86D391); // 64

				a += aa;
				b += bb;
				c += cc;
				d += dd;
			}

			// Finish up by concatening the buffers with their hex output
			return NumberUtils.toHex( a ) + NumberUtils.toHex( b ) + NumberUtils.toHex( c ) + NumberUtils.toHex( d );
		}

		/**
		 * @private
		 * F, G, H and I are basic MD5 functions.
		 */
		private static function F(x:uint, y:uint, z:uint):uint	{ return ( x & y ) | ( ( ~x ) & z ) }
		private static function G(x:uint, y:uint, z:uint):uint	{ return ( x & z ) | ( y & ( ~z ) ) }
		private static function H(x:uint, y:uint, z:uint):uint	{ return x ^ y ^ z }
		private static function I(x:uint, y:uint, z:uint):uint	{ return y ^ ( x | ( ~z ) ) }
		
		/**
		 * @private
		 * FF, GG, HH, and II transformations for rounds 1, 2, 3, and 4.
		 * Rotation is separate from addition to prevent recomputation.
		 */
		private static function transform(func:Function, a:uint, b:uint, c:uint, d:uint, x:uint, s:uint, t:uint):uint {
			a += int( func( b, c, d ) ) + x + t;
			return NumberUtils.rol( a, s ) +  b;
		}
		private static function FF(a:uint, b:uint, c:uint, d:uint, x:uint, s:uint, t:uint):uint	{ return transform(F, a, b, c, d, x, s, t) }
		private static function GG(a:uint, b:uint, c:uint, d:uint, x:uint, s:uint, t:uint):uint	{ return transform(G, a, b, c, d, x, s, t) }
		private static function HH(a:uint, b:uint, c:uint, d:uint, x:uint, s:uint, t:uint):uint	{ return transform(H, a, b, c, d, x, s, t) }
		private static function II(a:uint, b:uint, c:uint, d:uint, x:uint, s:uint, t:uint):uint	{ return transform(I, a, b, c, d, x, s, t) }
		
	}

}