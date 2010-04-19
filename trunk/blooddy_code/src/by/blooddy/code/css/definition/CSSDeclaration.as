////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css.definition {

	import by.blooddy.code.css.definition.values.CSSValue;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					18.04.2010 5:37:11
	 */
	public class CSSDeclaration {
		
		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function convertName(name:String):String {
			var result:String = '';
			const l:uint = name.length;
			var c:String, c2:String;
			var j:uint = 0;
			for ( var i:uint = 0; i<l; i++ ) {
				c = name.charAt( i );
				c2 = c.toLowerCase();
				if ( c2 != c ) {
					result += name.substring( j, i ) + '-' + c2;
					j = i + 1;
				}
			}
			result += name.substr( j );
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function CSSDeclaration(name:String, values:Vector.<CSSValue>) {
			super();
			this.name = name;
			this.values = values;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var name:String;

		public var values:Vector.<CSSValue>;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function toString():String {
			return convertName( this.name ) + ':' + this.values.join( ' ' );
		}

	}
	
}