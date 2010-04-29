////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.parser {

	import by.blooddy.code.css.CSSManager;
	import by.blooddy.code.css.CSSParser;
	import by.blooddy.code.errors.ParserError;
	import by.blooddy.code.net.AbstractLoadableParser;
	import by.blooddy.core.blooddy;
	import by.blooddy.core.events.net.loading.LoaderEvent;
	import by.blooddy.core.managers.resource.IResourceManager;
	import by.blooddy.core.managers.resource.ResourceManager;
	import by.blooddy.core.net.MIME;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.net.loading.LoaderDispatcher;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.Dictionary;

	//--------------------------------------
	//  Implements events: ILoadable
	//--------------------------------------

	[Event( name="open", type="flash.events.Event" )]

	[Event( name="progress", type="flash.events.ProgressEvent" )]

	[Event( name="complete", type="flash.events.Event" )]

	/**
	 * какая-то ошибка при исполнении.
	 */
	[Event( name="asyncError", type="flash.events.AsyncErrorEvent" )]	

	[Event( name="loaderInit", type="by.blooddy.core.events.net.loading.LoaderEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.04.2010 17:58:08
	 */
	public class ComponentParser extends AbstractLoadableParser {

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
		public function ComponentParser(manager:IResourceManager=null) {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _source:XML;
		
		/**
		 * @private
		 */
		private var _resourceManager:IResourceManager;

		/**
		 * @private
		 */
		private var _cssManager:CSSManager;
		
		/**
		 * @private
		 */
		private var _loader:ILoadable;
		
		/**
		 * @private
		 */
		private const _list:Vector.<StyleAsset> = new Vector.<StyleAsset>();
		
		/**
		 * @private
		 */
		private const _hash:Dictionary = new Dictionary();
		
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

		/**
		 * @private
		 */
		private var _errors:Vector.<Error>;
		
		public function get errors():Vector.<Error> {
			return this._errors;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function parse(xml:XML, manager:IResourceManager=null):void {

			super.start();

			this._source = xml;
			this._resourceManager = manager || ResourceManager.manager;
			this._cssManager = CSSManager.getManager( manager );

			this._content = null;
			this._errors = new Vector.<Error>();

		}

		protected override function $action():Boolean {
			
			if ( this._source.name() != _COMPONENT_NAME ) throw new ParserError();

			this._content = new ComponentDefinition();
			
			var list:XMLList;
			// head
			list = this._source.blooddy::head.blooddy::*;
			if ( list.length() > 0 ) {
				
				var name:String;
				var controllerName:String;

				var i:int;
				var href:String;
				var rel:String;
				var type:String;

				var asset:StyleAsset;
				var loader:ILoadable;
				var parser:CSSParser;
//				var loaderDispatcher:LoaderDispatcher;
				
				var hash:Object = new Object();
				
				for each ( var x:XML in list ) {
					switch ( x.localName() ) {

						case 'meta':
							switch ( x.@name.toString().toLowerCase() ) {
								case 'name':		name = x.@content.toString();			break;
								case 'controller':	controllerName = x.@content.toString();	break;
							}
							break;

						case 'link':
							href = x.@href.toString();
							if ( href ) {
								rel = x.@rel.toString().toLowerCase();
								if ( !rel ) {
									type = x.@type.toString().toLowerCase();
									if ( !type ) type = MIME.analyseURL( href );
									if ( type == MIME.CSS ) {
										rel = 'stylesheet';
									}
								}
								switch ( rel ) {
									case 'stylesheet':
										if ( href in hash ) {
											asset = hash[ href ];
											i = this._list.lastIndexOf( asset );
											if ( i >= 0 ) this._list.splice( i, 1 );
										} else {
											asset = new StyleAsset( href );
											if ( this._cssManager.hasDefinition( href ) ) {
												asset.definition = this._cssManager.getDefinition( href );
											} else {
												loader = this._cssManager.loadDefinition( href );
												loader.addEventListener( Event.COMPLETE,					this.handler_loader_complete );
												loader.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_loader_complete );
												loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_loader_complete );
												this._hash[ loader ] = asset;
												super.addLoader( loader );
											}
											hash[ href ] = asset;
										}
										this._list.push( asset );
										break;
									case 'preload':
									case '':
										if ( this._content.preload.indexOf( href ) < 0 ) {
											this._content.preload.push( href );
										}
										break;
								}
							}
							break;

						case 'style':
							asset = new StyleAsset();
							parser = new CSSParser();
							parser.addEventListener( Event.COMPLETE,		this.handler_parser_complete );
							parser.addEventListener( IOErrorEvent.IO_ERROR,	this.handler_parser_complete );
							parser.parse( x.text().toString(), this._cssManager );
							this._hash[ parser ] = asset;
							this._list.push( asset );
							super.addLoader( parser );
							break;

					}
//					if ( loader ) {
//
//						if ( loaderDispatcher ) {
//							loaderDispatcher.addLoaderListener( loader );
//						} else if ( this._loader ) {
//							loaderDispatcher = new LoaderDispatcher();
//							loaderDispatcher.addLoaderListener( this._loader );
//							loaderDispatcher.addLoaderListener( loader );
//							this._loader = loaderDispatcher;
//						} else {
//							this._loader = loader;
//						}
//						loader = null;
//
//					}
					
					trace( x.toXMLString() );
				}

			}
			// body
			list = this._source.blooddy::body;
			if ( list.length() > 0 ) {
				//trace( list[ 0 ].toXMLString() );
			}

			if ( this._loader ) {
				
			} else {
				
			}

			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_loader_complete(event:Event):void {
			var loader:ILoadable = event.target as ILoadable;
			loader.removeEventListener( Event.COMPLETE,						this.handler_loader_complete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_loader_complete );
			loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_loader_complete );
			var asset:StyleAsset = this._hash[ loader ];
			asset.definition = this._cssManager.getDefinition( asset.href );
			delete this._hash[ loader ];
		}

		/**
		 * @private
		 */
		private function handler_parser_complete(event:Event):void {
			var parser:CSSParser = event.target as CSSParser;
			parser.removeEventListener( Event.COMPLETE,			this.handler_loader_complete );
			parser.removeEventListener( IOErrorEvent.IO_ERROR,	this.handler_loader_complete );
			var asset:StyleAsset = this._hash[ parser ];
			asset.definition = parser.content;
			delete this._hash[ parser ];
		}
		
	}
	
}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.code.css.CSSParser;
import by.blooddy.code.css.definition.CSSDefinition;
import by.blooddy.core.net.loading.ILoadable;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: StyleAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class StyleAsset {

	public function StyleAsset(href:String=null) {
		super();
		this.href = href;
	}

	public var href:String;

	public var definition:CSSDefinition;

}