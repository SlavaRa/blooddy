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
			this._table = MedianCutPaletteHelper.createTable( image, maxColors );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _table:ByteArray;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function getColors():Vector.<uint> {
			this._table.position = 0;
			var l:uint = this._table.readUnsignedByte() + 1;
			var result:Vector.<uint> = new Vector.<uint>( l, true );
			for ( var i:uint = 0; i<l; i++ ) {
				result[ i ] = this._table.readUnsignedInt();
			}
			return result;
		}

		public function getIndexByColor(color:uint):uint {
			return MedianCutPaletteHelper.getIndexByColorFromTable( this._table, color );
		}

	}
	
}