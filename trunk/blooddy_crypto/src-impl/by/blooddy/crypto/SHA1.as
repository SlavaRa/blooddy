////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto {

	import flash.utils.ByteArray;
	
	/**
	 * Encodes and decodes binary data using 
	 * <a herf="http://www.faqs.org/rfcs/rfc3174.html">SHA1 (Secure Hash Algorithm)</a> algorithm.
	 * 
	 * @author					BlooDHounD
	 * @version					2.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					03.10.2010 21:07:00
	 */
	public class SHA1 {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Performs SHA1 hash algorithm on a String.
		 *
		 * @param	str		The string to hash.
		 *
		 * @return			A string containing the hash value of <code>source</code>.
		 *
		 * @keyword			sha1.hash, hash
		 */
		public static native function hash(str:String):String;
		
		/**
		 * Performs SHA1 hash algorithm on a <code>ByteArray</code>.
		 *
		 * @param	data	The <code>ByteArray</code> data to hash.
		 *
		 * @return			A string containing the hash value of data.
		 *
		 * @keyword			sha1.hashBytes, hashBytes
		 */
		public static native function hashBytes(data:ByteArray):String;
		
	}
	
}