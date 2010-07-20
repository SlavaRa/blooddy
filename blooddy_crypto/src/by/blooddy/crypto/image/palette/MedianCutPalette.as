////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image.palette {

	import flash.display.BitmapData;
	
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
		 * Создаёт объект MedianCutPalette
		 * 
		 * @param	image		картинка, на основании которой необходимо построить палитру.
		 * @param	maxColors	максимальное количество цветов. ограничевается в предлах от 2 до 256.
		 * 
		 * @throw	TypeError	параметр image не должен быть равен null;
		 * @throw	RangeError	количество цветов заданно в неверном диапазоне
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

		/**
		 * @inheritDoc
		 */
		public function getColors():Vector.<uint> {
			return this._list.slice();
		}

		/**
		 * @inheritDoc
		 */
		public function getIndexByColor(color:uint):uint {
			return this._hash[ color ];
		}

	}
	
}