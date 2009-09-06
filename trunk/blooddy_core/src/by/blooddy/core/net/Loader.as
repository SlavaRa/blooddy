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
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.errors.InvalidSWFError;
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
	[Event( name="complete", type="flash.events.Event" )]

	/**
	 * @copy					by.blooddy.core.net.ILoadable#ioError
	 */
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]

	/**
	 * @copy					by.blooddy.core.net.ILoadable#open
	 */
	[Event( name="open", type="flash.events.Event" )]

	/**
	 * @copy					by.blooddy.core.net.ILoadable#progress
	 */
	[Event( name="progress", type="flash.events.ProgressEvent" )]

	//--------------------------------------
	//  Implements events: ILoader
	//--------------------------------------

	/**
	 * @copy					by.blooddy.core.net.ILoader#httpStatus
	 */
	[Event( name="httpStatus", type="flash.events.HTTPStatusEvent" )]

	/**
	 * @copy					by.blooddy.core.net.ILoader#securityError
	 */
	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Флаха инициализировалась.
	 * 
	 * @eventType			flash.events.Event.INIT
	 */
	[Event( name="init", type="flash.events.Event" )]

	/**
	 * Выгрузилось всё нафик.
	 * 
	 * @eventType			flash.events.Event.UNLOAD
	 */
	[Event( name="unload", type="flash.events.Event" )]

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

		/**
		 * @private
		 * статус загрузки. ожидание
		 */
		private static const _STATE_IDLE:uint =		0;

		/**
		 * @private
		 * статус загрузки. прогресс
		 */
		private static const _STATE_PROGRESS:uint =	_STATE_IDLE		+ 1;

		/**
		 * @private
		 * статус загрузки. всё зашибись
		 */
		private static const _STATE_COMPLETE:uint =	_STATE_PROGRESS	+ 1;

		/**
		 * @private
		 * статус загрузки. ошибка
		 */
		private static const _STATE_ERROR:uint =	_STATE_COMPLETE	+ 1;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 * Constructor.
		 *
		 * @param	request			Если надо, то сразу передадим и начнётся загрузка.
		 * @param	loaderContext	Если надо грузить, то возможно пригодится.
		 */
		public function Loader(request:URLRequest=null, loaderContext:LoaderContext=null) {
			super();
			this._loaderContext = loaderContext;
			if ( request ) this.load( request );
		}

		//--------------------------------------------------------------------------
		//
		//  Variblies
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _loader:LoaderAsset;

		/**
		 * @private
		 */
		private var _request:URLRequest;

		//--------------------------------------------------------------------------
		//
		//  Overiden methods: EventDispatcher
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override final function dispatchEvent(event:Event):Boolean {
			throw new IllegalOperationError( getErrorMessage( 2071 ), 2071 );
		}

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
			return ( this.loaderInfo ? this.loaderInfo.bytesLoaded : 0 );
		}

		//----------------------------------
		//  bytesTotal
		//----------------------------------

		/**
		 * @copy					by.blooddy.core.net.ILoadable#bytesTotal
		 */
		public function get bytesTotal():uint {
			return ( this.loaderInfo ? this.loaderInfo.bytesTotal : 0 );
		}

		//----------------------------------
		//  loaded
		//----------------------------------

		/**
		 * @private
		 */
		private var _state:uint = _STATE_IDLE;

		/**
		 * @copy					by.blooddy.core.net.ILoadable#loaded
		 */
		public function get loaded():Boolean {
			return this._state >= _STATE_COMPLETE;
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
			return ( this._request ? this._request.url : null );
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

		/**
		 * @private
		 */
		private var _contentType:String;

		public function get contentType():String {
			return this._contentType;
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
			return ( this._loader ? this._loader.contentLoaderInfo : null );
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
			if ( this._state != _STATE_IDLE ) throw new ArgumentError();
			else if ( this._state > _STATE_PROGRESS ) this.clear();
			this._state = _STATE_PROGRESS;
			this._loader = new LoaderAsset( this );
			var li:LoaderInfo = this._loader.contentLoaderInfo;
			li.addEventListener( Event.OPEN,					super.dispatchEvent,		false, int.MAX_VALUE );
			li.addEventListener( ProgressEvent.PROGRESS,		super.dispatchEvent,		false, int.MAX_VALUE );
			li.addEventListener( HTTPStatusEvent.HTTP_STATUS,	super.dispatchEvent,		false, int.MAX_VALUE );
			li.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_error,			false, int.MAX_VALUE );
			li.addEventListener( Event.COMPLETE,				this.handler_complete,		false, int.MAX_VALUE );
			li.addEventListener( Event.INIT,					this.handler_security_init,	false, int.MAX_VALUE );
			this._request = copyURLRequest( request );
			this._loader.$load( this._request, this._loaderContext );
		}

		/**
		 * @copy					by.blooddy.core.net.ILoader#close()
		 */
		public function close():void {
			if ( this._state != _STATE_PROGRESS ) throw new ArgumentError();
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
			if ( this._state != _STATE_IDLE ) throw new ArgumentError();
			else if ( this._state > _STATE_PROGRESS ) this.clear();
			this._state = _STATE_PROGRESS;
			this._loader = new LoaderAsset( this );
			var li:LoaderInfo = this._loader.contentLoaderInfo;
			li.addEventListener( Event.OPEN,					super.dispatchEvent,	false, int.MAX_VALUE );
			li.addEventListener( ProgressEvent.PROGRESS,		super.dispatchEvent,	false, int.MAX_VALUE );
			li.addEventListener( HTTPStatusEvent.HTTP_STATUS,	super.dispatchEvent,	false, int.MAX_VALUE );
			li.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_error,		false, int.MAX_VALUE );
			li.addEventListener( Event.COMPLETE,				this.handler_complete,	false, int.MAX_VALUE );
			li.addEventListener( Event.INIT,					this.handler_init,		false, int.MAX_VALUE );
			this._loader.$loadBytes( bytes, this._loaderContext );
		}

		/**
		 * @copy					flash.display.Loader#unload()
		 */
		public function unload():void {
			if ( this._state <= _STATE_PROGRESS ) throw new ArgumentError();
			this.clear();
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return '[' + ClassUtils.getClassName(this) + ' url="' + ( this.url || "" ) + '"]';
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 */
		protected function $dispatchEvent(event:Event):Boolean {
			return super.dispatchEvent( event );
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
			var unload:Boolean = ( this._content || this._loader );
			this.clear_loader();
			this._state = _STATE_IDLE;
			this._request = null;
			this._contentType = null;
			if ( unload && super.hasEventListener( Event.UNLOAD ) ) {
				super.dispatchEvent( new Event( Event.UNLOAD ) );
			}
		}

		/**
		 * @private
		 */
		private function clear_loader():void {
			var li:LoaderInfo = this._loader.contentLoaderInfo;
			li.removeEventListener( Event.OPEN,						super.dispatchEvent );
			li.removeEventListener( ProgressEvent.PROGRESS,			super.dispatchEvent );
			li.removeEventListener( HTTPStatusEvent.HTTP_STATUS,	super.dispatchEvent );
			li.removeEventListener( IOErrorEvent.IO_ERROR,			this.handler_error );
			li.removeEventListener( Event.COMPLETE,					this.handler_security_complete );
			li.removeEventListener( Event.COMPLETE,					this.handler_complete );
			li.removeEventListener( Event.INIT,						this.handler_security_init );
			li.removeEventListener( Event.INIT,						this.handler_init );
			try {
				this._loader.$close();
			} catch ( e:Error ) {
			}
			try {
				this._loader.$unload();
			} catch ( e:Error ) {
			}
			this._loader = null;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_security_init(event:Event):void {
			try {

				this._loader.$content;
				this.handler_init( event );

			} catch ( e:SecurityError ) {

				var li:LoaderInfo = this._loader.contentLoaderInfo;
				this._contentType = li.contentType;
				li.removeEventListener( Event.COMPLETE, this.handler_complete );
				li.addEventListener( Event.COMPLETE, this.handler_security_complete );

			}
		}

		/**
		 * @private
		 */
		private function handler_init(event:Event):void {
			var content:DisplayObject = this._loader.$content;

			_JUNK.addChild( content );
			_JUNK.removeChild( content );

			if ( this._contentType && this._contentType != this._loader.contentLoaderInfo.contentType ) {
				switch ( this._loader.contentLoaderInfo.contentType ) {
					case MIME.FLASH:	break;
					default:			throw new InvalidSWFError();
				}
				switch ( this._contentType ) {
					case MIME.PNG:
					case MIME.JPEG:
					case MIME.GIF:		break;
					default:			throw new InvalidSWFError();
				}
				if ( !( content is MovieClip ) && ( content as MovieClip ).numChildren <= 0 ) {
					throw new InvalidSWFError();
				}
				content = ( content as MovieClip ).getChildAt( 0 );
				if ( !( content is Bitmap ) ) {
					throw new InvalidSWFError();
				}
			} else {
				this._contentType = this._loader.contentLoaderInfo.contentType;
			}

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
			if ( super.hasEventListener( Event.INIT ) ) {
				super.dispatchEvent( event );
			}
		}

		/**
		 * @private
		 */
		private function handler_security_complete(event:Event):void {

			var bytes:ByteArray = new ByteArray();
			bytes.writeBytes( this._loader.contentLoaderInfo.bytes );

			this.clear_loader();

			this._loader = new LoaderAsset( this );
			var li:LoaderInfo = this._loader.contentLoaderInfo;
			li.addEventListener( ProgressEvent.PROGRESS,		super.dispatchEvent,	false, int.MAX_VALUE );
			li.addEventListener( Event.COMPLETE,				this.handler_complete,	false, int.MAX_VALUE );
			li.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_error,		false, int.MAX_VALUE );
			li.addEventListener( Event.INIT,					this.handler_init,		false, int.MAX_VALUE );
			this._loader.$loadBytes( bytes, this._loaderContext );

			bytes.clear();

		}

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			this._state = _STATE_COMPLETE;
			super.dispatchEvent( event );
		}

		/**
		 * @private
		 */
		private function handler_error(event:ErrorEvent):void {
			this.clear_loader();
			// Перенапрвляем, только если есть листенер
			super.dispatchEvent( event );
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
import flash.events.Event;
import flash.display.Sprite;

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
	 * @private
	 */
	public function LoaderAsset(target:by.blooddy.core.net.Loader) {
		super();
		this._target = target;
		super.addEventListener( Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MAX_VALUE, true );
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

	[Deprecated( message="свойство запрещено", replacement="$content" )]
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

	[Deprecated( message="метод запрещен", replacement="$load" )]
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

	[Deprecated( message="метод запрещен", replacement="$loadBytes" )]
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

	[Deprecated( message="метод запрещен", replacement="$unload" )]
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

	[Deprecated( message="метод запрещен", replacement="$unload" )]
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

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function handler_addedToStage(event:Event):void {
		_JUNK.addChild( this );
		_JUNK.removeChild( this );
		throw new IllegalOperationError();
	}

}