////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.meta {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					06.03.2010 13:18:17
	 */
	public class AbstractInfo {
		
		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------
		
		protected namespace $protected_inf;
		
		use namespace $protected_inf;
		
		//--------------------------------------------------------------------------
		//
		//  Protected class methods
		//
		//--------------------------------------------------------------------------
		
		protected static function parseType(name:String):QName {
			var arr:Array = name.split( '::', 2 );
			if ( arr.length > 1 ) {
				return new QName( arr[ 0 ], arr[ 1 ] );
			} else {
				return new QName( '', arr[ 0 ] );
			}
		}
		
		protected static function typeURI(name:QName):String {
			return 'class://' + name;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected class variables
		//
		//--------------------------------------------------------------------------
		
		protected static const ns_rdf:Namespace = new Namespace( 'rdf', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' );
		
		protected static const ns_as3:Namespace = new Namespace( 'as3', AS3 + '#' );

		protected static const ns_dc:Namespace = new Namespace( 'dc', 'http://purl.org/dc/elements/1.1/' );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function AbstractInfo() {
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function toXML():XML {
			return <node />;
		}

		public function toString():String {
			return this.toXML().toXMLString();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		$protected_inf function parseXML(xml:XML):void {
		}
		
	}
	
}