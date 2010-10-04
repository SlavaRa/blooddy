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
	 * @created					01.10.2010 15:53:38
	 */
	public class JSON {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @copy	by.blooddy.crypto.serialization.JSONEncoder#encode()
		 */
		public static function encode(value:*):String {
			return JSONEncoder.encode( value );
		}

		/**
		 * @copy	by.blooddy.crypto.serialization.JSONDecoder#decode()
		 */
		public static function decode(value:String):* {
			return JSONDecoder.decode( value );
		}
		
	}
	
}