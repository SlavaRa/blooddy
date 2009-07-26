package by.blooddy.core.utils.crypto {
	import flash.utils.ByteArray;
	

	/**
	 * Converts a string to a sequence of 16-word blocks
	 * that we'll do the processing on.  Appends padding
	 * and length in the process.
	 *
	 * @param	s			The string to split into blocks
	 * 
	 * @return				An array containing the blocks that s was split into.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	internal function createBlocksFromString(s:String):Array {
		var bytes:ByteArray = new ByteArray();
		bytes.writeUTFBytes(s);
		return createBlocksFromByteArray( bytes );
//		var blocks:Array = new Array();
//		var len:int = s.length * 8;
//		var mask:int = 0xFF; // ignore hi byte of characters > 0xFF
//		for( var i:int = 0; i < len; i += 8 ) {
////			blocks[ i >> 5 ] |= ( s.charCodeAt( i / 8 ) & mask ) << ( 24 - i % 32 );
//			blocks[ i >> 5 ] |= ( s.charCodeAt( i / 8 ) & mask ) << ( i % 32 );
//		}
//		// append padding and length
////		blocks[ len >> 5 ] |= 0x80 << ( 24 - len % 32 );
//		blocks[ len >> 5 ] |= 0x80 << ( len % 32 );
////		blocks[ ( ( ( len + 64 ) >> 9 ) << 4 ) + 15 ] = len;
//		blocks[ ( ( ( len + 64 ) >>> 9 ) << 4 ) + 14 ] = len;
//		return blocks;
	}

}