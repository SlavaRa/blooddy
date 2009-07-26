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
	 * @keyword					crc32
	 * 
	 * @see						http://www.w3.org/TR/PNG/#D-CRCAppendix
	 */
	public final class CRC32 {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Calculates a CRC-32 checksum over a ByteArray
		 * 
		 * @param	data			
		 * 
		 * @return					CRC-32 checksum
		 * 
		 * @keyword					crc32.calculate
		 */
		public static function calculate(data:ByteArray):uint {
			var len:uint = data.length;
			var i:uint;
			var c:uint = 0xFFFFFFFF;
			for (i = 0; i < len; i++) {
				c = uint(CRC_TABLE[(c ^ data[i]) & 0xff]) ^ (c >>> 8);
			}
			return (c ^ 0xFFFFFFFF);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const CRC_TABLE:Array = createCRCTable();
		
		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function createCRCTable():Array {
			var table:Array = new Array();
			var i:uint;
			var j:uint;
			var c:uint;
			for (i = 0; i < 256; i++) {
				c = i;
				for (j = 0; j < 8; j++) {
					if (c & 1) {
						c = 0xEDB88320 ^ (c >>> 1);
					} else {
						c >>>= 1;
					}
				}
				table.push(c);
			}
			return table;
		}
		
	}

}