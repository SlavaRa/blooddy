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
	}

}