////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.utils;

import by.blooddy.utils.Char;
import by.blooddy.system.Memory;
import flash.Error;
import flash.utils.ByteArray;

class MemoryScanner {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function readCharCode(_position:UInt, ?single:Bool=true):UInt {
		return TMP.readCharCode( _position, single );
	}

	public static inline function readChar(_position:UInt, ?single:Bool=true):String {
		return TMP.readChar( _position, single );
	}
	
	public static inline function readIdentifier(_memory:ByteArray, _position:UInt):String {
		return TMP.readIdentifier( _memory, _position );
	}

	public static inline function readString(_memory:ByteArray, _position:UInt):String {
		return TMP.readString( _memory, _position );
	}

	public static inline function readNumber(_memory:ByteArray, _position:UInt):String {
		return TMP.readNumber( _memory, _position );
	}

	public static inline function skipBlockComment(_position:UInt):UInt {
		return TMP.skipBlockComment( _position );
	}

	public static inline function readBlockComment(_memory:ByteArray, _position:UInt):String {
		return TMP.readBlockComment( _memory, _position );
	}

	public static inline function skipLine(_position:UInt):Void {
		TMP.skipLine( _position );
	}

	public static inline function readLine(_memory:ByteArray, _position:UInt):String {
		return TMP.readLine( _memory, _position );
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

	public static inline function readCharCode(_position:UInt, ?single:Bool=true):UInt {
		if ( single ) {
			return Memory.getByte( _position++ );
		} else {
			var c:UInt = Memory.getByte( _position );
			if ( c >= 0x80 ) {
				if ( ( c & 0xF8 ) == 0xF0 ) {			// 4 bytes

					c =	( ( c                             & 0x7  ) << 18 ) |
						( ( Memory.getByte( ++_position ) & 0x3F ) << 12 ) |
						( ( Memory.getByte( ++_position ) & 0x3F ) <<  6 ) |
						(   Memory.getByte( ++_position ) & 0x3F         ) ;

				} else if ( ( c & 0xF0 ) == 0xE0 ) {	// 3 bytes

					c =	( ( c                             & 0xF  ) << 12 ) |
						( ( Memory.getByte( ++_position ) & 0x3F ) <<  6 ) |
						(   Memory.getByte( ++_position ) & 0x3F         ) ;

				} else if ( ( c & 0xE0 ) == 0xC0 ) {	// 2 bytes

					c =	( ( c                             & 0x1F ) <<  6 ) |
						(   Memory.getByte( ++_position ) & 0x3F         ) ;

				}
			}
			++_position;
			return c;
		}
	}

	public static inline function readChar(_position:UInt, ?single:Bool=true):String {
		var c:UInt = readCharCode( _position, single );
		return String.fromCharCode( c );
	}

	public static inline function readIdentifier(_memory:ByteArray, _position:UInt):String {
		var pos:UInt = _position;
		var c:UInt = readCharCode( _position, false );
		if (
			( c < Char.a || c > Char.z ) &&
			( c < Char.A || c > Char.Z ) &&
			c != Char.DOLLAR &&
			c != Char.UNDER_SCORE &&
			c <= 0x7f
		) {
			_position = pos;
			return null;
		} else {
			var p:UInt;
			do {
				p = _position;
				c = readCharCode( _position, false ); // bug?
			} while (
				( c >= Char.a && c <= Char.z ) ||
				( c >= Char.A && c <= Char.Z ) ||
				( c >= Char.ZERO && c <= Char.NINE ) ||
				c == Char.DOLLAR ||
				c == Char.UNDER_SCORE ||
				c > 0x7f
			);
			_position = p;
			_memory.position = pos;
			return _memory.readUTFBytes( _position - pos );
		}
	}
	
	public static inline function readString(_memory:ByteArray, _position:UInt):String {
		var pos:UInt = _position;
		var to:UInt = readCharCode( _position );
		if ( to != Char.SINGLE_QUOTE && to != Char.DOUBLE_QUOTE ) {
			--_position;
			return null;
		} else {
			var p:UInt = pos + 1;
			var result:String = '';
			var c:UInt, t:String;
			while ( ( c = readCharCode( _position, false ) ) != to ) {
				if ( c == Char.BACK_SLASH ) {
					_memory.position = p;
					result += _memory.readUTFBytes( _position - 1 - p );
					c = readCharCode( _position );
					if		( c == Char.n )	result += '\n';
					else if	( c == Char.r )	result += '\r';
					else if	( c == Char.t )	result += '\t';
					else if	( c == Char.v )	result += '\x0B';
					else if	( c == Char.f )	result += '\x0C';
					else if	( c == Char.b )	result += '\x08';
					else if	( c == Char.x ) {
						t = readFixedHex( _memory, _position, 2 );
						if ( t != null ) {
							result += String.fromCharCode( untyped __global__["parseInt"]( t, 16 ) );
						} else {
							result += 'x';
						}
					} else if ( c == Char.u ) {
						t = readFixedHex( _memory, _position, 4 );
						if ( t != null ) {
							result += String.fromCharCode( untyped __global__["parseInt"]( t, 16 ) );
						} else {
							result += 'u';
						}
					} else {
						if ( c >= 0x80 ) {
							--_position;
							c = readCharCode( _position, false );
						}
						result += String.fromCharCode( c );
					}
					p = _position;
				} else if (
					c == Char.EOS ||
					c == Char.CARRIAGE_RETURN ||
					c == Char.NEWLINE
				) {
					// откатываемся
					_position = pos;
					break;
				}
			}
			if ( _position == pos ) {
				return null;
			} else {
				if ( p != _position - 1 ) {
					_memory.position = p;
					result += _memory.readUTFBytes( _position - 1 - p );
				}
				return result;
			}
		}
	}

	public static inline function readNumber(_memory:ByteArray, _position:UInt):String {
		var pos:UInt = _position;
		var c:UInt = readCharCode( _position );
		var t:String;
		var s:String;
		var result:String = null;
		if ( c == Char.DASH ) {
			s = '-';
			c = readCharCode( _position );
		} else {
			s = '';
		}
		if ( c == Char.ZERO ) {

			c = readCharCode( _position );
			if ( c == Char.x || c == Char.X ) {	// hex
				t = readHex( _memory, _position );
				if ( t != null ) {
					result = untyped __global__["parseInt"]( t, 16 );
				}
			} else if ( c == Char.DOT ) {		// float
				t = readDec( _memory, _position );
				if ( t != null ) {
					result = '.' + t;
					t = readExp( _memory, _position );
					if ( t != null ) {
						result += t;
					}
				}
			} else {
				--_position;
			}

		} else if ( c == Char.DOT ) {

			t = readDec( _memory, _position );
			if ( t != null ) {
				result = '.' + t;
				t = readExp( _memory, _position );
				if ( t != null ) {
					result += t;
				}
			}

		}
		if ( result == null ) {

			--_position;
			t = readDec( _memory, _position );
			if ( t != null ) {
				result = t;
				if ( readCharCode( _position ) == Char.DOT ) {
					t = readDec( _memory, _position );
					if ( t != null ) {
						result += '.' + t;
					}
				} else {
					--_position;
				}
				t = readExp( _memory, _position );
				if ( t != null ) {
					result += t;
				}
			}

		}
		if ( result == null ) {
			_position = pos;
			return null;
		} else {
			return s + result;
		}
	}

	public static inline function skipBlockComment(_position:UInt):UInt {
		var pos:UInt = _position;
		if (
			readCharCode( _position ) != Char.SLASH ||
			readCharCode( _position ) != Char.ASTERISK
		) {
			_position = pos;
		} else {
			var c:UInt;
			do {
				c = readCharCode( _position );
				if ( c == Char.ASTERISK ) {
					if ( readCharCode( _position ) == Char.SLASH ) {
						break;
					} else {
						--_position;
					}
				} else if ( c == Char.EOS ) {
					_position = pos;
					break;
				}
			} while ( true );
		}
		return pos;
	}

	public static inline function readBlockComment(_memory:ByteArray, _position:UInt):String {
		var pos:UInt = skipBlockComment( _position );
		if ( pos == _position ) {
			return null;
		} else {
			_memory.position = pos + 2;
			return _memory.readUTFBytes( _position - 4 - pos );
		}
	}

	public static inline function skipLine(_position:UInt):Void {
		var c:UInt;
		do {
			c = readCharCode( _position );
		} while ( c != Char.NEWLINE && c != Char.CARRIAGE_RETURN && c != Char.EOS );
		--_position;
	}

	public static inline function readLine(_memory:ByteArray, _position:UInt):String {
		var pos:UInt = _position;
		skipLine( _position );
		_memory.position = pos;
		return _memory.readUTFBytes( _position - pos );
	}

	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static inline function readDec(_memory:ByteArray, _position:UInt):String {
		var pos:UInt = _position;
		var c:UInt;
		do {
			c = readCharCode( _position );
		} while (
			c >= Char.ZERO && c <= Char.NINE
		);
		--_position;
		if ( _position == pos ) {
			return null;
		} else {
			_memory.position = pos;
			return _memory.readUTFBytes( _position - pos );
		}
	}

	/**
	 * @private
	 */
	private static inline function readExp(_memory:ByteArray, _position:UInt):String {
		var c:UInt = readCharCode( _position );
		if ( c != Char.e && c != Char.E ) {
			--_position;
			return null;
		} else {
			var prefix:String;
			c = readCharCode( _position );
			if ( c == Char.DASH ) {
				prefix = '-';
			} else {
				prefix = '';
				if ( c != Char.PLUS ) {
					--_position;
				}
			}
			var t:String = readDec( _memory, _position );
			if ( t == null ) {
				return null;
			} else {
				return 'e' + prefix + t;
			}
		}
	}

	/**
	 * @private
	 */
	private static inline function readHex(_memory:ByteArray, _position:UInt):String {
		var pos:UInt = _position;
		var c:UInt;
		do {
			c = readCharCode( _position );
		} while (
			( c >= Char.ZERO && c <= Char.NINE ) ||
			( c >= Char.a && c <= Char.f ) ||
			( c >= Char.A && c <= Char.F )
		);
		--_position;
		if ( _position == pos ) {
			return null;
		} else {
			_memory.position = pos;
			return _memory.readUTFBytes( _position - pos );
		}
	}
	
	/**
	 * @private
	 */
	private static inline function readFixedHex(_memory:ByteArray, _position:UInt, length:UInt):String {
		var c:UInt;
		var i:UInt = 0;
		do {
			c = readCharCode( _position );
			if (
				( c < Char.ZERO || c > Char.NINE ) &&
				( c < Char.a || c > Char.f ) &&
				( c < Char.A || c > Char.F )
			) {
				break;
			}
		} while ( ++i < length );
		if ( i != length ) {
			_position -= i;
			return null;
		} else {
			_memory.position = _position - length;
			return _memory.readUTFBytes( length );
		}
	}

	///**
	 //* @private
	 //*/
	//public static inline function readTo(...to):String {
		//var pos:uint = this._position;
		//var c:uint;
		//do {
			//c = this.readCharCode();
			//switch ( c ) {
				//case Char.CARRIAGE_RETURN:
				//case Char.NEWLINE:
					//break;
			//}
			//if ( to.indexOf( c ) >= 0 ) {
				//--this._position;
				//return this._source.substring( pos, this._position );
			//}
		//} while ( c != Char.EOS );
		//this._position = pos;
		//return null;
	//}
	
}