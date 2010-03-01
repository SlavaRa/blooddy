////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					bytearray, bytearrayutils, utils
	 */
	public final class ByteArrayUtils {

		public static function bytesToHashString(bytes:ByteArray):String {
			var l:uint = bytes.length;
			var arr:Array = new Array();
			for ( var i:uint = 0; i<l; i++ ) {
				arr[i] = bytes[i] & 0xFF;
			}
			return String.fromCharCode.apply( String, arr );
		}

		public static function bytesToString(bytes:ByteArray, separator:String=""):String {
			var arr:Array = new Array();
			var l:uint = bytes.length;
			var ch:String;
			for ( var i:uint = 0; i<l; i++ ) {
				ch = bytes[i].toString( 16 );
				arr.push( ch.length < 2 ? '0' + ch : ch );
			}
			return arr.join(separator);
		}

		public static function stringToBytes(s:String, separator:String=""):ByteArray {
			var bytes:ByteArray = new ByteArray();
			var arr:Array, l:uint, i:uint;
			if ( separator ) {
				arr = s.split(separator);
				l = arr.length;
				for (i=0; i<l; i++) {
					bytes.writeByte( parseInt( arr[i] as String, 16 ) );
				}
			} else {
				l = s.length;
				for (i=0; i<l; i+=2) {
					bytes.writeByte( parseInt( s.substr(i, 2), 16 ) );
				}
			}
			bytes.position = 0;
			return bytes;
		}

		public static function spliceBytes(bytes:ByteArray, startIndex:uint, deleteCount:uint, input:IDataInput=null):void {
			var pos:uint = bytes.position;
			var tmp:ByteArray;
			if ( startIndex + deleteCount < bytes.length ) {
				tmp = new ByteArray();
				bytes.position = startIndex + deleteCount;
				bytes.readBytes(tmp);
			}
			bytes.length = startIndex;
			bytes.position = startIndex;
			if ( input && input.bytesAvailable>0 ) {
				input.readBytes(bytes, bytes.length);
			}
			if ( tmp ) tmp.readBytes(bytes, bytes.length);
			bytes.position = pos;
		}

		public static function dump(bytes:ByteArray, offset:uint=0, length:uint=0):String {
			offset = Math.min( offset, bytes.length );
			length = Math.min( length, bytes.length ) || bytes.length;

			var result:String = "";
			var col:uint;
			var p:uint;
			var line_s:String;
			var code:uint;
			var i:uint = offset;
			if ( i % 16 != 0 ) { // есть пропущеные байты
				var rest:int = i % 0xF;
				result += ( '00000000' + ( i - rest ).toString( 16 ).toUpperCase() ).substr( -8 ) + ':  ';
				if ( rest >= 8 ) result += ' ';
				p = 0;
				line_s = "";
				do {
					result += '   ';
					line_s += ' ';
				} while ( ++p < rest );
				for ( col=( rest < 8 ? 0 : 1 ); col<2; col++ ) {
					for ( p=p%8; p<8 && i<length; p++, i++ ) {
						code = ( bytes[ i ] & 0xFF );
						result += ( '0' + code.toString( 16 ).toUpperCase() ).substr( -2 ) + ' ';
						line_s += ( code >= 32 && code <= 126 ? String.fromCharCode( code ) : '.' );
					}
					while ( p++ < 8 ) {
						result += '   ';
						line_s += ' ';
					}
					result += ' ';
				}
				result += '|' + line_s + '|';
				if ( i < length ) result += '\n';
			}
			while ( i<length ) {
				result += ( '00000000' + i.toString( 16 ).toUpperCase() ).substr( -8 ) + ':  ';
				line_s = '';
				for ( col=0; col<2; col++ ) {
					for ( p=0; p<8 && i<length; p++, i++ ) {
						code = ( bytes[ i ] & 0xFF );
						result += ( '0' + code.toString( 16 ).toUpperCase() ).substr( -2 ) + ' ';
						line_s += ( code >= 32 && code <= 126 ? String.fromCharCode( code ) : '.' );
					}
					while ( p++ < 8 ) {
						result += '   ';
						line_s += ' ';
					}
					result += ' ';
				}
				result += '|' + line_s + '|';
				if ( i < length ) result += '\n';
			}
			return result;
		}

	}

}