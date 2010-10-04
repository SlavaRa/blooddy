////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto;

import by.blooddy.system.Memory;
import by.blooddy.utils.ByteArrayUtils;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class SHA1 {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function hash(s:String):String {
		var bytes:ByteArray = new ByteArray();
		bytes.writeUTFBytes( s );
		var result:String = hashBytes( bytes );
		//bytes.clear();
		return result;
	}

	public static function hashBytes(bytes:ByteArray):String {
		return TMP.hashBytes( bytes );
	}

}

/**
 * @private
 */
private class TMP {

	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	public static function hashBytes(bytes:ByteArray):String {

		var len:UInt = bytes.length;
		var mem:ByteArray = Memory.memory;

		var i:UInt = len << 3;
		var bytesLength:UInt = ( ( ( ( i + 64 ) >>> 9 ) << 4 ) + 15 ) << 2; // длинна для подсчёта в блоков

		// копируем массив
		var tmp:ByteArray = ByteArrayUtils.createByteArray( bytesLength + 4 );
		tmp.writeBytes( bytes );

		// помещаем в пямять
		if ( tmp.length < 1024 ) tmp.length = 1024;
		Memory.memory = tmp;

		Memory.memory = mem;

		var result:String = tmp.readUTFBytes( 32 );

		//tmp.clear();

		return result;

	}

}