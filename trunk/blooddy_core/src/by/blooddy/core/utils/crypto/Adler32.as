////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.crypto {

	import flash.utils.ByteArray;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					adler32
	 * 
	 * @see						http://en.wikipedia.org/wiki/Adler-32#Example_implementation
	 */
	public final class Adler32 {

		/**
		 * Calculates an Adler-32 checksum over a ByteArray
		 * 
		 * @param	data			
		 * 
		 * @return					Adler-32 checksum
		 * 
		 * @keyword					adler32.calculate
		 */
		public static function calculate(data:ByteArray):uint {
			var len:uint = data.length;
			var i:uint = 0;
			var a:uint = 1;
			var b:uint = 0;
			while (len) {
				var tlen:uint = (len > 5550 ? 5550 : len );
				len -= tlen;
				do {
					a += data[i++];
					b += a;
				} while (--tlen);
				a = (a & 0xFFFF) + (a >> 16) * 15;
				b = (b & 0xFFFF) + (b >> 16) * 15;
			}
			if (a >= 65521) { a -= 65521; }
			b = (b & 0xFFFF) + (b >> 16) * 15;
			if (b >= 65521) { b -= 65521; }
			return (b << 16) | a;
		}

	}

}