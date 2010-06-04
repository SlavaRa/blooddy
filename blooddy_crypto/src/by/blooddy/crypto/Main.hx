package by.blooddy.crypto;

import flash.Lib;
import flash.utils.ByteArray;
import flash.Memory;

/**
 * ...
 * @author BlooDHounD
 */

class Main {
	
	static function main() {
		MD5;

		//var i:UInt = 0;
		//while ( i++ < 64 ) {
		//var len = i * 8;
		//trace( i +' ' + ( ( ( ( len + 64 ) >>> 9 ) << 4 ) + 14 ) * 4 );
		//}

		trace( by.blooddy.crypto.MD5.hash( 'хуй' ) );
		
		//var i:UInt = 0;
		//while ( i < 64 ) {
			//trace( 'i = ' + i + ';		blocks[ ' + ( i >> 5 ) + ' ] |= bytes[ cast( ' + ( i / 8 ) + ' ) ] << ( ' + ( i % 32 ) + ' );' );
			//i += 8;
		//}
		
	}
	
}