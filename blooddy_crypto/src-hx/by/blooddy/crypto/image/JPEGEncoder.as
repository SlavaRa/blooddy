////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image {

	import flash.utils.ByteArray;
	import flash.display.BitmapData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class JPEGEncoder {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Created a JPEG image from the specified BitmapData
		 *
		 * @param	image	The BitmapData that will be converted into the JPEG format.
		 * @param	quality	The quality level between 1 and 100 that detrmines the level of compression used in the generated JPEG
		 *
		 * @return a ByteArray representing the JPEG encoded image data.
		 */
		public static native function encode(image:BitmapData, quality:uint=60):ByteArray;
		
	}
	
}