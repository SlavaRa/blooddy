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
	 */
	public class PNG24Encoder {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Created a PNG image from the specified BitmapData
		 *
		 * @param	image	The BitmapData that will be converted into the PNG format.
		 * @return			a ByteArray representing the PNG encoded image data.
		 */
		public static native function encode(image:BitmapData, filter:uint=0):ByteArray;
		
	}
	
}