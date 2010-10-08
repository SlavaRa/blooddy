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
import flash.errors.StackOverflowError;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.Vector;
import flash.xml.XML;
import flash.xml.XMLDocument;
import flash.xml.XMLList;

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

		var set:Object = XML.settings();
		XML.setSettings( untyped {
			ignoreComments: true,
			ignoreProcessingInstructions: false,
			ignoreWhitespace: true,
			prettyIndent: false,
			prettyPrinting: false
		} );
		
		var mem:ByteArray = Memory.memory;

		var tmp:ByteArray = new ByteArray();
		tmp.writeUTFBytes( '0123456789abcdef' );
		tmp.length = 1024;
		Memory.memory = tmp;

		var position:UInt = 16;

		var cvint:Class<Int> = untyped __as__( new Vector<Int>(), Object ).constructor;
		var cvuint:Class<UInt> = untyped __as__( new Vector<UInt>(), Object ).constructor;
		var cvdouble:Class<Float> = untyped __as__( new Vector<Float>(), Object ).constructor;
		var cvobject:Class<Dynamic> = untyped __as__( new Vector<Dynamic>(), Object ).constructor;

		var writeValue:Dictionary->ByteArray->UInt->Dynamic->Void = null;

		writeValue = function(hash:Dictionary, _memory:ByteArray, _position:UInt, value:Dynamic):Void {
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

						if ( untyped __in__( value, hash ) ) Error.throwError( StackOverflowError, 2024 );
						hash[ value ] = true;

						var i:Int = 0;
						var l:Int;
						if (
							( untyped __is__( value, Array ) ) ||
							( untyped __is__( value, cvobject ) )
						) {

							TMP.writeCharCode( _position, Char.LEFT_BRACKET );
							l = untyped value.length - 1;
							while ( l >= 0 && value[ l ] == null ) {
								--l;
							}
							++l;
							if ( l > 0 ) {
								writeValue( hash, _memory, _position, value[ 0 ] );
								_position = position;
								while ( ++i < l ) {
									TMP.writeCharCode( _position, Char.COMMA );
									writeValue( hash, _memory, _position, value[ i ] );
									_position = position;
								}
							}
							TMP.writeCharCode( _position, Char.RIGHT_BRACKET );

						} else if (
							( untyped __is__( value, cvint ) ) ||
							( untyped __is__( value, cvuint ) )
						) {

							TMP.writeCharCode( _position, Char.LEFT_BRACKET );
							l = value.length;
							if ( l > 0 ) {
								TMP.writeInt( _memory, _position, value[ 0 ] );
								while ( ++i < l ) {
									TMP.writeCharCode( _position, Char.COMMA );
									TMP.writeInt( _memory, _position, value[ i ] );
								}
							}
							TMP.writeCharCode( _position, Char.RIGHT_BRACKET );

						} else if (
							( untyped __is__( value, cvdouble ) )
						) {

							TMP.writeCharCode( _position, Char.LEFT_BRACKET );
							l = untyped value.length - 1;
							while ( l >= 0 && !untyped __global__["isFinite"]( value[ l ] ) ) {
								--l;
							}
							++l;
							if ( l > 0 ) {
								TMP.writeNumber( _memory, _position, value[ 0 ] );
								while ( ++i < l ) {
									TMP.writeCharCode( _position, Char.COMMA );
									TMP.writeNumber( _memory, _position, value[ i ] );
								}
							}
							TMP.writeCharCode( _position, Char.RIGHT_BRACKET );

						} else {

							TMP.writeCharCode( _position, Char.LEFT_BRACE );

							var n:String;
							var f:Bool = false;

							if ( value.constructor != Object ) {

								var v:Dynamic;
								var list:XMLList = SerializationHelper.getPropertyNames( value );
								l = list.length();
								i = 0;
								while ( i < l ) {
									n = untyped list[ i ];
									try {

										v = value[ untyped n ];

										if ( f )	TMP.writeCharCode( _position, Char.COMMA );
										else		f = true;
										TMP.writeString( _memory, _position, n );
										TMP.writeCharCode( _position, Char.COLON );
										writeValue( hash, _memory, _position, v );
										_position = position;

									} catch ( e:Dynamic ) {
										// skip
									}
									++i;
								}

							}

							var arr:Array<String> = untyped __keys__( value );
							for ( n in arr ) {
								if ( ! untyped __is__( value[ n ], Function ) ) {
									if ( f )	TMP.writeCharCode( _position, Char.COMMA );
									else		f = true;
									TMP.writeString( _memory, _position, n );
									TMP.writeCharCode( _position, Char.COLON );
									writeValue( hash, _memory, _position, value[ untyped n ] );
									_position = position;
								}
							}
							
							TMP.writeCharCode( _position, Char.RIGHT_BRACE );

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
			Memory.setI32( _position, 0x65757274 );	// true
			_position += 4;
		} else {
			Memory.setI32( _position, 0x736C6166 );	// fals
			_position += 4;
			Memory.setByte( _position, 0x65 );		// e
			++_position;
		}
	}

	public static inline function writeNull(_position:UInt):Void {
		Memory.setI32( _position, 0x6C6C756E );		// null
		_position += 4;
	}

	public static inline function writeNumber(_memory:ByteArray, _position:UInt, value:Float):Void {
		if ( untyped __global__["isFinite"]( value ) ) {
			if ( value % 1 == 0 ) {
				writeInt( _memory, _position, value );
			} else {
				_memory.position = _position;
				_memory.writeUTFBytes( untyped value.toString() );
				_position = _memory.position;
			}
		} else {
			writeNull( _position );
		}
	}

	public static inline function writeInt(_memory:ByteArray, _position:UInt, value:Float):Void {
		if ( value == 0 ) {
			writeCharCode( _position, Char.ZERO );
		} else {
			if ( value < 0 ) {
				writeCharCode( _position, Char.DASH );
				value = -value;
			}
			if ( value > 1e6 && value <= 0xFFFFFFFF ) {
				Memory.setI16( _position, 0x7830 );	// 0x
				_memory.position = _position + 2;
				_memory.writeUTFBytes( untyped value.toString( 16 ) );
				_position = _memory.position;
			} else {
				_memory.position = _position;
				_memory.writeUTFBytes( untyped value.toString() );
				_position = _memory.position;
			}
		}
	}

	public static inline function writeStringEmpty(_position:UInt):Void {
		Memory.setI16( _position, 0x2222 );
		_position += 2;
	}

	public static inline function writeString(_memory:ByteArray, _position:UInt, value:String):Void {
		if ( value.length <= 0 ) {

			writeStringEmpty( _position );

		} else {

			writeCharCode( _position, Char.DOUBLE_QUOTE );

			// write temp string
			var i:UInt = _position + value.length * 4;
			var j:UInt = i;
			_memory.position = i;
			_memory.writeUTFBytes( value );
			var len:UInt = _memory.position;
			_memory.position = _position;

			var c:UInt;
			while ( i < len ){
				c = Memory.getByte( i );
				if ( c < Char.SPACE || c == Char.DOUBLE_QUOTE || c == Char.BACK_SLASH ) {
					if ( i != j ) {
						_memory.position = _position;
						_memory.writeBytes( _memory, j, i-j );
						_position = _memory.position;
					}
					j = i + 1;
					if ( c == Char.NEWLINE ) {
						Memory.setI16( _position, 0x6E5C ); // \n
						_position += 2;
					} else if ( c == Char.CARRIAGE_RETURN ) {
						Memory.setI16( _position, 0x725C ); // \r
						_position += 2;
					} else if ( c == Char.TAB ) {
						Memory.setI16( _position, 0x745C ); // \t
						_position += 2;
					} else if ( c == Char.DOUBLE_QUOTE ) {
						Memory.setI16( _position, 0x225C ); // \"
						_position += 2;
					} else if ( c == Char.BACK_SLASH ) {
						Memory.setI16( _position, 0x5C5C ); // \\
						_position += 2;
					} else if ( c == Char.VERTICAL_TAB ) {
						Memory.setI16( _position, 0x765C ); // \v
						_position += 2;
					} else if ( c == Char.BACKSPACE ) {
						Memory.setI16( _position, 0x625C ); // \b
						_position += 2;
					} else if ( c == Char.FORM_FEED ) {
						Memory.setI16( _position, 0x665C ); // \f
						_position += 2;
					} else if ( c < Char.SPACE ) {
						Memory.setI16( _position, 0x785C ); // \x
						_position += 2;
						writeCharCode( _position, Memory.getByte( c >>> 4 ) );
						writeCharCode( _position, Memory.getByte( c & 0xF ) );
					}
				}
				++i;
			};
			if ( i != j ) {
				_memory.position = _position;
				_memory.writeBytes( _memory, j, i-j );
				_position = _memory.position;
			}

			writeCharCode( _position, Char.DOUBLE_QUOTE );

		}
	}

}