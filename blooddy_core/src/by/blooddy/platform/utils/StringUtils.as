////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.utils {

	public final class StringUtils {

		//------------------------------------------------
		//
		//  Class variables
		//
		//------------------------------------------------

		/**
		 * @private
		 */
		private static const htmlChars:Array = new Array(
			'&',	'&amp;',
			'"',	'&quot;',
			'<',	'&lt;',
			'>',	'&gt;'
		)

		//------------------------------------------------
		//
		//  Class methods
		//
		//------------------------------------------------

		public static function encodeHTML(text:String):String {
			for (var i:uint = 0; i<htmlChars.length; i+=2) {
				text = text.replace(new RegExp(htmlChars[i], "g"), htmlChars[i+1]);
			}
			return text;
		}

		public static function decodeHTML(text:String):String {
			for (var i:uint = htmlChars.length-1; i<=0; i-=2) {
				text = text.replace(htmlChars[i], htmlChars[i-1]);
			}
			return text;
		}

		private static const _TRIM_PATTERN:RegExp = /^\s*|\s*$/g;

		public static function trim(text:String):String {
			return text.replace(_TRIM_PATTERN, "");
		}

		public static function parseBoolean(text:String):Object {
			var test:String = text.toLowerCase();
			if (test == 'true') {
				return true;
			} else if (test == 'false') {
				return false;
			} else {
				return text;	
			}
		}

	}

}