////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image {

	import flash.utils.ByteArray;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.06.2010 3:07:56
	 */
	public final class JPEGTable {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _quantTables:Object = new Object();

		/**
		 * @private
		 */
		private static var _huffmanTable:ByteArray;

		/**
		 * @private
		 */
		private static var _categoryTable:ByteArray;

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function getTable(quality:uint=60):ByteArray {
			if ( quality > 100 ) throw new ArgumentError();
			var quantTable:ByteArray = _quantTables[ quality ];
			if ( !quantTable ) {
				quantTable = JPEGTableHelper.createQuantTable( quality );
				if ( !_huffmanTable ) {
					_huffmanTable = JPEGTableHelper.createHuffmanTable();
					_categoryTable = JPEGTableHelper.createCategoryTable();
				}
			}
			var result:ByteArray = new ByteArray();
			result.writeBytes( quantTable );
			result.writeBytes( _huffmanTable );
			result.writeBytes( _categoryTable );
			result.position = 0;
			return result;
		}

	}
	
}