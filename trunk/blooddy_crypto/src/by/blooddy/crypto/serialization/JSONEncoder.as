////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.serialization {

	import flash.errors.StackOverflowError;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.xml.XMLDocument;
	
	/**
	 * @author					BlooDHounD
	 * @version					2.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					01.10.2010 15:53:47
	 */
	public class JSONEncoder {
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _SETTINGS:Object = {
			ignoreComments: true,
			ignoreProcessingInstructions: false,
			ignoreWhitespace: true,
			prettyIndent: false,
			prettyPrinting: false
		}
		
		/**
		 * @private
		 */
		private static const _TRUE:ByteArray = new ByteArray();
		_TRUE.writeUTFBytes( 'true' );

		/**
		 * @private
		 */
		private static const _FALSE:ByteArray = new ByteArray();
		_FALSE.writeUTFBytes( 'false' );
		
		/**
		 * @private
		 */
		private static const _NULL:ByteArray = new ByteArray();
		_NULL.writeUTFBytes( 'null' );

		/**
		 * @private
		 */
		private static const _STRING:ByteArray = new ByteArray();
		_STRING.writeUTFBytes( '""' );
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @param	value
		 *
		 * @return
		 * 
		 * @throws	flash.errors.StackOverflowError
		 */
		public static function encode(value:*):String {
			var settings:Object = XML.settings();
			var bytes:ByteArray = new ByteArray();
			XML.setSettings( _SETTINGS );
			writeValue( bytes, value, new Dictionary() );
			XML.setSettings( settings );
			bytes.position = 0;
			return bytes.readUTFBytes( bytes.length );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function writeValue(bytes:ByteArray, value:*, hash:Dictionary):void {
			switch ( typeof value ) {
				case 'number':
					if ( isFinite( value ) )	bytes.writeUTFBytes( value );
					else						bytes.writeBytes( _NULL );
					break;

				case 'boolean':
					bytes.writeBytes( value ? _TRUE : _FALSE );
					break;

				case 'xml':
					value = value.toXMLString();

				case 'string':
					writeString( bytes, value );
					break;

				case 'object':
					if ( value ) {
						if ( value is XMLDocument ) {

							if ( value.childNodes.length > 0 ) {
								writeString( bytes, ( new XML( value ) ).toXMLString() );
							} else {
								bytes.writeBytes( _STRING );
							}

						} else { 

							if ( value in hash ) Error.throwError( StackOverflowError, 2024 );
							hash[ value ] = true;

							var i:int, l:int;
							
							if ( value is Array || value is Vector.<*> ) { // array

								bytes.writeByte( 91 );	// bytes.writeUTFBytes( '[' );
								l = value.length - 1;
								while ( l >= 0 && value[ l ] == null ) {
									--l;
								}
								++l;
								if ( l > 0 ) {
									writeValue( bytes, value[ 0 ], hash );
									for ( i=1; i<l; ++i ) {
										bytes.writeByte( 44 );	// bytes.writeUTFBytes( ',' );
										writeValue( bytes, value[ i ], hash );
									}
								}
								bytes.writeByte( 93 );	// bytes.writeUTFBytes( ']' );

							} else if ( value is Vector.<uint> || value is Vector.<int> ) { // array

								bytes.writeByte( 91 );	// bytes.writeUTFBytes( '[' );
								l = value.length;
								if ( l > 0 ) {
									bytes.writeUTFBytes( value[ 0 ] );
									for ( i=1; i<l; ++i ) {
										bytes.writeByte( 44 );	// bytes.writeUTFBytes( ',' );
										bytes.writeUTFBytes( value[ i ] );
									}
								}
								bytes.writeByte( 93 );	// bytes.writeUTFBytes( ']' );

							} else if ( value is Vector.<Number> ) { // array

								bytes.writeByte( 91 );	// bytes.writeUTFBytes( '[' );
								l = value.length - 1;
								while ( l >= 0 && !isFinite( value[ l ] ) ) {
									--l;
								}
								++l;
								if ( l > 0 ) {
									if ( isFinite( value[ 0 ] ) )	bytes.writeUTFBytes( value[ 0 ] );
									else							bytes.writeBytes( _NULL );
									for ( i=1; i<l; ++i ) {
										bytes.writeByte( 44 );	// bytes.writeUTFBytes( ',' );
										if ( isFinite( value[ 0 ] ) )	bytes.writeUTFBytes( value[ i ] );
										else							bytes.writeBytes( _NULL );
									}
								}
								bytes.writeByte( 93 );	// bytes.writeUTFBytes( ']' );

							} else { // object

								bytes.writeByte( 123 );	// bytes.writeUTFBytes( '{' );
								
								var n:String;
								var f:Boolean;
								
								if ( value.constructor !== Object ) {
									
									var xml:XML = describeType( value );
									
									var list:XMLList;
									var v:*;
									for each ( n in xml.*.(
											n = name(),
											(
												(
													name() == 'accessor' &&
													@access.charAt( 0 ) == 'r'
												) ||
												n == 'variable' ||
												n == 'constant'
											) &&
											attribute( 'uri' ).length() <= 0 &&
											(
												list = metadata,
												list.length() <= 0 ||
												list.( @name == 'Transient' ).length() <= 0
											)
										).@name
									) {
										try {

											v = value[ n ];

											if ( f )	bytes.writeByte( 44 );	// bytes.writeUTFBytes( ',' );
											else		f = true;
											writeString( bytes, n );
											bytes.writeByte( 58 );	// bytes.writeUTFBytes( ':' );
											writeValue( bytes, v, hash );

										} catch ( e:* ) {
											// skip
										}
									}
									
								}
								
								for ( n in value ) {
									if ( value[ n ] is Function ) continue;
									if ( f )	bytes.writeByte( 44 );	// bytes.writeUTFBytes( ',' );
									else		f = true;
									writeString( bytes, n );
									bytes.writeByte( 58 );	// bytes.writeUTFBytes( ':' );
									writeValue( bytes, value[ n ], hash );
								}
								
								bytes.writeByte( 125 );	// bytes.writeUTFBytes( '}' );

							}
							delete hash[ value ];
						}
						break;
					}
				default:
					bytes.writeBytes( _NULL );
					break;
			}
		}
		
		/**
		 * @private
		 */
		private static function writeString(bytes:ByteArray, value:String):void {
			bytes.writeByte( 34 );	// bytes.writeUTFBytes( '"' );
			var l:uint = value.length;
			var s:String;
			var c:uint;
			var j:uint = 0;
			for ( var i:uint = 0; i<l; ++i ) {
				switch ( c = value.charCodeAt( i ) ) {
					case 13/*CARRIAGE_RETURN*/:	s = '\\r';	break;
					case 10/*NEWLINE*/:			s = '\\n';	break;
					case  9/*TAB*/:				s = '\\t';	break;
					case 11/*VERTICAL_TAB*/:	s = '\\v';	break;
					case  8/*BACKSPACE*/:		s = '\\b';	break;
					case 12/*FORM_FEED*/:		s = '\\f';	break;
					case 92/*BACK_SLASH*/:		s = '\\\\';	break;
					case 34/*DOUBLE_QUOTE*/:	s = '\\\"';	break;
					default:
						if ( c < 32 ) {
							s = '\\x' + ( c < 16 ? '0' : '' ) + c.toString( 16 );
						}
						break;
				}
				if ( s ) {
					bytes.writeUTFBytes( value.substring( j, i ) );
					bytes.writeUTFBytes( s );
					j = i + 1;
					s = null;
				}
			}
			bytes.writeUTFBytes( j == 0 ? value : value.substr( j ) );
			bytes.writeByte( 34 );	// bytes.writeUTFBytes( '"' );
		}
		
	}
	
}