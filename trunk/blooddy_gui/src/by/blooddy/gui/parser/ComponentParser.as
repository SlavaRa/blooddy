////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 q1
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.parser {
	
	import by.blooddy.core.blooddy;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.gui.display.Component;
	
	import flash.events.EventDispatcher;
	import by.blooddy.code.errors.ParserError;
	
	//--------------------------------------
	//  Implements events: ILoadable
	//--------------------------------------
	
	[Event( name="open", type="flash.events.Event" )]
	[Event( name="complete", type="flash.events.Event" )]
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]
	[Event( name="loaderInit", type="by.blooddy.core.events.net.loading.LoaderEvent" )]
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.04.2010 17:58:08
	 */
	public class ComponentParser extends EventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		private static const _COMPONENT_NAME:QName = new QName( blooddy, 'component' );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function ComponentParser() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function parse(xml:XML):void {

			trace( xml.toXMLString() );
			if ( xml.name() != _COMPONENT_NAME ) throw new ParserError();

			var list:XMLList;
			
			list = xml.blooddy::head;
			if ( list.length() > 0 ) {
				// head
				trace( list[ 0 ].toXMLString() );
			}
			list = xml.blooddy::body;
			if ( list.length() > 0 ) {
				// head
				trace( list[ 0 ].toXMLString() );
			}
		}
		
	}
	
}