////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.crypto {

	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	 * Converts a ByteArray to a sequence of 16-word blocks
	 * that we'll do the processing on.  Appends padding
	 * and length in the process.
	 * 
	 * @param	data		The data to split into blocks
	 * 
	 * @return				An array containing the blocks into which data was split
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	internal function createBlocksFromByteArray(bytes:ByteArray):Array {
		var pos:int = bytes.position;
		bytes.position = 0;

		var blocks:Array = new Array();
		var len:int = bytes.length * 8;
		var mask:int = 0xFF; // ignore hi byte of characters > 0xFF
		for( var i:int = 0; i < len; i += 8 ) {
//			blocks[ i >> 5 ] |= ( bytes[i/8] & mask ) << ( 24 - i % 32 );
			blocks[ i >> 5 ] |= bytes[i/8] << ( i % 32 );
		}

		// append padding and length
//		blocks[ len >> 5 ] |= 0x80 << ( 24 - len % 32 );
		blocks[ len >> 5 ] |= 0x80 << ( len % 32 );
//		blocks[ ( ( ( len + 64 ) >> 9 ) << 4 ) + 15 ] = len;
		blocks[ ( ( ( len + 64 ) >>> 9 ) << 4 ) + 14 ] = len;

		bytes.position = pos;

		return blocks;
	}

}