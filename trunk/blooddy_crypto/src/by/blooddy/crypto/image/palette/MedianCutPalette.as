////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image.palette {

	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.06.2010 23:05:22
	 */
	public class MedianCutPalette implements IPalette {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function MedianCutPalette(image:BitmapData, maxColors:uint=256) {
			super();

			if ( maxColors < 2 || maxColors > 256 ) Error.throwError( RangeError, 2006 );

			var colors:Array = new Array();

			var width:uint = image.width;
			var height:uint = image.height;

			var c:uint;

			if ( image.transparent ) {
				var pixels:ByteArray = image.getPixels( image.rect );
				pixels.position = 0;
				while ( pixels.bytesAvailable ) {
					c = pixels.readUnsignedInt();
					colors[ c ] = c;
				}
			} else {
				var x:uint;
				var y:uint;
				for ( y=0; y<height; y++ ) {
					for ( x=0; x<width; x++ ) {
						c = image.getPixel( x, y );
						colors[ c ] = c;
					}
				}
			}

			var points:Array = new Array();
			for each ( c in colors ) {
				points.push( c );
			}
//			trace( points );
			
		}

		/**
		 * @private
		 */
		private const _blocks:Vector.<Block> = new Vector.<Block>();

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function getIndexByColor(color:uint):uint {
			return 0;
		}

	}

}

internal final class Block {
	
	public function Block() {
		super();
	}

}