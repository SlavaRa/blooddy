////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image {

	import by.blooddy.crypto.image.palette.IPalette;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class PNG8Encoder {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static native function encode(image:BitmapData, palette:IPalette=null, filter:uint=0):ByteArray;
		
	}
	
}