////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.crypto {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					ip, utils
	 * 
	 * @see						flash.net.XMLSocket
	 */
	public final class IP {

		/**
		 * Превращаем IP в число.
		 * 
		 * @param	IP				Строковый вид IP.
		 * 
		 * @return					Возвращаем числовой вид IP.
		 * 
		 * @keyword					ip.encode, encode
		 */
		public static function encode(IP:String = "0.0.0.0"):uint {
			var tmp:Array = IP.split(".", 4);
			var result:uint = 0;
			for (var i:uint = 0; i<4; i++) {
				result |= Math.min(uint(tmp[i]), 0xFF) << (3-i)*8;
			}
			return result;
		}

		/**
		 * Превращаем число в IP.
		 * 
		 * @param	IP		Числовой вид IP.
		 * 
		 * @return			Возвращаем строковый вид IP.
		 * 
		 * @keyword					ip.decode, decode
		 */
		public static function decode(IP:uint = 0x000000):String {
			var tmp:Array = new Array();
			for (var i:uint = 0; i<4; i++) {
				tmp[i] = ( IP >> (3-i)*8 ) & 0xFF;
			}
			return tmp.join(".");
		}

	}
}