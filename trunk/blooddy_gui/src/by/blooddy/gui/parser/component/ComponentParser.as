////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.parser.component {

	import by.blooddy.code.css.CSSManager;
	import by.blooddy.code.css.CSSParser;
	import by.blooddy.code.css.definition.CSSMedia;
	import by.blooddy.code.css.definition.CSSRule;
	import by.blooddy.code.css.definition.values.CSSValue;
	import by.blooddy.code.css.definition.values.CollectionValue;
	import by.blooddy.code.css.definition.values.ComplexValue;
	import by.blooddy.code.errors.ParserError;
	import by.blooddy.code.net.AbstractLoadableParser;
	import by.blooddy.core.blooddy;
	import by.blooddy.core.events.net.loading.LoaderEvent;
	import by.blooddy.core.managers.resource.IResourceManager;
	import by.blooddy.core.managers.resource.ResourceManager;
	import by.blooddy.core.net.MIME;
	import by.blooddy.core.net.loading.IProcessable;
	import by.blooddy.gui.parser.css.ComplexValueFactory;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.utils.Dictionary;

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	[Event( name="open", type="flash.events.Event" )]

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
			this._cssManager.addEventListener( LoaderEvent.LOADER_INIT, trace );

			this._content = null;
			this._errors = new Vector.<Error>();

		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		protected override function onParse():Boolean {
			
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
				var mediaName:String;

				var asset:StyleAsset;
				var loader:IProcessable;
				var parser:CSSParser;
				
				var key:String;
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
										mediaName = x.@media.toString();
										key = mediaName + '\x00' + href;
										if ( key in hash ) {
											asset = hash[ key ];
											i = this._list.lastIndexOf( asset );
											if ( i >= 0 ) this._list.splice( i, 1 );
										} else {
											asset = new StyleAsset( href );
											if ( mediaName ) {
												asset.mediaName = mediaName;
											}
											if ( this._cssManager.hasDefinition( href ) ) {
												asset.medias = this._cssManager.getDefinition( href );
											} else {
												loader = this._cssManager.loadDefinition( href );
												loader.addEventListener( Event.COMPLETE,	this.handler_loader_complete );
												loader.addEventListener( ErrorEvent.ERROR,	this.handler_loader_complete );
												this._hash[ loader ] = asset;
												super.addLoader( loader );
											}
											hash[ key ] = asset;
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
							type = x.@type.toString().toLowerCase();
							if ( !type || type == MIME.CSS ) {
								mediaName = x.@media.toString();
								asset = new StyleAsset();
								if ( mediaName ) asset.mediaName = mediaName;
								parser = new CSSParser();
								parser.addEventListener( Event.COMPLETE,	this.handler_parser_complete );
								parser.addEventListener( ErrorEvent.ERROR,	this.handler_parser_complete );
								parser.parse( x.text().toString(), this._cssManager );
								this._hash[ parser ] = asset;
								this._list.push( asset );
								super.addLoader( parser );
							}
							break;

					}
				}

			}
			// body
			list = this._source.blooddy::body;
			if ( list.length() > 0 ) {
				//trace( list[ 0 ].toXMLString() );
			}

			// если всё загружено, то конец
			if ( super.loaded ) {
				this.onLoad();
			}

			return true;
		}

		protected override function onLoad():void {
			this._source = null;

			this._cssManager.removeEventListener( LoaderEvent.LOADER_INIT, super.dispatchEvent );
			this._cssManager = null;
			this._resourceManager = null;

			var asset:StyleAsset;
			var media:CSSMedia;
			var rule:CSSRule;
			var n:String;
			var i:uint, l:uint;
			var values:Vector.<CSSValue>;
			var value:CSSValue;
			for each ( asset in this._list ) {
				for each ( media in asset.medias ) {
					for each ( rule in media.rules ) {
						for ( n in rule.declarations ) {
							value = rule.declarations[ n ];
							if ( value is ComplexValue ) {
								rule.declarations[ n ] = ComplexValueFactory.getValue( value as ComplexValue );
							} else if ( value is CollectionValue ) {
								values = ( value as CollectionValue ).values;
								l = values.length;
								for ( i=0; i<l; i++ ) {
									value = values[ i ];
									if ( value is ComplexValue ) {
										values[ i ] = ComplexValueFactory.getValue( value as ComplexValue );
									}
								}
							}
						}
					}
				}
				trace( asset.medias );
			}

			super.stop();
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
			var loader:IProcessable = event.target as IProcessable;
			loader.removeEventListener( Event.COMPLETE,		this.handler_loader_complete );
			loader.removeEventListener( ErrorEvent.ERROR,	this.handler_loader_complete );
			var asset:StyleAsset = this._hash[ loader ];
			asset.medias = this._cssManager.getDefinition( asset.href );
			delete this._hash[ loader ];
		}

		/**
		 * @private
		 */
		private function handler_parser_complete(event:Event):void {
			var parser:CSSParser = event.target as CSSParser;
			parser.removeEventListener( Event.COMPLETE,		this.handler_loader_complete );
			parser.removeEventListener( ErrorEvent.ERROR,	this.handler_loader_complete );
			var asset:StyleAsset = this._hash[ parser ];
			asset.medias = parser.content;
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
import by.blooddy.code.css.definition.CSSMedia;
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

	public var medias:Vector.<CSSMedia>;

	public var mediaName:String;

	public var loader:ILoadable;

}