////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.errors.getErrorMessage;
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	//--------------------------------------
	//  Implements events: ILoadable
	//--------------------------------------

	/**
	 * @copy					by.blooddy.core.net.ILoadable#complete
	 */
	[Event(name="complete", type="flash.events.Event")]

	/**
	 * @copy					by.blooddy.core.net.ILoadable#ioError
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")]

	/**
	 * @copy					by.blooddy.core.net.ILoadable#open
	 */
	[Event(name="open", type="flash.events.Event")]

	/**
	 * @copy					by.blooddy.core.net.ILoadable#progress
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")]

	//--------------------------------------
	//  Implements events: ILoader
	//--------------------------------------

	/**
	 * @copy					by.blooddy.core.net.ILoader#httpStatus
	 */
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]

	/**
	 * @copy					by.blooddy.core.net.ILoader#securityError
	 */
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Флаха инициализировалась.
	 * 
	 * @eventType			flash.events.Event.INIT
	 */
	[Event(name="init", type="flash.events.Event")]

	/**
	 * Выгрузилось всё нафик.
	 * 
	 * @eventType			flash.events.Event.UNLOAD
	 */
	[Event(name="unload", type="flash.events.Event")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					loader
	 * 
	 * @see						flash.display.Loader
	 */
	public class Loader extends EventDispatcher implements ILoader {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _JUNK:Sprite = new Sprite();

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 * Constructor
		 *
		 * @param	request			Если надо, то сразу передадим и начнётся загрузка.
		 * @param	loaderContext	Если надо грузить, то возможно пригодится.
		 */
		public function Loader(request:URLRequest=null, loaderContext:LoaderContext=null) {
			super();
			var li:LoaderInfo = this._loader.contentLoaderInfo;
			li.addEventListener( Event.OPEN,					super.dispatchEvent,	false, int.MAX_VALUE );
			li.addEventListener( ProgressEvent.PROGRESS,		super.dispatchEvent,	false, int.MAX_VALUE );
			li.addEventListener( HTTPStatusEvent.HTTP_STATUS,	super.dispatchEvent,	false, int.MAX_VALUE );
			li.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_error,		false, int.MAX_VALUE );
			li.addEventListener( Event.COMPLETE,				this.handler_complete,	false, int.MAX_VALUE );
			li.addEventListener( Event.INIT,					this.handler_init,		false, int.MAX_VALUE );
			li.addEventListener( Event.UNLOAD,					super.dispatchEvent,	false, int.MAX_VALUE );
			this._loaderContext = loaderContext;
			if ( request ) this.load( request );
		}

		//--------------------------------------------------------------------------
		//
		//  Includes
		//
		//--------------------------------------------------------------------------

		include "../../../../includes/override_EventDispatcher.as"

		//--------------------------------------------------------------------------
		//
		//  Variblies
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _loader:LoaderAsset = new LoaderAsset();

		/**
		 * @private
		 */
		private var _request:URLRequest;

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoadable
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  bytesLoaded
		//----------------------------------

		/**
		 * @copy					by.blooddy.core.net.ILoadable#bytesLoaded
		 */
		public function get bytesLoaded():uint {
			return this.loaderInfo.bytesLoaded;
		}

		//----------------------------------
		//  bytesTotal
		//----------------------------------

		/**
		 * @copy					by.blooddy.core.net.ILoadable#bytesTotal
		 */
		public function get bytesTotal():uint {
			return this.loaderInfo.bytesTotal;
		}

		//----------------------------------
		//  loaded
		//----------------------------------

		/**
		 * @private
		 */
		protected var _status:uint = 0;

		/**
		 * @copy					by.blooddy.core.net.ILoadable#loaded
		 */
		public function get loaded():Boolean {
			return this._status == 2;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoader
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  url
		//----------------------------------

		/**
		 * @copy					by.blooddy.core.net.ILoader#url
		 */
		public function get url():String {
			return ( this._request ? this._request.url : this.loaderInfo.url );
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  loaderContext
		//----------------------------------

		/**
		 * @private
		 */
		private var _loaderContext:LoaderContext;

		/**
		 * A LoaderContext object to use to control loading of the content.
		 * This is an advanced property. 
		 * Most of the time you can use the trustContent property.
		 * 
		 * @default					null
		 * 
		 * @keyword					loader.loadercontext, loadercontext
		 * 
		 * @see						flash.system.LoaderContext
		 * @see						flash.system.ApplicationDomain
		 * @see						flash.system.SecurityDomain
		 */
		public function get loaderContext():LoaderContext {
			return this._loaderContext;
		}

		/**
		 * @private
		 */
		public function set loaderContext(value:LoaderContext):void {
			if ( this._loaderContext === value ) return;
			this._loaderContext = value;
		}

		//----------------------------------
		//  contentType
		//----------------------------------

		public function get contentType():String {
			return this._loader.contentLoaderInfo.contentType;
		}

		//----------------------------------
		//  content
		//----------------------------------

		/**
		 * @private
		 */
		private var _content:IBitmapDrawable;

		/**
		 * @copy					flash.display.Loader#content
		 */
		public function get content():IBitmapDrawable {
			return this._content;
		}

		//----------------------------------
		//  loaderInfo
		//----------------------------------

		/**
		 * @copy					flash.display.Loader#contentLoaderInfo
		 */
		public final function get loaderInfo():LoaderInfo {
			return this._loader.contentLoaderInfo;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: ILoader
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy					by.blooddy.core.net.ILoader#load()
		 */
		public function load(request:URLRequest):void {
			if ( this._status == 1 ) throw new IllegalOperationError(); // TODO: описать ошибку
			else if ( this._status == 2 ) this.clear();
			this._request = copyURLRequest( request );
			this._status = 1;
			this._loader.$load( this._request, this._loaderContext );
		}

		/**
		 * @copy					by.blooddy.core.net.ILoader#close()
		 */
		public function close():void {
			if ( this._status != 1 ) throw new IllegalOperationError(); // TODO: описать ошибку
			this.clear();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy					flash.display.Loader#loadBytes()
		 */
		public function loadBytes(bytes:ByteArray):void {
			if ( this._status == 1 ) throw new IllegalOperationError(); // TODO: описать ошибку
			else if ( this._status == 2 ) this.clear();
			this._status = 1;
			this._loader.$loadBytes( bytes, this._loaderContext );
		}

		/**
		 * @copy					flash.display.Loader#unload()
		 */
		public function unload():void {
			this._loader.$unload();
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return '[' + ClassUtils.getClassName( this ) + ' url="' + ( this.url || "" ) + '"]';
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function clear():void {
			try {
				this._loader.$close();
			} catch ( e:Error ) {
			}
			try {
				this._loader.$unload();
			} catch ( e:Error ) {
			}
			this._status = 0;
			this._request = null;
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
			var content:DisplayObject = this._loader.$content;

			_JUNK.addChild( content );
			_JUNK.removeChild( content );

			switch ( this._loader.contentLoaderInfo.contentType ) {
				case MIME.FLASH:
					this._content = content;
					break;
				case MIME.PNG:
				case MIME.JPEG:
				case MIME.GIF:
					this._content = ( content as Bitmap ).bitmapData;
					break;
			}

			super.dispatchEvent( event );
		}

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			this._status = 2;
			super.dispatchEvent( event );
		}

		/**
		 * @private
		 */
		private function handler_error(event:ErrorEvent):void {
			this.clear();
			// Перенапрвляем, только если есть листенер
			// иначе возникает ошибка.
			if ( super.hasEventListener( event.type ) ) super.dispatchEvent( event );
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.net.Loader;

import flash.display.DisplayObject;	
import flash.display.Loader;
import flash.errors.IllegalOperationError;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: LoaderAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 */
internal final class LoaderAsset extends flash.display.Loader {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public function LoaderAsset(target:by.blooddy.core.net.Loader=null) {
		super();
		this._target = target;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _target:by.blooddy.core.net.Loader;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	[Deprecated(message="свойство запрещено", replacement="$content")]
	/**
	 * @private
	 */
	public override function get content():DisplayObject {
		throw new IllegalOperationError(); // TODO: описать ошибку
	}

	/**
	 * @private
	 */
	internal function get $content():DisplayObject {
		return super.content;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	[Deprecated(message="метод запрещен", replacement="$load")]
	/**
	 * @private
	 */
	public override function load(request:URLRequest, context:LoaderContext=null):void {
		throw new IllegalOperationError(); // TODO: описать ошибку
	}

	/**
	 * @private
	 */
	internal function $load(request:URLRequest, context:LoaderContext=null):void {
		super.load( request, context );
	}

	[Deprecated(message="метод запрещен", replacement="$loadBytes")]
	/**
	 * @private
	 */
	public override function loadBytes(bytes:ByteArray, context:LoaderContext=null):void {
		throw new IllegalOperationError(); // TODO: описать ошибку
	}

	/**
	 * @private
	 */
	internal function $loadBytes(bytes:ByteArray, context:LoaderContext=null):void {
		super.loadBytes( bytes, context );
	}

	[Deprecated(message="метод запрещен", replacement="$unload")]
	/**
	 * @private
	 */
	public override function unload():void {
		throw new IllegalOperationError(); // TODO: описать ошибку
	}

	/**
	 * @private
	 */
	internal function $unload():void {
		try {
			super.unloadAndStop();
		} catch ( e:Error ) {
		}
	}

	[Deprecated(message="метод запрещен", replacement="$unload")]
	/**
	 * @private
	 */
	public override function unloadAndStop(gc:Boolean=true):void {
		throw new IllegalOperationError(); // TODO: описать ошибку
	}

	/**
	 * @private
	 */
	public override function close():void {
		if ( this._target ) {
			this._target.close();
		} else {
			if ( super.contentLoaderInfo && super.contentLoaderInfo.bytesLoaded < super.contentLoaderInfo.bytesTotal ) {
				super.close();
			}
		}
	}

	/**
	 * @private
	 */
	internal function $close():void {
		super.close();
	}

}