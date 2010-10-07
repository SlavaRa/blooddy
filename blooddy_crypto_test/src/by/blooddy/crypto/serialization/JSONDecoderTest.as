////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.serialization {

	import org.flexunit.Assert;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class JSONDecoderTest {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function equalsObjects(o1:Object, o2:Object):Boolean {

			if ( o1 == o2 ) return true;
			
			if ( !o1 || !o2 ) return false;
			if ( o1.constructor !== o2.constructor ) return false;

			if ( o1 is Array ) {
				if ( o1.length != o2.length ) return false;
			}
			
			var i:Object;
			for ( i in o1 ) {
				if ( !( i in o2 ) ) return false;
				else if ( o1[ i ] != o2[ i ] ) {
					switch ( typeof o1[ i ] ) {
						case 'object':
							if ( !equalsObjects( o1[ i ], o2[ i ] ) ) {
								return false;
							}
							break;
						case 'number':
							if ( isFinite( o1[ i ] ) || isFinite( o2[ i ] ) ) {
								return false;
							}
							break;
					}
				}
			}
			
			for ( i in o2 ) {
				if ( !( i in o2 ) ) return false;
			}

			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		[Test( expects="TypeError" )]
		public function decode_value_null():void {
			JSONDecoder.decode( null );
		}

		[Test]
		public function decode_value_empty():void {
			Assert.assertTrue(
				JSONDecoder.decode( '' ) === undefined
			);
		}

		[Test]
		public function decode_undefined():void {
			// assertStrictlyEquals not work with undefined
			Assert.assertTrue(
				JSONDecoder.decode( 'undefined' ) === undefined
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_identifier():void {
			JSONDecoder.decode( 'identifier' );
		}
		
		[Test]
		public function decode_true():void {
			Assert.assertTrue(
				JSONDecoder.decode( 'true' )
			);
		}
		
		[Test]
		public function decode_false():void {
			Assert.assertFalse(
				JSONDecoder.decode( 'false' )
			);
		}
		
		[Test]
		public function decode_null():void {
			Assert.assertNull(
				JSONDecoder.decode( 'null' )
			);
		}

		[Test]
		public function decode_string():void {
			Assert.assertEquals(
				JSONDecoder.decode( '"string"' ),
				'string'
			);
			Assert.assertEquals(
				JSONDecoder.decode( "'string'" ),
				'string'
			);
		}

		[Test( expects="SyntaxError" )]
		public function decode_string_noclose():void {
			JSONDecoder.decode( '"string' );
		}
		
		[Test]
		public function decode_string_escape():void {
			Assert.assertEquals(
				JSONDecoder.decode( '"\\x33\\u0044\\t\\n\\b\\r\\t\\v\\f\\\\\\""' ),
				'\x33\u0044\t\n\b\r\t\v\f\\\"'
			);
		}
		
		[Test]
		public function decode_string_nonescape():void {
			Assert.assertEquals(
				JSONDecoder.decode( '"\\x3\\u044\\5"' ),
				'\x3\u044\5'
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_sring_newline():void {
			JSONDecoder.decode( '"firs\nsecond"' );
		}

		[Test]
		public function decode_number_zero():void {
			Assert.assertEquals(
				JSONDecoder.decode( '0' ),
				0
			);
		}

		[Test]
		public function decode_number_firstzero():void {
			Assert.assertEquals(
				JSONDecoder.decode( '01' ),
				01
			);
			Assert.assertEquals(
				JSONDecoder.decode( '002' ),
				002
			);
		}

		[Test]
		public function decode_number_positive():void {
			Assert.assertEquals(
				JSONDecoder.decode( '123' ),
				123
			);
		}
		
		[Test]
		public function decode_number_float():void {
			Assert.assertEquals(
				JSONDecoder.decode( '1.123' ),
				1.123
			);
		}

		[Test( expects="SyntaxError" )]
		public function decode_number_nonfloat():void {
			JSONDecoder.decode( '1.' );
		}
		
		[Test]
		public function decode_number_float_witoutLeadZero():void {
			Assert.assertEquals(
				JSONDecoder.decode( '.123' ),
				.123
			);
		}

		public function decode_number_exp():void {
			Assert.assertEquals(
				JSONDecoder.decode( '1E3' ),
				1e3
			);
			Assert.assertEquals(
				JSONDecoder.decode( '1e-3' ),
				1e-3
			);
			Assert.assertEquals(
				JSONDecoder.decode( '1e+3' ),
				1e+3
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_number_nonexp():void {
			JSONDecoder.decode( '1E' );
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_number_floatexp():void {
			JSONDecoder.decode( '1E1.2' );
		}
		
		[Test]
		public function decode_number_hex():void {
			Assert.assertEquals(
				JSONDecoder.decode( '0xFF' ),
				0xFF
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_number_nonhex():void {
			JSONDecoder.decode( '0x' );
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_number_nonhex2():void {
			JSONDecoder.decode( '0xZ' );
		}
		
		[Test]
		public function decode_number_NaN():void {
			Assert.assertTrue(
				isNaN( JSONDecoder.decode( 'NaN' ) )
			);
		}

		[Test]
		public function decode_dash_number():void {
			Assert.assertEquals(
				JSONDecoder.decode( '-  \n 5' ),
				-5
			);
		}
		
		[Test]
		public function decode_dash_undefined():void {
			Assert.assertTrue(
				isNaN( JSONDecoder.decode( '-undefined' ) )
			);
		}
		
		[Test]
		public function decode_dash_null():void {
			Assert.assertEquals(
				JSONDecoder.decode( '-null' ),
				-null
			);
		}

		[Test]
		public function decode_dash_NaN():void {
			Assert.assertTrue(
				isNaN( JSONDecoder.decode( '-NaN' ) )
			);
		}
		
		[Test]
		public function decode_dash_withspace():void {
			Assert.assertEquals(
				JSONDecoder.decode( '-  \n 5' ),
				-   5
			);
		}

		[Test( expects="SyntaxError" )]
		public function decode_dash_false():void {
			JSONDecoder.decode( '-false' );
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_dash_true():void {
			JSONDecoder.decode( '-true' );
		}
		
		[Test]
		public function decode_object_empty():void {
			Assert.assertTrue(
				equalsObjects(
					JSONDecoder.decode( '{}' ),
					{}
				)
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_object_leadComma():void {
			JSONDecoder.decode( '{,}' );
		}

		[Test]
		public function decode_object_key_string():void {
			Assert.assertTrue(
				equalsObjects(
					JSONDecoder.decode( '{"key":"value"}' ),
					{"key":"value"}
				)
			);
		}

		[Test]
		public function decode_object_key_nonstring():void {
			Assert.assertTrue(
				equalsObjects(
					JSONDecoder.decode( '{key1:"value1",5:"value2"}' ),
					{key1:"value1",5:"value2"}
				)
			);
		}
		
		[Test]
		public function decode_object_key_undefined_NaN():void {
			Assert.assertTrue(
				equalsObjects(
					JSONDecoder.decode( '{undefined:1,NaN:2}' ),
					{undefined:1,NaN:2}
				)
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_object_key_null():void {
			JSONDecoder.decode( '{null:1}' );
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_object_key_false():void {
			JSONDecoder.decode( '{false:1}' );
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_object_key_true():void {
			JSONDecoder.decode( '{true:1}' );
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_object_noclose():void {
			JSONDecoder.decode( '{key1:"value1"' );
		}
		
		[Test]
		public function decode_array_empty():void {
			Assert.assertTrue(
				equalsObjects(
					JSONDecoder.decode( '[]' ),
					[]
				)
			);
		}
		
		[Test]
		public function decode_array_trailComma():void {
			Assert.assertTrue(
				equalsObjects(
					JSONDecoder.decode( '[,,,]' ),
					[,,,]
				)
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_array_withIdentifier():void {
			JSONDecoder.decode( '[identifier]' );
		}

		[Test]
		public function decode_comment_line():void {
			Assert.assertTrue(
				equalsObjects(
					JSONDecoder.decode( '5// comment' ),
					5// comment
				)
			);
		}
		
		[Test]
		public function decode_comment_multiline():void {
			Assert.assertTrue(
				equalsObjects(
					JSONDecoder.decode( '[1/* line1\nline2*/,2]' ),
					[1/* line1\nline2*/,2]
				)
			);
		}
		
		[Test]
		public function decode_comment_only():void {
			Assert.assertTrue(
				JSONDecoder.decode( '// comment' ) === undefined
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_multilineComments_noclose():void {
			JSONDecoder.decode( '1/* comment' );
		}
		
		[Test]
		public function decode_object_all():void {
			Assert.assertTrue(
				equalsObjects(
					JSONDecoder.decode( '{key1: {"key2" /*comment\r222\n*/: null},// comment\n   3 : [undefined,true,false,\n-   .5e3,"string",				NaN]}' ),
					{ key1: { "key2" : null }, 3 : [ undefined, true, false, -.5e3, "string", NaN ] }
				)
			);
		}
		
	}

}