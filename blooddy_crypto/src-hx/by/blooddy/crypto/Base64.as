////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto {

	import flash.utils.ByteArray;
	
	/**
	 * Encodes and decodes binary data using 
	 * <a herf="http://tools.ietf.org/html/rfc4648">Base64</a> encoding algorithm.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class Base64 {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Encodes the <code>bytes</code> while conditionally inserting line breaks.
		 * 
		 * @param	bytes			The data to be encoded.
		 * 
		 * @param	insertNewLines	If <code>true</code> passed, the resulting 
		 * 							string will contain line breaks.
		 * 
		 * @default	<code>false</code>
		 * 
		 * @return	The data encoded.
		 */
		public static native function encode(bytes:ByteArray, insertNewLines:Boolean=false):String;
		
		/**
		 * Decodes the <code>source</code> string previously encoded using Base64
		 * algorithm.
		 * 
		 * @param	source	The string containing encoded data.
		 * 
		 * @return	The array of bytes obtained by decoding the <code>source</code>
		 * 			string.
		 */
		public static native function decode(source:String):ByteArray;
		
	}
	
}