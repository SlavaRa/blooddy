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
	import by.blooddy.core.utils.ClassAlias;
	
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
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
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
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _content:ComponentDefinition;

		public function get content():ComponentDefinition {
			return this._content;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function parse(xml:XML):void {

			this._content = null;

			if ( xml.name() != _COMPONENT_NAME ) throw new ParserError();

			this._content = new ComponentDefinition();
			
			var list:XMLList;
			
			// head
			list = xml.blooddy::head;
			if ( list.length() > 0 ) {
				var list2:XMLList;
				var list3:XMLList;
				// meta
				list2 = list.blooddy::meta;
				if ( list2.length() ) {
					var l:uint;
					// name
					list3 = list2.( @name.toLowerCase() == 'name' );
					l = list3.length();
					if ( l > 0 ) this._content.name = list3[ l - 1 ].@content.toString();
					// controller
					list3 = list2.( @name.toLowerCase() == 'controller' );
					l = list3.length();
					if ( l > 0 ) {
						var controllerName:String = list3[ l - 1 ].@content.toString();
						if ( controllerName ) {
							this._content.controller = ClassAlias.getClass( controllerName );
						}
					}
				}
				list2 = list.blooddy::link;
				trace( list2.toXMLString() );
			}
			// body
			list = xml.blooddy::body;
			if ( list.length() > 0 ) {
				//trace( list[ 0 ].toXMLString() );
			}

		}
		
	}
	
}