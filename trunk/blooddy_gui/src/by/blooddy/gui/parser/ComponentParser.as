////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.parser {

	import by.blooddy.code.css.CSSManager;
	import by.blooddy.code.css.CSSParser;
	import by.blooddy.code.errors.ParserError;
	import by.blooddy.core.blooddy;
	import by.blooddy.core.events.net.loading.LoaderEvent;
	import by.blooddy.core.managers.resource.IResourceManager;
	import by.blooddy.core.managers.resource.ResourceManager;
	import by.blooddy.core.net.MIME;
	import by.blooddy.core.net.loading.ILoadable;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;

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
	public class ComponentParser extends EventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _STYLES:Object = new Object();

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
		private var _resourceManager:IResourceManager;

		/**
		 * @private
		 */
		private var _cssManager:CSSManager;
		
		/**
		 * @private
		 */
		private const _list:Vector.<StyleAsset> = new Vector.<StyleAsset>();
		
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

			this._resourceManager = manager || ResourceManager.manager;
			this._cssManager = CSSManager.getManager( manager );

			this._content = null;
			this._errors = new Vector.<Error>();

			if ( xml.name() != _COMPONENT_NAME ) throw new ParserError();

			this._content = new ComponentDefinition();
			
			var list:XMLList;
			// head
			list = xml.blooddy::head.blooddy::*;
			if ( list.length() > 0 ) {
				
				var name:String;
				var controllerName:String;

				var i:int;
				var href:String;
				var rel:String;
				var type:String;
				var asset:StyleAsset;

				var content:String;
				var loader:ILoadable;
				var parser:CSSParser;
				
				var hash:Object = new Object();
				
				for each ( var x:XML in list ) {
					switch ( x.localName() ) {

						case 'meta':
							switch ( x.@name.toString().toLowerCase() ) {
								case 'name':		name = x.@content.toString();
								case 'controller':	controllerName = x.@content.toString();
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
											if ( href in _STYLES ) {
												asset = _STYLES[ href ];
											} else {
												asset = new StyleAsset();
												if ( this._cssManager.hasDefinition( href ) ) {
													asset.definition = this._cssManager.getDefinition( href );
												} else {
													asset.loader = this._cssManager.loadDefinition( href );
												}
												_STYLES[ href ] = asset;
											}
											if ( asset.loader ) {
												
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
							break;

					}
					trace( x.toXMLString() );
				}

				/*
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
				// перебираем ссылки
				list2 = list.blooddy::link;
				var i:int;
				var href:String;
				var rel:String;
				var type:String;
				var css:Vector.<String> = new Vector.<String>();
				for each ( var x:XML in list2 ) {
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
								i = css.indexOf( href );
								if ( i >= 0 ) css.splice( i, 1 );
								css.push( href );
								break;
							case 'preload':
							case '':
								if ( this._content.preload.indexOf( href ) < 0 ) {
									this._content.preload.push( href );
								}
								break;
						}
					}
				}
				
				trace( list2.toXMLString() );*/
			}
			// body
			list = xml.blooddy::body;
			if ( list.length() > 0 ) {
				//trace( list[ 0 ].toXMLString() );
			}

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

	public function StyleAsset() {
		super();
	}

	public var loader:ILoadable;

	public var definition:CSSDefinition;

}