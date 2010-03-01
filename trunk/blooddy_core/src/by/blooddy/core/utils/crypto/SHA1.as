////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.crypto {

	import by.blooddy.core.utils.math.NumberUtils;
	import flash.utils.ByteArray;
	
	/**
	 * US Secure Hash Algorithm 1 (SHA1)
	 *
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					sha1, crypto, hash
	 * 
	 * @see						http://www.faqs.org/rfcs/rfc3174.html
	 */
	public class SHA1 {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Performs the SHA1 hash algorithm on a string.
		 *
		 * @param		s			The string to hash
		 * 
		 * @return					A string containing the hash value of s
		 * 
		 * @keyword					sha1.hash, hash
		 */
		public static function hash(s:String):String {
			var blocks:Array = createBlocksFromString(s);
			var byteArray:ByteArray = hashBlocks(blocks);
			
			return	NumberUtils.toHex( byteArray.readInt() ) +
					NumberUtils.toHex( byteArray.readInt() ) +
					NumberUtils.toHex( byteArray.readInt() ) +
					NumberUtils.toHex( byteArray.readInt() ) +
					NumberUtils.toHex( byteArray.readInt() );
		}

		/**
		 * Performs the SHA1 hash algorithm on a ByteArray.
		 *
		 * @param	data			The ByteArray data to hash
		 * 
		 * @return					A string containing the hash value of data
		 * 
		 * @keyword					sha1.hashBytes, hashBytes
		 */
		public static function hashBytes(data:ByteArray):String {
			var blocks:Array = createBlocksFromByteArray(data);
			var byteArray:ByteArray = hashBlocks(blocks);
			return	NumberUtils.toHex( byteArray.readInt() ) +
					NumberUtils.toHex( byteArray.readInt() ) +
					NumberUtils.toHex( byteArray.readInt() ) +
					NumberUtils.toHex( byteArray.readInt() ) +
					NumberUtils.toHex( byteArray.readInt() );
		}

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function hashBlocks( blocks:Array ):ByteArray {
			// initialize the h's
			var h0:int = 0x67452301;
			var h1:int = 0xEFCDAB89;
			var h2:int = 0x98BADCFE;
			var h3:int = 0x10325476;
			var h4:int = 0xC3D2E1F0;
			
			var len:int = blocks.length;
			var w:Array = new Array(80);
			
			// loop over all of the blocks
			for ( var i:int = 0; i < len; i += 16 ) {

				// 6.1.c
				var a:int = h0;
				var b:int = h1;
				var c:int = h2;
				var d:int = h3;
				var e:int = h4;
				
				// 80 steps to process each block
				// TODO: unroll for faster execution, or 4 loops of
				// 20 each to avoid the k and f function calls
				for ( var t:int = 0; t < 80; t++ ) {
					
					if ( t < 16 ) {
						// 6.1.a
						w[ t ] = blocks[ i + t ];
					} else {
						// 6.1.b
						w[ t ] = NumberUtils.rol( w[ t - 3 ] ^ w[ t - 8 ] ^ w[ t - 14 ] ^ w[ t - 16 ], 1 );
					}
					
					// 6.1.d
					var temp:int = NumberUtils.rol( a, 5 ) + f( t, b, c, d ) + e + int( w[ t ] ) + k( t );
					
					e = d;
					d = c;
					c = NumberUtils.rol( b, 30 );
					b = a;
					a = temp;
				}
				
				// 6.1.e
				h0 += a;
				h1 += b;
				h2 += c;
				h3 += d;
				h4 += e;		
			}
			
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeInt(h0);
			byteArray.writeInt(h1);
			byteArray.writeInt(h2);
			byteArray.writeInt(h3);
			byteArray.writeInt(h4);
			byteArray.position = 0;
			return byteArray;
		}

		/**
		 * @private
		 * Performs the logical function based on t
		 */
		private static function f(t:int, b:int, c:int, d:int):int {
			if ( t < 20 )		return ( b & c ) | ( ~b & d );
			else if ( t < 40 )	return b ^ c ^ d;
			else if ( t < 60 )	return ( b & c ) | ( b & d ) | ( c & d );
			else				return b ^ c ^ d;
		}

		/**
		 * @private
		 * Determines the constant value based on t
		 */
		private static function k(t:int):int {
			if ( t < 20 )		return 0x5A827999;
			else if ( t < 40 )	return 0x6ED9EBA1;
			else if ( t < 60 )	return 0x8F1BBCDC;
			else				return 0xCA62C1D6;
		}

	}

}