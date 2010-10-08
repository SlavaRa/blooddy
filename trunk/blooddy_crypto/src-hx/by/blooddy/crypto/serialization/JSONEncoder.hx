////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.serialization;

import by.blooddy.system.Memory;
import by.blooddy.utils.ByteArrayUtils;
import by.blooddy.utils.Char;
import flash.Error;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class JSONEncoder {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function encode(value:Dynamic):String {
		
		var writeValue:ByteArray->Dynamic->Void;
		
		writeValue = function(_memory:ByteArray, value:Dynamic):Void {
			
		}
		
		return null;
	}
	
}

/**
 * @private
 */
private class TMP {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function writeCharCode(_position:UInt, c:UInt):Void {
		Memory.setByte( _position++, c );
	}

	public static inline function writeBoolean(_position:UInt, value:Bool):Void {
		if ( value ) {
			Memory.setI32( _position, 0x65757274 );
			_position += 4;
		} else {
			Memory.setI32( _position, 0x736c6166 );
			_position += 4;
			Memory.setByte( _position, 0x65 );
			++_position;
		}
	}

	public static inline function writeNull(_position:UInt):Void {
		Memory.setI32( _position, 0x6c6c756e );
		_position += 4;
	}

	public static inline function writeNumber(_memory:ByteArray, _position:UInt, value:Float):Void {
		_memory.position = _position;
		_memory.writeUTFBytes( untyped value.toString() );
		_position = _memory.position;
	}

	public static inline function writeStringEmpty(_position:UInt):Void {
		Memory.setI16( _position, 0x2222 );
		_position += 2;
	}

	public static inline function writeString(_memory:ByteArray, _position:UInt, value:String):Void {
		writeCharCode( _position, Char.DOUBLE_QUOTE );

		// write temp string
		var i:UInt = _position + value.length * 2;
		var j:UInt = i;
		_memory.position = i;
		_memory.writeUTFBytes( value );
		var len:UInt = _memory.position;

		var c:UInt;
		do {
			c = Memory.getByte( i );
			if ( c == Char.CARRIAGE_RETURN ) {
				
			} else if ( c == Char.NEWLINE ) {
				
			} else if ( c == Char.TAB ) {
				
			} else if ( c == Char.DOUBLE_QUOTE ) {
				
			} else if ( c == Char.BACK_SLASH ) {
				
			} else if ( c == Char.VERTICAL_TAB ) {
				
			} else if ( c == Char.BACKSPACE ) {
				
			} else if ( c == Char.FORM_FEED ) {
				
			} else if ( c < Char.SPACE ) {
				
			}
		} while ( ++i < len );
		
		_memory.position = _position;


		_position = _memory.position;
		writeCharCode( _position, Char.DOUBLE_QUOTE );
	}

}