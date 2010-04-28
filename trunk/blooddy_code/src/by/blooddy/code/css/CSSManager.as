////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css {

	import by.blooddy.code.css.definition.CSSDefinition;
	import by.blooddy.core.events.net.loading.LoaderEvent;
	import by.blooddy.core.managers.resource.IResourceManager;
	import by.blooddy.core.managers.resource.ResourceManager;
	import by.blooddy.core.net.loading.ILoadable;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.Dictionary;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	[Event( name="loaderInit", type="by.blooddy.core.events.net.loading.LoaderEvent" )]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.04.2010 22:40:36
	 */
	public class CSSManager extends EventDispatcher {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _HASH:Dictionary = new Dictionary( true );

		/**
		 * @private
		 */
		private static var _privateCall:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function getManager(manager:IResourceManager=null):CSSManager {
			if ( !manager ) manager = ResourceManager.manager;
			var result:CSSManager = _HASH[ manager ];
			if ( !result ) {
				_privateCall = true;
				_HASH[ manager ] = result = new CSSManager( manager );
				_privateCall = false;
			}
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Constructor
		 */
		public function CSSManager(manager:IResourceManager) {
			super();
			if ( !_privateCall ) throw new ArgumentError();
			this._manager = manager;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _manager:IResourceManager;

		/**
		 * @private
		 */
		private const _definitions:Object = new Object();

		/**
		 * @private
		 */
		private const _loaders:Object = new Object();
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function hasDefinition(url:String):Boolean {
			return url in this._definitions;
		}

		public function getDefinition(url:String):CSSDefinition {
			return this._definitions[ url ];
		}

		public function loadDefinition(url:String):ILoadable {
			var result:CSSLoader = this._loaders[ url ];
			if ( !result ) {
				this._loaders[ url ] = result = new CSSLoader( this, this._manager, url );
				result.addEventListener( Event.COMPLETE,					this.handler_complete, false, int.MAX_VALUE );
				result.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_complete, false, int.MAX_VALUE );
				result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_complete, false, int.MAX_VALUE );
				result.addEventListener( LoaderEvent.LOADER_INIT,			super.dispatchEvent );
			}
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			var loader:CSSLoader = event.target as CSSLoader;
			loader.removeEventListener( Event.COMPLETE,						this.handler_complete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_complete );
			loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_complete );
			loader.removeEventListener( LoaderEvent.LOADER_INIT,			super.dispatchEvent );
			this._definitions[ loader.$url ] = loader.$content;
		}

	}
	
}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.code.css.CSSManager;
import by.blooddy.code.css.CSSParser;
import by.blooddy.code.css.definition.CSSDefinition;
import by.blooddy.core.events.net.loading.LoaderEvent;
import by.blooddy.core.managers.resource.IResourceManager;
import by.blooddy.core.net.loading.ILoadable;
import by.blooddy.core.net.loading.LoaderPriority;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: CSSLoader
//
////////////////////////////////////////////////////////////////////////////////

//--------------------------------------
//  Implements events
//--------------------------------------

[Event( name="progress", type="flash.events.ProgressEvent" )]
[Event( name="complete", type="flash.events.Event" )]
[Event( name="ioError", type="flash.events.IOErrorEvent" )]
[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]

//--------------------------------------
//  Events
//--------------------------------------

[Event( name="loaderInit", type="by.blooddy.core.events.net.loading.LoaderEvent" )]

/**
 * @private
 */
internal final class CSSLoader extends EventDispatcher implements ILoadable {

	public function CSSLoader(cssManager:CSSManager, resourceManager:IResourceManager, url:String) {
		super();
		this._cssManager = cssManager;
		this._resourceManager = resourceManager;
		this.$url = url;
		this.createLoader();
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _cssManager:CSSManager;

	/**
	 * @private
	 */
	private var _resourceManager:IResourceManager;
	
	/**
	 * @private
	 */
	private var _loader:ILoadable;
	
	/**
	 * @private
	 */
	private var _parser:CSSParser;
	
	//--------------------------------------------------------------------------
	//
	//  Internal properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	internal var $url:String;
	
	internal var $content:CSSDefinition;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public function get progress():Number {
		return ( this._loader.progress + ( this._parser ? this._parser.progress : 0 ) ) / 2;
	}
	
	/**
	 * @private
	 */
	public function get loaded():Boolean {
		return this._parser && this._parser.loaded;
	}

	/**
	 * @private
	 */
	public function get bytesLoaded():uint {
		return this._loader.bytesLoaded + ( this._parser ? this._parser.bytesLoaded : 0 );
	}

	/**
	 * @private
	 */
	public function get bytesTotal():uint {
		return this._loader.bytesTotal + ( this._parser ? this._parser.bytesTotal : 0 );
	}

	//--------------------------------------------------------------------------
	//
	//  Private methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function createLoader():void {
		this._loader = this._resourceManager.loadResourceBundle( this.$url, LoaderPriority.HIGHEST );
		if ( this._loader.loaded ) {
			this._loader = null;
			this.createParser();
		} else {
			this._loader.addEventListener( Event.COMPLETE,						this.handler_loader_complete, false, int.MAX_VALUE );
			this._loader.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_loader_error, false, int.MAX_VALUE );
			this._loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_loader_error, false, int.MAX_VALUE );
		}
	}

	/**
	 * @private
	 */
	private function clearLoader():void {
		this._loader.removeEventListener( Event.COMPLETE,						this.handler_loader_complete );
		this._loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_loader_error );
		this._loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_loader_error );
		this._loader = null;
	}

	/**
	 * @private
	 */
	private function createParser():void {
		var data:String = this._resourceManager.getResource( this.$url ) as String;
		if ( data ) {
			this._parser = new CSSParser();
			this._parser.addEventListener( Event.COMPLETE,			this.handler_loader_complete );
			this._parser.addEventListener( IOErrorEvent.IO_ERROR,	this.handler_loader_error );
			this._parser.addEventListener( LoaderEvent.LOADER_INIT,	super.dispatchEvent );
			this._parser.parse( data, this._cssManager );
		} else {
			super.dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR ) );
		}
	}

	/**
	 * @private
	 */
	private function clearParser():void {
		this._parser.removeEventListener( Event.COMPLETE,			this.handler_parser_complete );
		this._parser.removeEventListener( IOErrorEvent.IO_ERROR,	this.handler_parser_error );
		this._parser.removeEventListener( LoaderEvent.LOADER_INIT,	super.dispatchEvent );
		this._parser = null;
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
		this.clearLoader();
		this.createParser();
	}

	/**
	 * @private
	 */
	private function handler_loader_error(event:ErrorEvent):void {
		this.clearLoader();
		super.dispatchEvent( event );
	}

	/**
	 * @private
	 */
	private function handler_parser_complete(event:Event):void {
		this.$content = this._parser.content;
		this.clearParser();
		if ( super.hasEventListener( ProgressEvent.PROGRESS ) ) {
			super.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this.bytesLoaded, this.bytesTotal ) );
		}
		super.dispatchEvent( event );
	}
	
	/**
	 * @private
	 */
	private function handler_parser_error(event:ErrorEvent):void {
		this.clearParser();
		super.dispatchEvent( event );
	}
	
}