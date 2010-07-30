////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image {

	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	/**
	 * Encodes image data using 
	 * <a href="http://www.w3.org/TR/PNG-Compression.html">PNG</a> compression 
	 * algorithm. This class may use 
	 * different compression techniques provided in <code>PNG8Encoder</code> and
	 * <code>PNG24Encoder</code>.
	 * 
	 * @see	by.blooddy.crypto.image.PNG8Encoder
	 * @see	by.blooddy.crypto.image.PNG24Encoder
	 * @see	by.blooddy.crypto.image.palette.IPalette
	 * @see	by.blooddy.crypto.image.PNGFilter
	 * 
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
		
		/**
		 * Creates a PNG-encoded byte sequence from the specified <code>BitmapData</code>
		 * 
		 * @param	image		The <code>BitmapData</code> of the image you wish to encode.
		 * 
		 * @param	filter		The encoding algorithm you wish to apply while encoding.
		 * 						Use the constants provided in 
		 * 						<code>by.blooddy.crypto.image.PNGFilter</code> class.
		 * @see					by.blooddy.crypto.image.PNGFilter
		 * @default				<code>PNGFilter.NONE</code>
		 * 
		 * @see					by.blooddy.crypto.image.PNG8Encoder.encode()
		 * @see					by.blooddy.crypto.image.PNG24Encoder.encode()
		 * 
		 * @return	The sequence of bytes containing the encoded image.
		 */
		public static function encode(image:BitmapData, filter:uint=0):ByteArray {
			var size:uint = image.width * image.height;
			if ( size >= 32 && size <= 64 ) return PNG8Encoder.encode( image, null, filter );
			else return PNG24Encoder.encode( image, filter );
		}
		
	}
	
}