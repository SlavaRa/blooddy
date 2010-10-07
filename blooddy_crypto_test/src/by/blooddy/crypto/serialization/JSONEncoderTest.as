////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.serialization {

	import flash.xml.XMLDocument;
	
	import org.flexunit.Assert;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class JSONEncoderTest {

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		[Test]
		public function encode_null():void {
			Assert.assertEquals(
				JSONEncoder.encode( null ),
				'null'
			);
		}

		[Test]
		public function encode_undefined():void {
			Assert.assertEquals(
				JSONEncoder.encode( undefined ),
				'null'
			);
		}

		[Test]
		public function encode_notFinite():void {
			Assert.assertEquals(
				JSONEncoder.encode( NaN ),
				'null'
			);
			Assert.assertEquals(
				JSONEncoder.encode( Number.NEGATIVE_INFINITY ),
				'null'
			);
			Assert.assertEquals(
				JSONEncoder.encode( Number.POSITIVE_INFINITY ),
				'null'
			);
		}

		[Test]
		public function encode_number_positive():void {
			Assert.assertEquals(
				JSONEncoder.encode( 5 ),
				'5'
			);
		}
		
		[Test]
		public function encode_number_negative():void {
			Assert.assertEquals(
				JSONEncoder.encode( -5 ),
				'-5'
			);
		}
		
		[Test]
		public function encode_false():void {
			Assert.assertEquals(
				JSONEncoder.encode( false ),
				'false'
			);
		}
		
		[Test]
		public function encode_true():void {
			Assert.assertEquals(
				JSONEncoder.encode( true ),
				'true'
			);
		}
		
		[Test]
		public function encode_string():void {
			Assert.assertEquals(
				JSONEncoder.encode( 'asd' ),
				'"asd"'
			);
		}

		[Test]
		public function encode_string_escape():void {
			Assert.assertEquals(
				JSONEncoder.encode( '\x33\u0044\t\n\b\r\t\v\f\\"' ),
				'"\x33\u0044\\t\\n\\b\\r\\t\\v\\f\\\\\\""'
			);
		}
		
		[Test]
		public function encode_string_nonescape():void {
			Assert.assertEquals(
				JSONEncoder.encode( '\x3\u044\5' ),
				'"\x3\u044\5"'
			);
		}

		[Test]
		public function encode_xml():void {
			Assert.assertEquals(
				JSONEncoder.encode( <xml field="098"><node field="123" /></xml> ),
				'"<xml field=\\"098\\"><node field=\\"123\\"/></xml>"'
			);
		}

		[Test]
		public function encode_xmlDocument():void {
			Assert.assertEquals(
				JSONEncoder.encode( new XMLDocument( '<xml field="098">\n         <node            field = "123" />\n\r\t</xml>' ) ),
				'"<xml field=\\"098\\"><node field=\\"123\\"/></xml>"'
			);
		}

		[Test]
		public function encode_xml_empty():void {
			Assert.assertEquals(
				JSONEncoder.encode( new XML() ),
				'""'
			);
		}
		
		[Test]
		public function encode_xmlDocument_empty():void {
			Assert.assertEquals(
				JSONEncoder.encode( new XMLDocument() ),
				'""'
			);
		}

		[Test]
		public function encode_array_empty():void {
			Assert.assertEquals(
				JSONEncoder.encode( [] ),
				'[]'
			);
		}

		[Test]
		public function encode_array_trailComma():void {
			Assert.assertEquals(
				JSONEncoder.encode( [5,,,] ),
				'[5]'
			);
			Assert.assertEquals(
				JSONEncoder.encode( new Array( 100 ) ),
				'[]'
			);
		}
		
		[Test]
		public function encode_array_leadComma():void {
			Assert.assertEquals(
				JSONEncoder.encode( [,,5] ),
				'[null,null,5]'
			);
		}
		
		[Test]
		public function encode_vector_empty():void {
			Assert.assertEquals(
				JSONEncoder.encode( new <*>[] ),
				'[]'
			);
			Assert.assertEquals(
				JSONEncoder.encode( new <SimpleClass>[] ),
				'[]'
			);
			Assert.assertEquals(
				JSONEncoder.encode( new <uint>[] ),
				'[]'
			);
			Assert.assertEquals(
				JSONEncoder.encode( new <int>[] ),
				'[]'
			);
			Assert.assertEquals(
				JSONEncoder.encode( new <Number>[] ),
				'[]'
			);
		}
		
		[Test]
		public function encode_vector_int():void {
			Assert.assertEquals(
				JSONEncoder.encode( new <uint>[1,5,6] ),
				'[1,5,6]'
			);
			Assert.assertEquals(
				JSONEncoder.encode( new <int>[1,-5,6] ),
				'[1,-5,6]'
			);
		}
		
		[Test]
		public function encode_vector_number():void {
			Assert.assertEquals(
				JSONEncoder.encode( new <Number>[1.555,0.5e-1,6,NaN] ),
				'[1.555,0.05,6]'
			);
		}
		
		[Test]
		public function encode_vector_object():void {
			Assert.assertEquals(
				JSONEncoder.encode( new <*>[{},5,null] ),
				'[{},5]'
			);
		}
		
		[Test]
		public function encode_object_empty():void {
			Assert.assertEquals(
				JSONEncoder.encode( {} ),
				'{}'
			);
		}
		
		[Test]
		public function encode_object_key_string():void {
			Assert.assertEquals(
				JSONEncoder.encode( { "string key": "value" } ),
				'{"string key":"value"}'
			);
		}
		
		[Test]
		public function encode_object_key_nonstring():void {
			Assert.assertEquals(
				JSONEncoder.encode( { key: "value", 5:true } ),
				'{"key":"value","5":true}'
			);
		}
		
		[Test]
		public function encode_object_key_undefined_NaN():void {
			Assert.assertEquals(
				JSONEncoder.encode( {undefined:1,NaN:2} ),
				'{"undefined":1,"NaN":2}'
			);
		}

		[Test]
		public function encode_object_class():void {
			Assert.assertEquals(
				JSONEncoder.encode( new SimpleClass() ),
				'{"accessor":4,"variable":1,"constant":2,"getter":3,"dynamicProperty":0}'
			);
		}

		[Test( expects="flash.errors.StackOverflowError" )]
		public function encode_object_recursion():void {
			var o:SimpleClass = new SimpleClass();
			o.arr = [ o ];
			JSONEncoder.encode( o );
		}
		
	}

}