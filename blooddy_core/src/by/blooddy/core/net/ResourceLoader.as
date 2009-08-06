////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.managers.IResourceBundle;
	import by.blooddy.core.managers.ResourceManager;
	import by.blooddy.core.utils.DefinitionFinder;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * Загружает свф и воспринимает его как ресурсы.
	 * Если загружается не свф, то обижаемся на него и просим убираться во свояси.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					resourceloader, resource, loader
	 */
	public class ResourceLoader extends HeuristicLoader implements IResourceBundle {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _MANAGER:ResourceManager = new ResourceManager();

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function ResourceLoader(request:URLRequest=null, loaderContext:LoaderContext=null) {
			super( request, loaderContext );
			super.addEventListener( Event.INIT, this.handler_init, false, int.MAX_VALUE, true );
			super.addEventListener( Event.COMPLETE, this.handler_complete, false, int.MAX_VALUE, true );
			super.addEventListener( ProgressEvent.PROGRESS, this.handler_progress, false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _resources:Object = new Object();

		/**
		 * @private
		 */
		private const _domains:Object = new Object();

		private var _hasDomain:Boolean = false;

		/**
		 * @private
		 */
		private var _definitions:DefinitionFinder;

		/**
		 * @private
		 */
		private var _loaders:uint = 0;

		/**
		 * @private
		 */
		private var _complete:Boolean = false;

		/**
		 * @private
		 */
		private var _progress:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Implements properties: IResourceBundle
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function get name():String {
			return super.url;
		}

		/**
		 * @inheritDoc
		 */
		public function get empty():Boolean {
			return !this._complete;
		}

		public override function get loaded():Boolean {
			return ( super.loaded || this._complete ) && this._loaders == 0;
		}
		
		/**
		 * @private
		 */
		private var _bytesLoaded:uint = 0;
		
		public override function get bytesLoaded():uint {
			return this._bytesLoaded;			
		}
		
		/**
		 * @private
		 */
		private var _bytesTotal:uint = 0;
		
		public override function get bytesTotal():uint {
			return this._bytesTotal;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IResourceBundle
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function getResource(name:String):* {
			if ( !name ) return super.content;
			else if ( name in this._resources ) {
				return _MANAGER.getResource( this._resources[ name ], name );
			} else if ( super.loaderInfo && super.loaderInfo.applicationDomain && super.loaderInfo.applicationDomain.hasDefinition( name ) ) {
				return super.loaderInfo.applicationDomain.getDefinition( name );
			} else if ( super.content && name in super.content ) {
				return super.content[ name ];
			}
			return null;
		}

		/**
		 * @inheritDoc
		 */
		public function hasResource(name:String):Boolean {
			return (
				this._complete && (
					!name ||
					( ( name in this._resources ) && _MANAGER.hasResource( this._resources[ name ], name ) ) ||
					( super.loaderInfo && super.loaderInfo.applicationDomain && super.loaderInfo.applicationDomain.hasDefinition( name ) ) ||
					( super.content && name in super.content )
				)
			);
		}

		/**
		 * @inheritDoc
		 */
		public function getResources():Array {
			if ( super.contentType != MIME.FLASH || !this._definitions ) return new Array();
			return this._definitions.getDefinitionNames();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: HeuristicLoader
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function unload():void {
			this._complete = false;
			super.unload();
			this.$unload();
		}

		/**
		 * @private
		 */
		public override function close():void {
			this._complete = false;
			super.close();
			this.$unload();
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function $unload():void {
			_MANAGER.removeEventListener( DomainEvent.DOMAIN_UNLOAD, this.handler_unload );
			for ( var domain:String in this._domains ) {
				if ( _MANAGER.dispatchEvent( new DomainEvent( DomainEvent.DOMAIN_UNLOAD, false, true, domain ) ) ) { // все разрешили
					_MANAGER.removeResourceBundle( domain );
					delete this._domains[ domain ];
				}
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_init(event:Event):void {
			if ( super.contentType == MIME.FLASH ) {
				if ( !this._definitions ) {
					if ( super.loaderInfo ) {
						this._definitions = new DefinitionFinder( super.loaderInfo.bytes );
					} else {
						throw new ArgumentError();
					}
				}
				var data:String = this._definitions.getMetadata();
				if ( data ) {
					var xml:XML;
					try {
						xml = new XML( data );
					} catch ( e:Error ) {
					}
					if ( xml ) {
						var loader:ILoadable;
						var library:XML, libraries:XMLList = xml.rdf::Description.shared::library;
						var list:XMLList;
						var domain:String;
						var definitions:Array;
						var lm:String, name:String;
						for each ( library in libraries ) {
							list = library.shared::domain;
							if ( list.length() > 0 ) {
								domain = list[0].@rdf::resource.toString();
								if ( domain ) {
									list = library.shared::definition;
									if ( list.length() > 0 ) {
										xml = list[0];
										if ( xml.hasSimpleContent() ) {
											name = xml[0].toString();
											if ( !( name in this._resources ) ) {
												this._resources[ name ] = domain; // добавляем
											}
										} else {
											list = xml.*.( namespace() == rdf && ( lm = localName() ) && ( lm == "Bag" || lm == "Seq" || lm == "Alt" ) ).rdf::li;
											if ( list.length() > 0 ) {
												for each ( xml in list ) {
													if ( xml.hasSimpleContent() ) {
														name = xml[0].toString();
														if ( !( name in this._resources ) ) {
															this._resources[ name ] = domain; // добавляем
														}
													}
												}
											}
										}
									}
									this._hasDomain = true;
									loader = _MANAGER.loadResourceBundle( domain, LoaderPriority.HIGHEST );
									this._domains[ domain ] = loader;
									if ( !loader.loaded ) {
										loader.addEventListener( Event.COMPLETE,					this.handler_module_complete );
										loader.addEventListener( ProgressEvent.PROGRESS, 			this.handler_module_progress );
										loader.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_module_complete );
										loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_module_complete );
										this._loaders++;
									}
								}
							}
						}
						if ( this._hasDomain ) { // есть у нас перенаправления
							_MANAGER.addEventListener( DomainEvent.DOMAIN_UNLOAD, this.handler_unload );
						}
					}
				}
			}
		}
		
		/**
		 * @private
		 */
		private function handler_progress(event:ProgressEvent):void {
			if ( this._hasDomain ) {
				if ( !this._progress ) {
					event.stopImmediatePropagation();
					this.handler_module_progress( event );
				}
			} else {
				this._bytesLoaded = event.bytesLoaded;
				this._bytesTotal = event.bytesTotal;		
			}
		}

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			this._complete = true;
			if ( this._loaders > 0 ) {
				event.stopImmediatePropagation();
			}
		}

		/**
		 * @private
		 */
		private function handler_module_complete(event:Event):void {
			this._loaders--;
			var loader:ILoadable = event.target as ILoadable;
			loader.removeEventListener( Event.COMPLETE,						this.handler_module_complete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_module_complete );
			loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_module_complete );

			if ( this._loaders == 0 && this._complete ) {
				super.dispatchEvent( new Event( Event.COMPLETE ) );
			}
		}
		
		/**
		 * @private
		 */
		private function handler_module_progress(event:ProgressEvent):void {
			var bytesLoaded:uint = super.bytesLoaded;
			var bytesTotal:uint = super.bytesTotal;
			
			for each ( var loader:ILoadable in this._domains ) {
				if (loader.bytesLoaded > 0 && loader.bytesTotal > 0) {
					bytesLoaded += loader.bytesLoaded;
					bytesTotal += loader.bytesTotal;
				}
			}
			
			this._bytesLoaded = bytesLoaded;
			this._bytesTotal = bytesTotal;
			this._progress = true;
			super.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, this._bytesLoaded, this._bytesTotal));
			this._progress = false;
		}

		/**
		 * @private
		 */
		private function handler_unload(event:DomainEvent):void {
			if ( event.domain in this._domains ) { // у нас эта либа используется. надо
				event.preventDefault();
				event.stopImmediatePropagation();
			}
		}

	}

}

import by.blooddy.core.utils.ClassUtils;

import flash.events.Event;

/**
 * @private
 */
internal const rdf:Namespace = new Namespace( 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' );

/**
 * @private
 */
internal const shared:Namespace = new Namespace( 'http://timezero.com/library/shared/' );

/**
 * @private
 */
internal final class DomainEvent extends Event {

	/**
	 * @private
	 */
	public static const DOMAIN_UNLOAD:String = 'domainUnload';

	/**
	 * @private
	 */
	public function DomainEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, domain:String=null) {
		super( type, bubbles, cancelable );
		this.domain = domain;
	}

	/**
	 * @private
	 */
	public var domain:String;

	/**
	 * @private
	 */
	public override function clone():Event {
		return new DomainEvent( super.type, super.bubbles, super.cancelable, this.domain );
	}

	/**
	 * @private
	 */
	public override function toString():String {
		return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable', 'domain' );
	}

}