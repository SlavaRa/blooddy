package by.blooddy.core.utils {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					xml
	 */
	public final class XMLUtils {

		public static function parseStringNode(list:XMLList):String {
			if ( list.length() > 0 ) {
				return list[0].toString();
			}
			return null;
		}

		public static function parseDateNode(list:XMLList):Date {
			if ( list.length() > 0 ) {
				return new Date( Date.parse( list[0].toString() ) );
			}
			return null;
		}

		public static function parseUIntNode(list:XMLList):uint {
			if ( list.length() > 0 ) {
				return parseInt( list[0].toString() );
			}
			return null;
		}

		public static function parseBooleanNode(list:XMLList):Boolean {
			if ( list.length() > 0 ) {
				return parseBoolean( list[0].toString() );
			}
			return false;
		}

	}

}