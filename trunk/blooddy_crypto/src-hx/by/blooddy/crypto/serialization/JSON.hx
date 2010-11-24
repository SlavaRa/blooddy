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
import flash.errors.StackOverflowError;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.Vector;
import flash.xml.XML;
import flash.xml.XMLDocument;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class JSON {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function encode(value:Dynamic):String {

		var set:Object = XML.settings();
		XML.setSettings( {
			ignoreComments: true,
			ignoreProcessingInstructions: false,
			ignoreWhitespace: true,
			prettyIndent: false,
			prettyPrinting: false
		} );
		
		var mem:ByteArray = Memory.memory;

		var tmp:ByteArray = new ByteArray();
		tmp.writeUTFBytes( '0123456789abcdef' );
		// помещаем в пямять
		if ( tmp.length < Memory.MIN_SIZE ) tmp.length = Memory.MIN_SIZE;
		Memory.memory = tmp;

		var position:UInt = 16;

		var cvint:Class<Int> = untyped __as__( new Vector<Int>(), Object ).constructor;
		var cvuint:Class<UInt> = untyped __as__( new Vector<UInt>(), Object ).constructor;
		var cvdouble:Class<Float> = untyped __as__( new Vector<Float>(), Object ).constructor;
		var cvobject:Class<Dynamic> = untyped __as__( new Vector<Dynamic>(), Object ).constructor;

		var writeValue:Dictionary->ByteArray->UInt->Dynamic->Dynamic = null;

		writeValue = function(hash:Dictionary, _memory:ByteArray, _position:UInt, value:Dynamic):Dynamic {
			if ( _memory.bytesAvailable < 2048 ) {
				_memory.length += 4096;
			}
			var t:String = untyped __typeof__( value );
			if ( t == 'number' ) {
				TMP.writeNumber( _memory, _position, value );
			} else if ( t == 'boolean' ) {
				TMP.writeBoolean( _position, value );
			} else {
				if ( t == 'xml' ) {
					value = value.toXMLString();
					t = 'string';
				} else if ( value && t == 'object' ) {
					if ( untyped __is__( value, XMLDocument ) ) {
						if ( value.childNodes.length > 0 ) {
							value = ( new XML( value ) ).toXMLString();
							t = 'string';
						} else {
							TMP.writeStringEmpty( _position );
						}
					} else {

						if ( untyped __in__( value, hash ) ) {
							Memory.memory = mem;
							Error.throwError( StackOverflowError, 2024 );
						}
						hash[ value ] = true;

						var i:Int = 0;
						var l:Int;
						if (
							( untyped __is__( value, Array ) ) ||
							( untyped __is__( value, cvobject ) )
						) {

							TMP.writeByte( _position, Char.LEFT_BRACKET );	// [
							l = untyped value.length - 1;
							while ( l >= 0 && value[ l ] == null ) {
								--l;
							}
							++l;
							if ( l > 0 ) {
								writeValue( hash, _memory, _position, value[ 0 ] );
								_position = position;
								while ( ++i < l ) {
									TMP.writeByte( _position, Char.COMMA );	// ,
									writeValue( hash, _memory, _position, value[ i ] );
									_position = position;
								}
							}
							TMP.writeByte( _position, Char.RIGHT_BRACKET );	// ]

						} else if (
							( untyped __is__( value, cvint ) ) ||
							( untyped __is__( value, cvuint ) )
						) {

							TMP.writeByte( _position, Char.LEFT_BRACKET );	// [
							l = value.length;
							if ( l > 0 ) {
								TMP.writeFiniteNumber( _memory, _position, value[ 0 ] );
								while ( ++i < l ) {
									TMP.writeByte( _position, Char.COMMA );	// ,
									TMP.writeFiniteNumber( _memory, _position, value[ i ] );
								}
							}
							TMP.writeByte( _position, Char.RIGHT_BRACKET );	// ]

						} else if (
							( untyped __is__( value, cvdouble ) )
						) {

							TMP.writeByte( _position, Char.LEFT_BRACKET );	// [
							l = untyped value.length - 1;
							while ( l >= 0 && !untyped __global__["isFinite"]( value[ l ] ) ) {
								--l;
							}
							++l;
							if ( l > 0 ) {
								TMP.writeNumber( _memory, _position, value[ 0 ] );
								while ( ++i < l ) {
									TMP.writeByte( _position, Char.COMMA );	// ,
									TMP.writeNumber( _memory, _position, value[ i ] );
								}
							}
							TMP.writeByte( _position, Char.RIGHT_BRACKET );	// ]

						} else {

							TMP.writeByte( _position, Char.LEFT_BRACE );	// {

							var n:String;
							var f:Bool = false;
							var arr:Array<String>;
							var v:Dynamic = null;

							if ( value.constructor != Object ) {

								var h:Bool;
								
								arr = SerializationHelper.getPropertyNames( value );
								l = arr.length;
								i = 0;
								while ( i < l ) {
									n = arr[ i ];
									try {
										v = value[ untyped n ];
										h = true;
									} catch ( e:Dynamic ) {
										h = false;
										// skip
									}
									if ( h ) {
										if ( f )	TMP.writeByte( _position, Char.COMMA );	// ,
										else		f = true;
										TMP.writeString( _memory, _position, n );
										TMP.writeByte( _position, Char.COLON );	// :
										writeValue( hash, _memory, _position, v );
										_position = position;
									}
									++i;
								}

							}

							arr = untyped __keys__( value );
							l = arr.length;
							i = 0;
							while ( i < l ) {
								n = arr[ i ];
								v = value[ untyped n ];
								if ( !( untyped __is__( v, Function ) ) ) {
									if ( f )	TMP.writeByte( _position, Char.COMMA );	// ,
									else		f = true;
									TMP.writeString( _memory, _position, n );
									TMP.writeByte( _position, Char.COLON );	// :
									writeValue( hash, _memory, _position, v );
									_position = position;
								}
								++i;
							}
							
							TMP.writeByte( _position, Char.RIGHT_BRACE );	// }

						}

						untyped __delete__( hash, value );
						
					}
				}
				if ( t == 'string' ) {
					TMP.writeString( _memory, _position, value );
				} else if ( !value ) {
					TMP.writeNull( _position );
				}
			}
			position = _position;
		}

		writeValue( new Dictionary(), tmp, position, value );

		Memory.memory = mem;
		XML.setSettings( set );

		tmp.position = 16;
		return tmp.readUTFBytes( position - 16 );

	}
	
	public static function decode(value:String):Dynamic {

		if ( value == null ) Error.throwError( TypeError, 2007, 'value' );

		var result:Dynamic = untyped __global__["undefined"];

		if ( value.length > 0 ) {

			var mem:ByteArray = Memory.memory;

			var tmp:ByteArray = new ByteArray();
			tmp.writeUTFBytes( value );
			tmp.writeByte( 0 ); // EOF
			// помещаем в пямять
			if ( tmp.length < Memory.MIN_SIZE ) tmp.length = Memory.MIN_SIZE;
			Memory.memory = tmp;

			var _position:UInt = 0;

			var c:UInt = TMP.readNotSpaceCharCode( _position );
			if ( c != Char.EOS ) {

				var position:UInt = _position - 1;
				
				var readValue:ByteArray->UInt->Dynamic = null;

				readValue = function(_memory:ByteArray, _position:UInt):Dynamic {

					var pos:UInt;
					var c:UInt;
					var result:Dynamic = untyped __global__["undefined"];

					var	_tk:UInt = 0,
						_tt:String = null;

					TMP.readToken( _memory, _position, _tk, _tt, 0x7F7C );

					if ( _tk == TMP.STRING_LITERAL ) {

						result = _tt;

					} else if ( _tk == TMP.NUMBER_LITERAL ) {

						result = untyped __global__["parseFloat"]( _tt );

					} else if ( _tk == TMP.DASH ) {

						TMP.readToken( _memory, _position, _tk, _tt, 0x6600 );
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
							TMP.throwSyntaxError( mem );
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

						c = TMP.readNotSpaceCharCode( _position );
						if ( c != Char.RIGHT_BRACE ) {

							--_position;
							
							do {

								TMP.readToken( _memory, _position, _tk, _tt, 0x9F00 );

								if ( _tk == TMP.STRING_LITERAL || _tk == TMP.IDENTIFIER ) {
									key = _tt;
								} else if ( _tk == TMP.NUMBER_LITERAL ) {
									key = untyped __global__["parseFloat"]( _tt ).toString();
								} else {
									TMP.throwSyntaxError( mem );
								}

								TMP.readFixCharCode( mem, _position, Char.COLON );

								o[ untyped key ] = readValue( _memory, _position );
								_position = position;

								c = TMP.readNotSpaceCharCode( _position );
								if ( c == Char.RIGHT_BRACE ) {		// }
									break;
								} else if ( c != Char.COMMA ) {	// ,
									TMP.throwSyntaxError( mem );
								}

							} while ( true );
						}

						result = o;

					} else if ( _tk == TMP.LEFT_BRACKET ) {		// [

						var arr:Array<Dynamic> = new Array<Dynamic>();
						do {

							c = TMP.readNotSpaceCharCode( _position );
							if ( c == Char.RIGHT_BRACKET ) {	// ]
								break;
							} else if ( c == Char.COMMA ) {	// ,
								arr.push( untyped __global__["undefined"] );
							} else {

								--_position;

								arr.push( readValue( _memory, _position ) );
								_position = position;

								c = TMP.readNotSpaceCharCode( _position );
								if ( c == Char.RIGHT_BRACKET ) {	// ]
									break;
								} else if ( c != Char.COMMA ) {	// ,
									TMP.throwSyntaxError( mem );
								}
							}

						} while ( true );
						result = arr;

					} else {
						TMP.throwSyntaxError( mem );
					}

					position = _position;
					return result;

				}

				result = readValue( tmp, position );
				_position = position;

				TMP.readFixCharCode( mem, _position, Char.EOS );

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

	public static inline function writeByte(_position:UInt, value:UInt):Void {
		Memory.setByte( _position, value );
		++_position;
	}

	public static inline function writeI16(_position:UInt, value:UInt):Void {
		Memory.setI16( _position, value );
		_position += 2;
	}

	public static inline function writeI32(_position:UInt, value:UInt):Void {
		Memory.setI32( _position, value );
		_position += 4;
	}

	public static inline function writeBoolean(_position:UInt, value:Bool):Void {
		if ( value ) {
			writeI32( _position, 0x65757274 );	// true
		} else {
			writeI32( _position, 0x736C6166 );	// fals
			writeByte( _position, 0x65 );		// e
		}
	}

	public static inline function writeNull(_position:UInt):Void {
		writeI32( _position, 0x6C6C756E );		// null
	}

	public static inline function writeNumber(_memory:ByteArray, _position:UInt, value:Float):Void {
		if ( untyped __global__["isFinite"]( value ) ) {
			writeFiniteNumber( _memory, _position, value );
		} else {
			writeNull( _position );
		}
	}

	public static inline function writeFiniteNumber(_memory:ByteArray, _position:UInt, value:Float):Void {
		if ( value >= 0 && value <= 9 && value % 1 == 0 ) {
			writeByte( _position, Char.ZERO + untyped value ); // 0+
		} else {
			_memory.position = _position;
			_memory.writeUTFBytes( untyped value.toString() );
			_position = _memory.position;
		}
	}

	public static inline function writeStringEmpty(_position:UInt):Void {
		writeI16( _position, 0x2222 );	// ""
	}

	public static inline function writeString(_memory:ByteArray, _position:UInt, value:String):Void {
		if ( value.length <= 0 ) {

			writeStringEmpty( _position );

		} else {

			writeByte( _position, Char.DOUBLE_QUOTE );

			// write temp string
			var i:UInt = _position + value.length * 6;
			var j:UInt = i;
			_memory.position = i;
			_memory.writeUTFBytes( value );
			var len:UInt = _memory.position;
			_memory.position = _position;

			var c:UInt;
			while ( i < len ){
				c = Memory.getByte( i );
				if ( c < Char.SPACE || c == Char.DOUBLE_QUOTE || c == Char.SLASH || c == Char.BACK_SLASH ) {
					if ( i != j ) {
						_memory.position = _position;
						_memory.writeBytes( _memory, j, i-j );
						_position = _memory.position;
					}
					j = i + 1;
					if ( c == Char.NEWLINE ) {
						writeI16( _position, 0x6E5C );	// \n
					} else if ( c == Char.CARRIAGE_RETURN ) {
						writeI16( _position, 0x725C );	// \r
					} else if ( c == Char.TAB ) {
						writeI16( _position, 0x745C );	// \t
					} else if ( c == Char.DOUBLE_QUOTE ) {
						writeI16( _position, 0x225C );	// \"
					} else if ( c == Char.SLASH ) {
						writeI16( _position, 0x2F5C );	// \/
					} else if ( c == Char.BACK_SLASH ) {
						writeI16( _position, 0x5C5C );	// \\
					} else if ( c == Char.VERTICAL_TAB ) {
						writeI16( _position, 0x765C );	// \v
					} else if ( c == Char.BACKSPACE ) {
						writeI16( _position, 0x625C );	// \b
					} else if ( c == Char.FORM_FEED ) {
						writeI16( _position, 0x665C );	// \f
					} else if ( c < Char.SPACE ) {
						writeI32( _position, 0x3030755C );	// \u00
						writeByte( _position, Memory.getByte( c >>> 4 ) );
						writeByte( _position, Memory.getByte( c & 0xF ) );
					}
				}
				++i;
			};
			if ( i != j ) {
				_memory.position = _position;
				_memory.writeBytes( _memory, j, i-j );
				_position = _memory.position;
			}

			writeByte( _position, Char.DOUBLE_QUOTE );	// "

		}
	}

	public static inline function readFixCharCode(mem:ByteArray, _position:UInt, kind:UInt):Void {
		if ( readNotSpaceCharCode( _position ) != kind ) {
			TMP.throwSyntaxError( mem );
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
	public static inline function readToken(_memory:ByteArray, _position:UInt, _tk:UInt, _tt:String, flag:UInt):Void {
		var t:String;
		var c:UInt = readNotSpaceCharCode( _position );
		if (
			( flag &   1 ==   1 && c == Char.COMMA ) ||
			( flag &   2 ==   2 && c == Char.COLON ) ||
			( flag &   4 ==   4 && c == Char.LEFT_BRACE ) ||
			( flag &   8 ==   8 && c == Char.RIGHT_BRACE ) ||
			( flag &  16 ==  16 && c == Char.LEFT_BRACKET ) ||
			( flag &  32 ==  32 && c == Char.RIGHT_BRACKET ) ||
			( flag &  64 ==  64 && c == Char.DASH ) ||
			( flag & 128 == 128 && c == Char.EOS )
		) {
			_tk = c;
		} else if (
			flag & 256 == 256 &&
			( c == Char.SINGLE_QUOTE || c == Char.DOUBLE_QUOTE )
		) {
			--_position;
			t = MemoryScanner.readString( _memory, _position );
			if ( t != null ) {
				_tk = STRING_LITERAL;
				_tt = t;
			} else {
				_tk = UNKNOWN;
			}
		} else if (
			flag & 512 == 512 &&
			( ( c >= Char.ZERO && c <= Char.NINE ) || c == Char.DOT )
		) {
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
				flag & 1024 == 1024 &&
				c == Char.n &&
				MemoryScanner.readCharCode( _position ) == Char.u &&
				MemoryScanner.readCharCode( _position ) == Char.l &&
				MemoryScanner.readCharCode( _position ) == Char.l
			) {
				_tk = NULL;
			} else if (
				flag & 2048 == 2048 &&
				c == Char.t &&
				MemoryScanner.readCharCode( _position ) == Char.r &&
				MemoryScanner.readCharCode( _position ) == Char.u &&
				MemoryScanner.readCharCode( _position ) == Char.e
			) {
				_tk = TRUE;
			} else if (
				flag & 4096 == 4096 &&
				c == Char.f &&
				MemoryScanner.readCharCode( _position ) == Char.a &&
				MemoryScanner.readCharCode( _position ) == Char.l &&
				MemoryScanner.readCharCode( _position ) == Char.s &&
				MemoryScanner.readCharCode( _position ) == Char.e
			) {
				_tk = FALSE;
			} else if (
				flag & 8192 == 8192 &&
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
				flag & 16384 == 16384 &&
				c == Char.N &&
				MemoryScanner.readCharCode( _position ) == Char.a &&
				MemoryScanner.readCharCode( _position ) == Char.N
			) {
				_tk = NAN;
			} else if (
				flag & 32768 == 32768
			) {
				_position = pos;
				t = MemoryScanner.readIdentifier( _memory, _position );
				if ( t != null ) {
					_tk = IDENTIFIER;
					_tt = t;
				} else {
					_tk = UNKNOWN;
				}
			} else {
				_tk = UNKNOWN;
			}
		}
	}

	public static inline function throwSyntaxError(mem:ByteArray):Void {
		Memory.memory = mem;
		Error.throwError( SyntaxError, 1509 );
	}
	
}