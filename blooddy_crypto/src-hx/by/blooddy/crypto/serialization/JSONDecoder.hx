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

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function decode(value:String):Dynamic {

		if ( value == null ) Error.throwError( TypeError, 2007, 'value' );

		var result:Dynamic = untyped __global__["undefined"];

		if ( value.length > 0 ) {

			var mem:ByteArray = Memory.memory;

			var tmp:ByteArray = new ByteArray();
			tmp.writeUTFBytes( value );
			tmp.writeByte( 0 ); // EOF
			if ( tmp.length < 1024 ) {
				tmp.length = 1024;
			}
			Memory.memory = tmp;

			var _position:UInt = 0;
			var c:UInt = TMP.readNotSpaceCharCode( _position );

			if ( c != Char.EOS ) {

				var position:UInt = _position - 1;
				
				var readValue:ByteArray->UInt->Dynamic = null;

				readValue = function(_memory:ByteArray, _position:UInt):Dynamic {

					var pos:UInt;
					var result:Dynamic = untyped __global__["undefined"];

					var	_tk:UInt = 0,
						_tt:String = null;

					TMP.readToken( _memory, _position, _tk, _tt );

					if ( _tk == TMP.STRING_LITERAL ) {

						result = _tt;

					} else if ( _tk == TMP.NUMBER_LITERAL ) {

						result = untyped __global__["parseFloat"]( _tt );

					} else if ( _tk == TMP.DASH ) {

						TMP.readToken( _memory, _position, _tk, _tt );
						if ( _tk == TMP.NUMBER_LITERAL ) {
							result = - untyped __global__["parseFloat"]( _tt );
						} else if ( _tk == TMP.NULL ) {
							result = 0; // -null
						} else if (
							_tk == TMP.UNDEFINED ||
							_tk == TMP.NAN
						) {
							result = untyped __global__["Number"].NaN; // -undefined
						} else {
							Error.throwError( SyntaxError, 1509 );
						}

					} else if ( _tk == TMP.NULL ) {

						result = null;

					} else if ( _tk == TMP.TRUE ) {

						result = true;

					} else if ( _tk == TMP.FALSE ) {

						result = false;

					} else if ( _tk == TMP.UNDEFINED ) {

						//result = untyped __global__["undefined"];

					} else if ( _tk == TMP.NAN ) {

						result = untyped __global__["Number"].NaN;

					} else if ( _tk == TMP.LEFT_BRACE ) {		// {

						var o:Object = new Object();
						var key:String = null;

						pos = _position;
						TMP.readToken( _memory, _position, _tk, _tt );

						if ( _tk != TMP.RIGHT_BRACE ) {

							do {

								if ( _tk == TMP.STRING_LITERAL || _tk == TMP.IDENTIFIER ) {
									key = _tt;
								} else if ( _tk == TMP.NUMBER_LITERAL ) {
									key = untyped __global__["parseFloat"]( _tt ).toString();
								} else if ( _tk == TMP.UNDEFINED ) {
									key = 'undefined';
								} else if ( _tk == TMP.NAN ) {
									key = 'NaN';
								} else {
									Error.throwError( SyntaxError, 1509 ); // throw new ParserError( 'ожидался ключ объекта, а не ' + tok );
								}

								TMP.readFixSimpleToken( _position, TMP.COLON );

								untyped { o[ key ] = readValue( _memory, _position ); }
								_position = position;

								TMP.readToken( _memory, _position, _tk, _tt );
								if ( _tk == TMP.RIGHT_BRACE ) {		// }
									break;
								} else if ( _tk != TMP.COMMA ) {	// ,
									Error.throwError( SyntaxError, 1509 ); // throw new ParserError( 'ожидалась запятая либо завершение объекта, а не ' + tok );
								}

								TMP.readToken( _memory, _position, _tk, _tt );

							} while ( true );
						}

						result = o;

					} else if ( _tk == TMP.LEFT_BRACKET ) {		// [

						var arr:Array<Dynamic> = new Array<Dynamic>();
						do {

							pos = _position;
							TMP.readToken( _memory, _position, _tk, _tt );

							if ( _tk == TMP.RIGHT_BRACKET ) {	// ]
								break;
							} else if ( _tk == TMP.COMMA ) {	// ,
								arr.push( untyped __global__["undefined"] );
							} else {

								_position = pos;

								arr.push( readValue( _memory, _position ) );
								_position = position;

								TMP.readToken( _memory, _position, _tk, _tt );
								if ( _tk == TMP.RIGHT_BRACKET ) {	// ]
									break;
								} else if ( _tk != TMP.COMMA ) {	// ,
									Error.throwError( SyntaxError, 1509 ); // throw new ParserError( 'ожидалась запятая либо завершение массива, а не ' + tok );
								}
							}

						} while ( true );
						result = arr;

					} else {
						Error.throwError( SyntaxError, 1509 );
					}

					position = _position;
					return result;

				}

				result = readValue( tmp, position );
				_position = position;

				TMP.readFixSimpleToken( _position, TMP.EOF );

			}
			
			Memory.memory = mem;

		}

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
	public static inline var UNKNOWN:UInt =			1;
	public static inline var UNDEFINED:UInt =		1;
	public static inline var NULL:UInt =			2;
	public static inline var TRUE:UInt =			3;
	public static inline var FALSE:UInt =			4;
	public static inline var NAN:UInt =				5;
	public static inline var NUMBER_LITERAL:UInt =	6;
	public static inline var STRING_LITERAL:UInt =	7;
	public static inline var IDENTIFIER:UInt =		8;
	public static inline var COMMA:UInt =			Char.COMMA;
	public static inline var DASH:UInt =			Char.DASH;
	public static inline var COLON:UInt =			Char.COLON;
	public static inline var LEFT_BRACKET:UInt =	Char.LEFT_BRACKET;
	public static inline var RIGHT_BRACKET:UInt =	Char.RIGHT_BRACKET;
	public static inline var LEFT_BRACE:UInt =		Char.LEFT_BRACE;
	public static inline var RIGHT_BRACE:UInt =		Char.RIGHT_BRACE;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function readFixSimpleToken(_position:UInt, kind:UInt):Void {
		if ( readNotSpaceCharCode( _position ) != kind ) {
			Error.throwError( SyntaxError, 1509 );
		}
	}

	public static inline function readNotSpaceCharCode(_position:UInt):UInt {
		var c:UInt;
		do {
			c = MemoryScanner.readCharCode( _position );
			if (
				c != Char.CARRIAGE_RETURN &&
				c != Char.NEWLINE &&
				c != Char.SPACE &&
				c != Char.TAB &&
				c != Char.VERTICAL_TAB &&
				c != Char.BACKSPACE &&
				c != Char.FORM_FEED
			) {
				if ( c == Char.SLASH ) {
					c = MemoryScanner.readCharCode( _position );
					if ( c == Char.SLASH ) {			// //
						MemoryScanner.skipLine( _position );
						continue;
					} else if ( c == Char.ASTERISK ) {	// /*
						_position -= 2;
						c = _position;
						MemoryScanner.skipBlockComment( _position );
						if ( c != _position ) {
							continue;
						}
					}
					--_position;
					c = Char.SLASH;
				}
				break;
			}
		} while ( true );
		return c;
	}

	/**
	 * @private
	 */
	public static inline function readToken(_memory:ByteArray, _position:UInt, _tk:UInt, _tt:String):Void {
		var t:String;
		var c:UInt = readNotSpaceCharCode( _position );
		if (
			c == Char.COMMA ||
			c == Char.COLON ||
			c == Char.LEFT_BRACE ||
			c == Char.RIGHT_BRACE ||
			c == Char.LEFT_BRACKET ||
			c == Char.RIGHT_BRACKET ||
			c == Char.DASH ||
			c == Char.EOS
		) {
			_tk = c;
		} else if ( c == Char.SINGLE_QUOTE || c == Char.DOUBLE_QUOTE ) {
			--_position;
			t = MemoryScanner.readString( _memory, _position );
			if ( t != null ) {
				_tk = STRING_LITERAL;
				_tt = t;
			} else {
				_tk = UNKNOWN;
			}
		} else if ( ( c >= Char.ZERO && c <= Char.NINE ) || c == Char.DOT ) {
			--_position;
			t = MemoryScanner.readNumber( _memory, _position );
			if ( t != null ) {
				_tk = NUMBER_LITERAL;
				_tt = t;
			} else {
				_tk = UNKNOWN;
			}
		} else {
			
			var pos:UInt = _position - 1;
			if (
				c == Char.n &&
				MemoryScanner.readCharCode( _position ) == Char.u &&
				MemoryScanner.readCharCode( _position ) == Char.l &&
				MemoryScanner.readCharCode( _position ) == Char.l
			) {
				_tk = NULL;
			} else if (
				c == Char.t &&
				MemoryScanner.readCharCode( _position ) == Char.r &&
				MemoryScanner.readCharCode( _position ) == Char.u &&
				MemoryScanner.readCharCode( _position ) == Char.e
			) {
				_tk = TRUE;
			} else if (
				c == Char.f &&
				MemoryScanner.readCharCode( _position ) == Char.a &&
				MemoryScanner.readCharCode( _position ) == Char.l &&
				MemoryScanner.readCharCode( _position ) == Char.s &&
				MemoryScanner.readCharCode( _position ) == Char.e
			) {
				_tk = FALSE;
			} else if (
				c == Char.u &&
				MemoryScanner.readCharCode( _position ) == Char.n &&
				MemoryScanner.readCharCode( _position ) == Char.d &&
				MemoryScanner.readCharCode( _position ) == Char.e &&
				MemoryScanner.readCharCode( _position ) == Char.f &&
				MemoryScanner.readCharCode( _position ) == Char.i &&
				MemoryScanner.readCharCode( _position ) == Char.n &&
				MemoryScanner.readCharCode( _position ) == Char.e &&
				MemoryScanner.readCharCode( _position ) == Char.d
			) {
				_tk = UNDEFINED;
			} else if (
				c == Char.N &&
				MemoryScanner.readCharCode( _position ) == Char.a &&
				MemoryScanner.readCharCode( _position ) == Char.N
			) {
				_tk = NAN;
			} else {
				_position = pos;
				t = MemoryScanner.readIdentifier( _memory, _position );
				if ( t != null ) {
					_tk = IDENTIFIER;
					_tt = t;
				} else {
					_tk = UNKNOWN;
				}
			}
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static inline function makeToken(_tk:UInt, _tt:String, k:UInt, ?t:String=null):Void {
		_tk = k;
		_tt = t;
	}

}