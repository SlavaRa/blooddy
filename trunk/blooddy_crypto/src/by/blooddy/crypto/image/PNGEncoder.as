////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image {

	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.07.2010 17:44:26
	 */
	public class PNGEncoder {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public static function encode(image:BitmapData, filter:uint=0):ByteArray {
			var size:uint = image.width * image.height;
			if ( size >= 32 && size <= 64 ) return PNG8Encoder.encode( image, null, filter );
			else return PNG24Encoder.encode( image, filter );
		}
		
	}
	
}