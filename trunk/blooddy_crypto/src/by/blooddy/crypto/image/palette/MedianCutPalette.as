////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image.palette {

	import flash.utils.ByteArray;
	import flash.display.BitmapData;
	import flash.utils.Endian;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					04.07.2010 1:48:54
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
			var arr:Array = MedianCutPaletteHelper.createTable( image, maxColors );
			this._list = arr[ 0 ];
			this._hash = arr[ 1 ];
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _list:Vector.<uint>;

		/**
		 * @private
		 */
		private var _hash:Array;
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function getColors():Vector.<uint> {
			return this._list.slice();
		}

		public function getIndexByColor(color:uint):uint {
			return this._hash[ color ];
		}

	}
	
}