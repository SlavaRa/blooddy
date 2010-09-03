////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.meta {

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="namespace", name="$protected_info" )]

	[Exclude( kind="method", name="parseXML" )]

	[ExcludeClass]
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
		
		protected namespace $protected_info;
		
		use namespace $protected_info;
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		internal static const ns_rdf:Namespace = new Namespace( 'rdf', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' );
		
		internal static const ns_as3:Namespace = new Namespace( 'as3', AS3 + '#' );
		
		internal static const ns_dc:Namespace = new Namespace( 'dc', 'http://purl.org/dc/elements/1.1/' );

		internal static const ns_rdfs:Namespace = new Namespace( 'rdfs', 'http://www.w3.org/2000/01/rdf-schema' );

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
		
		$protected_info function parseXML(xml:XML):void {
		}
		
	}
	
}