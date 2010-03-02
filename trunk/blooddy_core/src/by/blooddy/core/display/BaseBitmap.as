////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 1, 2010 12:06:35 PM
	 */
	public class BaseBitmap extends Bitmap {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function BaseBitmap(bitmapData:BitmapData=null, pixelSnapping:String='auto', smoothing:Boolean=false) {
			super( bitmapData, pixelSnapping, smoothing );
			new DisplayObjectListener( this );
		}
		
	}

}