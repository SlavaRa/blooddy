////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.serialization;

import by.blooddy.system.Memory;
import by.blooddy.utils.Char;
import by.blooddy.utils.MemoryScanner;
import flash.Error;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class JSONDecoder {

	public static function decode(value:String):Dynamic {

		if ( value == null || value.length <= 0 ) return untyped __global__["undefined"];
		
		var mem:ByteArray = Memory.memory;

		var _memory:ByteArray = new ByteArray();
		_memory.writeUTFBytes( value );
		_memory.writeByte( 0 ); // EOF
		if ( _memory.length < 1024 ) {
			_memory.length = 1024;
		}
		Memory.memory = _memory;

		var	_position:UInt = 0,
			_tk:UInt = 0,
			_tt:String = null;
		
		var readValue = null;

		readValue = function():Dynamic {

			var pos:UInt;

			TMP.readToken( _memory, _position, _tk, _tt );

			if ( _tk == TMP.STRING_LITERAL ) {
				return _tt;
			} else if ( _tk == TMP.NUMBER_LITERAL ) {
				var n:Float = untyped __global__["parseFloat"]( _tt );
				if ( n % 1 == 0 && n >= -2147483648 ) {	// int.MIN_VALUE
					if ( n <= 2147483647 ) {			// int.MAX_VALUE
						return untyped __global__["int"]( n );
					} else if ( n <= 4294967295 ) {		 // uint.MAX_VALUE
						return untyped __global__["uint"]( n );
					}
				}
				return n;
			} else if ( _tk == TMP.NULL ) {
				return null;
			} else if ( _tk == TMP.TRUE ) {
				return true;
			} else if ( _tk == TMP.FALSE ) {
				return false;
			} else if ( _tk == TMP.UNDEFINED ) {
				return untyped __global__["undefined"];
			} else if ( _tk == TMP.NAN ) {
				return untyped __global__["Number"].NaN;
			} else if ( _tk == TMP.LEFT_BRACE ) {		// {

				var o:Object = new Object();
				var key:String = null;

				pos = _position;
				TMP.readToken( _memory, _position, _tk, _tt );
				if ( _tk == TMP.RIGHT_BRACE ) {
					return o;
				} else {
					_position = pos;
				}

				do {

					TMP.readToken( _memory, _position, _tk, _tt );

					if ( _tk == TMP.STRING_LITERAL || _tk == TMP.IDENTIFIER ) {
						key = _tt;
					} else if ( _tk == TMP.NUMBER_LITERAL ) {
						key = ( untyped __global__["parseFloat"]( _tt ) ).toString();
					} else {
						Error.throwError( SyntaxError, 1509 ); // throw new ParserError( 'ожидался ключ объекта, а не ' + tok );
					}

					TMP.readFixSimpleToken( _position, TMP.COLON );

					untyped { o[ key ] = readValue(); }

					TMP.readToken( _memory, _position, _tk, _tt );
					if ( _tk == TMP.RIGHT_BRACE ) {		// }
						return o;
					} else if ( _tk != TMP.COMMA ) {	// ,
						Error.throwError( SyntaxError, 1509 ); // throw new ParserError( 'ожидалась запятая либо завершение объекта, а не ' + tok );
					}

				} while ( true );

			} else if ( _tk == TMP.LEFT_BRACKET ) {		// [

				var arr:Array<Dynamic> = new Array<Dynamic>();
				do {

					pos = _position;
					TMP.readToken( _memory, _position, _tk, _tt );

					if ( _tk == TMP.RIGHT_BRACKET ) {	// ]
						return arr;
					} else if ( _tk == TMP.COMMA ) {	// ,
						arr.push( untyped __global__["undefined"] );
					} else {

						_position = pos;

						arr.push( readValue() );

						TMP.readToken( _memory, _position, _tk, _tt );
						if ( _tk == TMP.RIGHT_BRACKET ) {	// ]
							return arr;
						} else if ( _tk != TMP.COMMA ) {	// ,
							Error.throwError( SyntaxError, 1509 ); // throw new ParserError( 'ожидалась запятая либо завершение массива, а не ' + tok );
						}
					}

				} while ( true );

			}
			Error.throwError( SyntaxError, 1509 );
			return untyped __global__["undefined"];
		}

		var result:Dynamic = readValue();

		TMP.readFixSimpleToken( _position, TMP.EOF );
		
		Memory.memory = mem;

		return result;
	}

}

/**
 * @private
 */
private class TMP {

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	public static inline var EOF:UInt =				Char.EOS;
	public static inline var UNDEFINED:UInt =		1;
	public static inline var NULL:UInt =			2;
	public static inline var TRUE:UInt =			3;
	public static inline var FALSE:UInt =			4;
	public static inline var NAN:UInt =				5;
	public static inline var COLON:UInt =			Char.COLON;
	public static inline var LEFT_BRACE:UInt =		Char.LEFT_BRACE;
	public static inline var RIGHT_BRACE:UInt =		Char.RIGHT_BRACE;
	public static inline var LEFT_BRACKET:UInt =	Char.LEFT_BRACKET;
	public static inline var RIGHT_BRACKET:UInt =	Char.RIGHT_BRACKET;
	public static inline var COMMA:UInt =			Char.COMMA;
	public static inline var NUMBER_LITERAL:UInt =	12;
	public static inline var STRING_LITERAL:UInt =	13;
	public static inline var IDENTIFIER:UInt =		14;
	public static inline var BLOCK_COMMENT:UInt =	15;
	public static inline var LINE_COMMENT:UInt =	16;
	public static inline var UNKNOWN:UInt =			17;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function readToken(_memory:ByteArray, _position:UInt, _tk:UInt, _tt:String):Void {
		do {
			_readToken( _memory, _position, _tk, _tt );
		} while ( _tk == LINE_COMMENT || _tk == BLOCK_COMMENT );
	}

	public static inline function readFixSimpleToken(_position:UInt, kind:UInt):Void {
		var c:UInt;
		do {
			c = MemoryScanner.readCharCode( _position );
			if ( isNotSpace( c ) ) {
				if ( c == kind ) {
					break;
				} else {
					Error.throwError( SyntaxError, 1509 );
				}
			}
		} while ( true );
	}

	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static inline function isNotSpace(c:UInt):Bool {
		return (
			c != Char.CARRIAGE_RETURN &&
			c != Char.NEWLINE &&
			c != Char.SPACE &&
			c != Char.TAB &&
			c != Char.VERTICAL_TAB &&
			c != Char.LS &&
			c != Char.PS &&
			c != Char.BACKSPACE &&
			c != Char.FORM_FEED
		);
	}

	/**
	 * @private
	 */
	private static inline function _readToken(_memory:ByteArray, _position:UInt, _tk:UInt, _tt:String):Void {
		var t:String;
		var pos:UInt;
		var c:UInt;
		do {
			c = MemoryScanner.readCharCode( _position );
			if ( isNotSpace( c ) ) {
				if (
					c == Char.COMMA ||
					c == Char.COLON ||
					c == Char.LEFT_BRACE ||
					c == Char.RIGHT_BRACE ||
					c == Char.LEFT_BRACKET ||
					c == Char.RIGHT_BRACKET ||
					c == Char.EOS
				) {
					_tk = c;
					// makeToken( _tk, _tt, EOF, '\x00' );
					// makeToken( _tk, _tt, COLON, ':' );
					// makeToken( _tk, _tt, LEFT_BRACE, '{' );
					// makeToken( _tk, _tt, RIGHT_BRACE, '}' );
					// makeToken( _tk, _tt, LEFT_BRACKET, '[' );
					// makeToken( _tk, _tt, RIGHT_BRACKET, ']' );
					// makeToken( _tk, _tt, COMMA, ',' );
				} else if ( c == Char.SINGLE_QUOTE || c == Char.DOUBLE_QUOTE ) {
					--_position;
					t = MemoryScanner.readString( _memory, _position );
					if ( t != null ) {
						makeToken( _tk, _tt, STRING_LITERAL, t );
					} else {
						_tk = UNKNOWN;		// makeToken( _tk, _tt, UNKNOWN, String.fromCharCode( c ) );
					}
				} else if ( c == Char.SLASH ) {
					c = MemoryScanner.readCharCode( _position );
					if ( c == Char.SLASH ) {			// //
						MemoryScanner.skipLine( _position );
						_tk = LINE_COMMENT;
						//makeToken( _tk, _tt, LINE_COMMENT, MemoryScanner.readLine( _memory, _position ) );
						break;
					} else if ( c == Char.ASTERISK ) {	// /*
						_position -= 2;
						pos = MemoryScanner.skipBlockComment( _position );
						if ( pos != _position ) {
							_tk = BLOCK_COMMENT;
							break;
						}
						//t = MemoryScanner.readBlockComment( _memory, _position );
						//if ( t != null ) {
							//makeToken( _tk, _tt, BLOCK_COMMENT, t );
							//break;
						//}
						++_position;
					} else {
						--_position;
					}
					_tk = UNKNOWN;			// makeToken( _tk, _tt, UNKNOWN, '/' );
				} else {
					if ( ( c >= Char.ZERO && c <= Char.NINE ) || c == Char.DASH || c == Char.DOT ) {
						--_position;
						t = MemoryScanner.readNumber( _memory, _position );
						if ( t != null ) {
							makeToken( _tk, _tt, NUMBER_LITERAL, t );
							break;
						}
						++_position;
					} else if ( c == Char.n ) {
						pos = _position;
						if (
							MemoryScanner.readCharCode( _position ) == Char.u &&
							MemoryScanner.readCharCode( _position ) == Char.l &&
							MemoryScanner.readCharCode( _position ) == Char.l
						) {
							_tk = NULL;		// makeToken( _tk, _tt, NULL, 'null' );
							break;
						}
						_position = pos;
					} else if ( c == Char.t ) {
						pos = _position;
						if (
							MemoryScanner.readCharCode( _position ) == Char.r &&
							MemoryScanner.readCharCode( _position ) == Char.u &&
							MemoryScanner.readCharCode( _position ) == Char.e
						) {
							_tk = TRUE;		// makeToken( _tk, _tt, TRUE, 'true' );
							break;
						}
						_position = pos;
					} else if ( c == Char.f ) {
						pos = _position;
						if (
							MemoryScanner.readCharCode( _position ) == Char.a &&
							MemoryScanner.readCharCode( _position ) == Char.l &&
							MemoryScanner.readCharCode( _position ) == Char.s &&
							MemoryScanner.readCharCode( _position ) == Char.e
						) {
							_tk = FALSE;	// makeToken( _tk, _tt, FALSE, 'false' );
							break;
						}
						_position = pos;
					} else if ( c == Char.u ) {
						pos = _position;
						if (
							MemoryScanner.readCharCode( _position ) == Char.n &&
							MemoryScanner.readCharCode( _position ) == Char.d &&
							MemoryScanner.readCharCode( _position ) == Char.e &&
							MemoryScanner.readCharCode( _position ) == Char.f &&
							MemoryScanner.readCharCode( _position ) == Char.i &&
							MemoryScanner.readCharCode( _position ) == Char.n &&
							MemoryScanner.readCharCode( _position ) == Char.e &&
							MemoryScanner.readCharCode( _position ) == Char.d
						) {
							_tk = UNDEFINED;// makeToken( _tk, _tt, UNDEFINED, 'undefined' );
							break;
						}
						_position = pos;
					} else if ( c == Char.N ) {
						pos = _position;
						if (
							MemoryScanner.readCharCode( _position ) == Char.a &&
							MemoryScanner.readCharCode( _position ) == Char.N
						) {
							_tk = NAN;		// makeToken( _tk, _tt, NAN, 'NaN' );
							break;
						}
						_position = pos;
					} else if (
						( c >= Char.a && c <= Char.z ) ||
						( c >= Char.A && c <= Char.Z ) ||
						c == Char.DOLLAR ||
						c == Char.UNDER_SCORE
					) {
						--_position;
						makeToken( _tk, _tt, IDENTIFIER, MemoryScanner.readIdentifier( _memory, _position ) );
						break;
					} else { // попробуем прочитайть полный чаркод
						pos = --_position;
						c = MemoryScanner.readCharCode( _position, false );
						if ( c > 0x7F ) {
							_position = pos;
							makeToken( _tk, _tt, IDENTIFIER, MemoryScanner.readIdentifier( _memory, _position ) );
							break;
						}
					}
					_tk = UNKNOWN;			// makeToken( _tk, _tt, UNKNOWN, String.fromCharCode( c ) );
					break;
				}
				break;
			}
		} while ( true );
	}

	/**
	 * @private
	 */
	private static inline function makeToken(_tk:UInt, _tt:String, k:UInt, ?t:String=null):Void {
		_tk = k;
		_tt = t;
	}

}