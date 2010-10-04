////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.serialization {
	
	/**
	 * @author					BlooDHounD
	 * @version					2.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					01.10.2010 19:31:27
	 */
	public class JSONDecoder {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @param	value
		 *
		 * @return
		 *
		 * @throws	SyntaxError
		 */
		public static native function decode(value:String):*;

	}
	
}