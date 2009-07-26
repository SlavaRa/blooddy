package by.blooddy.core.managers {

	import by.blooddy.core.events.RemoteModuleEvent;
	
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	[Event(name="init", type="by.blooddy.core.events.RemoteModuleEvent")]
	[Event(name="unload", type="by.blooddy.core.events.RemoteModuleEvent")]

	public class RemoteModuleManager extends EventDispatcher implements IRemoteModuleManager {

		private static const _HASH:Dictionary = new Dictionary( true );

		private static const _CURRENT_DOMAIN:ApplicationDomain = ApplicationDomain.currentDomain; // СУКА!

		public function RemoteModuleManager(applicationDomain:ApplicationDomain=null) {
			super();

			if ( !applicationDomain ) applicationDomain = _CURRENT_DOMAIN;

			this._instance = _HASH[ applicationDomain ] as RemoteModuleManagerInstance;
			if ( !this._instance ) {
				_HASH[ applicationDomain ] = this._instance = new RemoteModuleManagerInstance( applicationDomain );
			}

			this._instance.addEventListener( RemoteModuleEvent.INIT, super.dispatchEvent, false, int.MAX_VALUE, true );
			this._instance.addEventListener( RemoteModuleEvent.UNLOAD, super.dispatchEvent, false, int.MAX_VALUE, true );
		}

		private var _instance:RemoteModuleManagerInstance;

		public function get applicationDomain():ApplicationDomain {
			return this._instance.applicationDomain;
		}

		public function hasDefinition(name:String):Boolean {
			return this._instance.hasDefinition( name );
		}

		public function getDefinition(name:String):Object {
			return this._instance.getDefinition( name );
		}

		public function load(request:URLRequest, applicationDomain:ApplicationDomain=null):void {
			this._instance.load( request, applicationDomain );
		}

		public function loadBytes(bytes:ByteArray, applicationDomain:ApplicationDomain=null):void {
			this._instance.loadBytes( bytes, applicationDomain );
		}

		public function hasModule(id:String):Boolean {
			return this._instance.hasModule( id );
		}

		public function unload():void {
			this._instance.unload();
		}

		public function unloadModule(id:String):void {
			this._instance.unloadModule( id );
		}

	}

}

import flash.events.EventDispatcher;
import flash.system.LoaderContext;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;
import by.blooddy.core.net.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import by.blooddy.core.events.RemoteModuleEvent;
import by.blooddy.core.managers.IRemoteModule;
import flash.display.LoaderInfo;
import flash.net.URLRequest;
import by.blooddy.core.managers.IRemoteModuleManager;
import by.blooddy.core.net.MIME;

internal final class RemoteModuleManagerInstance extends EventDispatcher implements IRemoteModuleManager {

	public function RemoteModuleManagerInstance(applicationDomain:ApplicationDomain) {
		super();
		this._applicationDomain = applicationDomain;
	}

	private const _loaders:Array = new Array();

	private var _applicationDomain:ApplicationDomain;

	public function get applicationDomain():ApplicationDomain {
		return this._applicationDomain;
	}

	public function hasDefinition(name:String):Boolean {
		var l:uint = this._loaders.length;
		var result:Object;
		for ( var i:uint = 0; i<l; i++ ) {
			if ( ( this._loaders[i] as ModuleLoader ).loaderInfo.applicationDomain.hasDefinition( name ) ) {
				return true;
			}
		}
		return false;
	}

	public function getDefinition(name:String):Object {
		var l:uint = this._loaders.length;
		var app:ApplicationDomain, result:Object;
		for ( var i:uint = 0; i<l; i++ ) {
			app = ( this._loaders[i] as ModuleLoader ).loaderInfo.applicationDomain;
			if ( app.hasDefinition( name ) ) {
				result = app.getDefinition( name );
				if ( result ) return result;
			}
		}
		return null;
	}

	public function load(request:URLRequest, applicationDomain:ApplicationDomain=null):void {
		var loader:ModuleLoader = new ModuleLoader();
		loader.addEventListener( Event.COMPLETE, this.handler_complete );
		loader.addEventListener( Event.INIT, this.handler_init );
		loader.addEventListener( IOErrorEvent.IO_ERROR, this.handler_error );
		loader.loaderContext = new LoaderContext( false, applicationDomain || new ApplicationDomain( this._applicationDomain ) );
		loader.load( request );
	}

	public function loadBytes(bytes:ByteArray, applicationDomain:ApplicationDomain=null):void {
		var loader:ModuleLoader = new ModuleLoader();
		loader.addEventListener( Event.COMPLETE, this.handler_complete );
		loader.addEventListener( Event.INIT, this.handler_init );
		loader.addEventListener( IOErrorEvent.IO_ERROR, this.handler_error );
		loader.loaderContext = new LoaderContext( false, applicationDomain || new ApplicationDomain( this._applicationDomain ) );
		loader.loadBytes( bytes );
	}

	public function unload():void {
		var loader:ModuleLoader;
		var id:String;
		while ( this._loaders.length ) {
			loader = this._loaders.pop() as ModuleLoader;
			id = loader.id;
			loader.unload();
			super.dispatchEvent( new RemoteModuleEvent( RemoteModuleEvent.UNLOAD, false, false, id ) );
		}
	}

	public function unloadModule(id:String):void {
		if (!id) return;
		for each ( var module:ModuleLoader in this._loaders ) {
			if ( module.id == id ) {
				module.unload();
				this._loaders.splice( this._loaders.indexOf( module ), 1 );
				super.dispatchEvent( new RemoteModuleEvent( RemoteModuleEvent.UNLOAD, false, false, id ) );
				return;
			}
		}
		throw new ArgumentError(); // TODO: описать ошибку
	}

	public function hasModule(id:String):Boolean {
		for each ( var module:ModuleLoader in this._loaders ) {
			if ( module.id == id ) return true;
		}
		return false;
	}

	private function handler_init(event:Event):void {
		var loader:ModuleLoader = event.target as ModuleLoader;
		loader.removeEventListener( Event.INIT, this.handler_init );
		if ( loader.contentType != MIME.FLASH || !( loader.content is IRemoteModule ) ) {
			loader.removeEventListener( Event.COMPLETE, this.handler_complete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR, this.handler_error );
			loader.close();
			loader.unload();
		}
	}

	private function handler_complete(event:Event):void {
		var loader:ModuleLoader = event.target as ModuleLoader;
		loader.removeEventListener( Event.COMPLETE, this.handler_complete );
		loader.removeEventListener( IOErrorEvent.IO_ERROR, this.handler_error );
		if ( loader && loader.id ) {
			this._loaders.push( loader );
			super.dispatchEvent( new RemoteModuleEvent( RemoteModuleEvent.INIT, false, false, loader.id ) );
		} else {
			loader.unload();
		}
	}

	private function handler_error(event:IOErrorEvent):void {
		var loader:Loader = event.target as Loader;
		loader.removeEventListener( Event.COMPLETE, this.handler_complete );
		loader.removeEventListener( Event.INIT, this.handler_init );
		loader.removeEventListener( IOErrorEvent.IO_ERROR, this.handler_error );
	}

}

internal final class ModuleLoader extends Loader {

	public function ModuleLoader() {
		super();
	}

	public function get id():String {
		var module:IRemoteModule = super.content as IRemoteModule;
		if ( module ) return module.id;
		return null;
	}

	public override function unload():void {
		var module:IRemoteModule = super.content as IRemoteModule;
		if ( module ) {
			module.clear();
		}
		super.unload();
	}

}