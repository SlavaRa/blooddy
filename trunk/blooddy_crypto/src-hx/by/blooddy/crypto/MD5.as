////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto {

	import flash.utils.ByteArray;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class MD5 {
		
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
		public static native function hash(s:String):String;
		
		/**
		 * Performs the MD5 hash algorithm on a ByteArray.
		 *
		 * @param	data			The ByteArray data to hash
		 *
		 * @return					A string containing the hash value of data
		 *
		 * @keyword					md5.hash, hash
		 */
		public static native function hashBytes(data:ByteArray):String;

	}
	
}