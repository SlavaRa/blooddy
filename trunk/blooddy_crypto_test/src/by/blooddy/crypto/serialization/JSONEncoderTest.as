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
				JSON.encode( null ),
				'null'
			);
		}

		[Test]
		public function encode_undefined():void {
			Assert.assertEquals(
				JSON.encode( undefined ),
				'null'
			);
		}

		[Test]
		public function encode_notFinite():void {
			Assert.assertEquals(
				JSON.encode( NaN ),
				'null'
			);
			Assert.assertEquals(
				JSON.encode( Number.NEGATIVE_INFINITY ),
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
				JSON.encode( 5 ),
				'5'
			);
		}
		
		[Test]
		public function encode_number_negative():void {
			Assert.assertEquals(
				JSON.encode( -5 ),
				'-5'
			);
		}
		
		[Test]
		public function encode_false():void {
			Assert.assertEquals(
				JSON.encode( false ),
				'false'
			);
		}
		
		[Test]
		public function encode_true():void {
			Assert.assertEquals(
				JSON.encode( true ),
				'true'
			);
		}
		
		[Test]
		public function encode_string():void {
			Assert.assertEquals(
				JSON.encode( 'asd' ),
				'"asd"'
			);
		}

		[Test]
		public function encode_string_enpty():void {
			Assert.assertEquals(
				JSON.encode( '' ),
				'""'
			);
		}
		
		[Test]
		public function encode_string_escape():void {
			Assert.assertEquals(
				JSON.encode( '\x33\u0044\t\n\b\r\t\v\f\\"' ),
				'"\x33\u0044\\t\\n\\b\\r\\t\\v\\f\\\\\\""'
			);
		}
		
		[Test]
		public function encode_string_nonescape():void {
			Assert.assertEquals(
				JSON.encode( '\x3\u044\5' ),
				'"\x3\u044\5"'
			);
		}

		[Test]
		public function encode_xml():void {
			Assert.assertEquals(
				JSON.encode( <xml field="098"><node field="123" /></xml> ),
				'"<xml field=\\"098\\"><node field=\\"123\\"/></xml>"'
			);
		}

		[Test]
		public function encode_xmlDocument():void {
			Assert.assertEquals(
				JSON.encode( new XMLDocument( '<xml field="098">\n         <node            field = "123" />\n\r\t</xml>' ) ),
				'"<xml field=\\"098\\"><node field=\\"123\\"/></xml>"'
			);
		}

		[Test]
		public function encode_xml_empty():void {
			trace( JSON.encode( new XML() ) );
			Assert.assertEquals(
				JSON.encode( new XML() ),
				'""'
			);
		}
		
		[Test]
		public function encode_xmlDocument_empty():void {
			Assert.assertEquals(
				JSON.encode( new XMLDocument() ),
				'""'
			);
		}

		[Test]
		public function encode_array_empty():void {
			Assert.assertEquals(
				JSON.encode( [] ),
				'[]'
			);
		}

		[Test]
		public function encode_array_trailComma():void {
			Assert.assertEquals(
				JSON.encode( [5,,,] ),
				'[5]'
			);
			Assert.assertEquals(
				JSON.encode( new Array( 100 ) ),
				'[]'
			);
		}
		
		[Test]
		public function encode_array_leadComma():void {
			Assert.assertEquals(
				JSON.encode( [,,5] ),
				'[null,null,5]'
			);
		}
		
		[Test]
		public function encode_vector_empty():void {
			Assert.assertEquals(
				JSON.encode( new <*>[] ),
				'[]'
			);
			Assert.assertEquals(
				JSON.encode( new <SimpleClass>[] ),
				'[]'
			);
			Assert.assertEquals(
				JSON.encode( new <uint>[] ),
				'[]'
			);
			Assert.assertEquals(
				JSON.encode( new <int>[] ),
				'[]'
			);
			Assert.assertEquals(
				JSON.encode( new <Number>[] ),
				'[]'
			);
		}
		
		[Test]
		public function encode_vector_int():void {
			Assert.assertEquals(
				JSON.encode( new <uint>[1,5,6] ),
				'[1,5,6]'
			);
			Assert.assertEquals(
				JSON.encode( new <int>[1,-5,6] ),
				'[1,-5,6]'
			);
		}
		
		[Test]
		public function encode_vector_number():void {
			Assert.assertEquals(
				JSON.encode( new <Number>[1.555,0.5e-1,6,NaN] ),
				'[1.555,0.05,6]'
			);
		}
		
		[Test]
		public function encode_vector_object():void {
			Assert.assertEquals(
				JSON.encode( new <*>[{},5,null] ),
				'[{},5]'
			);
		}
		
		[Test]
		public function encode_object_empty():void {
			Assert.assertEquals(
				JSON.encode( {} ),
				'{}'
			);
		}
		
		[Test]
		public function encode_object_key_string():void {
			Assert.assertEquals(
				JSON.encode( { "string key": "value" } ),
				'{"string key":"value"}'
			);
		}
		
		[Test]
		public function encode_object_key_nonstring():void {
			Assert.assertEquals(
				JSON.encode( { key: "value", 5:true } ),
				'{"key":"value","5":true}'
			);
		}
		
		[Test]
		public function encode_object_key_undefined_NaN():void {
			Assert.assertEquals(
				JSON.encode( {undefined:1,NaN:2} ),
				'{"undefined":1,"NaN":2}'
			);
		}

		[Test]
		public function encode_object_class():void {
			Assert.assertEquals(
				JSON.encode( new SimpleClass() ),
				'{"accessor":4,"variable":1,"constant":2,"getter":3,"dynamicProperty":0}'
			);
		}

		[Test( expects="flash.errors.StackOverflowError" )]
		public function encode_object_recursion():void {
			var o:SimpleClass = new SimpleClass();
			o.arr = [ o ];
			JSON.encode( o );
		}
		
	}

}