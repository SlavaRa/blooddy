////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image {

	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	/**
	 * Encodes image data using 24 bits of color information per pixel.
	 * 
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
		 * Creates a PNG image from the specified <code>BitmapData</code>
		 *
		 * @param	image	The <code>BitmapData</code> to be converted to PNG format.
		 * 
		 * @param	filter	The encoding algorithm to use when processing the image.
		 * 					Use the constants provided in 
		 * 					<code>by.blooddy.crypto.image.PNGFilter</code> class.
		 * @see				by.blooddy.crypto.image.PNGFilter
		 * @default			<code>PNGFilter.NONE</code>
		 * 
		 * @return			a <code>ByteArray</code> containing the PNG encoded image data.
		 */
		public static native function encode(image:BitmapData, filter:uint=0):ByteArray;
		
	}
	
}