////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

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

		public static function convertToConstName(name:String):String {
			return name.match( /\w[^A-Z]*/g ).join("_").toUpperCase();
		}

		public static function convertFromConstName(name:String):String {
			var arr:Array = name.split("_");
			var result:String = ( arr.shift() as String ).toLowerCase();
			for each (var word:String in arr) {
				result += word.charAt(0).toUpperCase() + word.substr(1).toLowerCase();
			} 
			return result;
		}

		/**
		 * @param	flag	1 - цифры, 2 - хекс буквы, 4 - весь остальное алфавит
		 */
		public static function random(length:uint=16, flag:uint=3):String {
			var result:String = "";
			var c:uint;
			var chars:Array = new Array();
			var i:uint;
			if ( flag & 1 ) {
				for (i=0; i<10; i++) {
					chars.push( i );
				}
			}
			if ( flag & 4 ) {
				for (i=97; i<123; i++) {
					chars.push( String.fromCharCode(i) );
				}
			} else {
				for (i=97; i<103; i++) {
					chars.push( String.fromCharCode(i) );
				}
			}
			while ( length-- ) {
				result += chars[ Math.round( (chars.length-1) * Math.random() )]
			}
			return result;
		}
		
		/**
		 * 
		 * @param 	count количество объектов(предметов, умений, etc.) от которых зависит окончание существительного
		 * @return 	0 - окончание для 1		1 - окончание для 2, 3, 4		2 - окончание для 0, 5 - 20
		 * 
		 */
		public static function getSuffix(count:uint=0):uint {
			var rest:uint;
		
			if (count >= 10 && count <= 20) {
				rest = count
			} else {
				rest = count % 10;
			}
			
			if ( rest > 0 ) {
				if ( rest < 2 ) {
					return 0;
				} else if ( rest < 5 ) {
					return 1;
				}
			}
			
			return 2;
		}
		
		public static function bytesToString(bytes:Number, fixed:uint = 0):String {
			var m:Number = (bytes < 1024) ? 1 : Math.pow(10, fixed);
			if (bytes >= 1024 * 1024) 		return Math.round(((bytes/1024/1024) * m))/m		+ ' МБ';
			else if (bytes >= 1024) 		return Math.round(((bytes/1024) * m))/m			+ ' КБ';
			else 							return bytes						 				+ ' Б';
		}

	}

}