////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.phpon {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					15.06.2010 21:00:25
	 */
	public final class PHPON {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _parser:PHPONParser = new PHPONParser();
		
		/**
		 * @private
		 */
		private static const _FUNCTION:QName = new QName( '', 'Function' );
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function decode(value:String):* {
			return _parser.parse( value );
		}
		
		public static function encode(value:*):String {
			return encodeValue( value, new Array() );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function encodeValue(value:*, list:Array):String {
			return null;
		}
		
	}
	
}