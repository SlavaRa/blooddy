////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.display.dispose;
	import by.blooddy.core.errors.getErrorMessage;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
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

		/**
		 * @private
		 */
		private static const _DOMAIN:String = ( new flash.net.LocalConnection() ).domain;
		
		/**
		 * @private
		 */
		private static const _URL:RegExp = ( _DOMAIN == 'localhost' ? null : new RegExp( '^((?!\w+://)|https?://(www\.)?' + _DOMAIN.replace( /\./g, '\\.' ) + ')', 'i' ) );
		
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
		public function Loader(request:URLRequest=null, loaderContext:by.blooddy.core.net.LoaderContext=null) {
			super();
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
		private var _loader:LoaderAsset;

		/**
		 * @private
		 */
		private var _request:URLRequest;

		/**
		 * @private
		 */
		private var _state:uint = _STATE_IDLE;
		
		/**
		 * @private
		 */
		private var _frameReady:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Implements properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  url
		//----------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get url():String {
			return ( this._request ? this._request.url : null );
		}
		
		//----------------------------------
		//  bytesLoaded
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get bytesLoaded():uint {
			return ( this.loaderInfo ? this.loaderInfo.bytesLoaded : 0 );
		}

		//----------------------------------
		//  bytesTotal
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get bytesTotal():uint {
			return ( this.loaderInfo ? this.loaderInfo.bytesTotal : 0 );
		}

		//----------------------------------
		//  loaded
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get loaded():Boolean {
			return this._state >= _STATE_COMPLETE;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoader
		//
		//--------------------------------------------------------------------------

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
		private var _loaderContext:by.blooddy.core.net.LoaderContext;

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
		public function get loaderContext():by.blooddy.core.net.LoaderContext {
			return this._loaderContext;
		}

		/**
		 * @private
		 */
		public function set loaderContext(value:by.blooddy.core.net.LoaderContext):void {
			if ( this._loaderContext === value ) return;
			if ( this._state != _STATE_IDLE ) throw new IllegalOperationError();
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
			return ( this._loader ? this._loader.$loaderInfo : null );
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: ILoader
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy					com.timezero.platform.net.ILoader#load()
		 */
		public function load(request:URLRequest):void {
			if ( this._state != _STATE_IDLE ) throw new ArgumentError();
			//else if ( this._state > _STATE_PROGRESS ) this.clear();
			this._state = _STATE_PROGRESS;
			this._request = copyURLRequest( request );
			this._loader = this.create_loader( true, true );
			this._loader.$load( this._request, this.create_loaderContext( _URL && _URL.test( this._request.url ) ) );
			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
		}

		/**
		 * @copy					com.timezero.platform.net.ILoader#close()
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
			//else if ( this._state > _STATE_PROGRESS ) this.clear();
			this._state = _STATE_PROGRESS;
			this._loader = this.create_loader( true );
			this._loader.$loadBytes( bytes, this.create_loaderContext() );
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
			return '[' + ClassUtils.getClassName( this ) + ' url="' + ( this.url || '' ) + '"]';
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * создаёт лоадер для загрузки
		 */
		private function create_loader(open:Boolean=false, security:Boolean=false):LoaderAsset {
			var result:LoaderAsset = new LoaderAsset( this );
			var li:LoaderInfo = result.$loaderInfo;
			if ( open ) {	// событие уже могло быть послано
				li.addEventListener( Event.OPEN,				super.dispatchEvent,		false, int.MAX_VALUE );
			}
			li.addEventListener( HTTPStatusEvent.HTTP_STATUS,	super.dispatchEvent,		false, int.MAX_VALUE );
			li.addEventListener( ProgressEvent.PROGRESS,		this.handler_progress,		false, int.MAX_VALUE );
			if ( security ) { // с подозрением на секурность, используем расширенный обработчик
				li.addEventListener( Event.INIT,				this.handler_security_init,	false, int.MAX_VALUE );
			} else {
				li.addEventListener( Event.INIT,				this.handler_init,			false, int.MAX_VALUE );
			}
			li.addEventListener( Event.COMPLETE,				this.handler_complete,		false, int.MAX_VALUE );
			li.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_error,			false, int.MAX_VALUE );
			return result;
		}

		/**
		 * @private
		 */
		private function create_loaderContext(canSecurity:Boolean=false):flash.system.LoaderContext {
			if (
				this._loaderContext && (
					( canSecurity && this._loaderContext.ignoreSecurity ) ||
					this._loaderContext.checkPolicyFile ||
					this._loaderContext.applicationDomain
				)
			) {
				return new flash.system.LoaderContext(
					this._loaderContext.checkPolicyFile,
					this._loaderContext.applicationDomain,
					( canSecurity && this._loaderContext.ignoreSecurity
						?	SecurityDomain.currentDomain
						:	null
					)
				);
			}
			return null;
		}
		
		/**
		 * @private
		 */
		private function clear():void {
			var unload:Boolean = Boolean( this._content || this._loader );
			this.clear_loader();
			this._request = null;
			if ( this._content ) {
				if ( this._content is DisplayObject ) {
					var d:DisplayObject = this._content as DisplayObject;
					_JUNK.addChild( d );
					_JUNK.removeChild( d );
					dispose( d );
				} else if ( this._content is BitmapData ) {
					( this._content as BitmapData ).dispose();
				}
				this._content = undefined;
			}
			this._contentType = null;
			this._state = _STATE_IDLE;
			if ( unload && super.hasEventListener( Event.UNLOAD ) ) {
				super.dispatchEvent( new Event( Event.UNLOAD ) );
			}
		}

		/**
		 * @private
		 */
		private function clear_loader():void {
			var li:LoaderInfo = this._loader.$loaderInfo;
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

				var li:LoaderInfo = this._loader.$loaderInfo;
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

			var invalidSWF:Boolean = false;
			
			if ( this._contentType && this._contentType != this._loader.$loaderInfo.contentType ) { // если они не равны, то протикала загрузка через loadBytes.
				// BUGFIX: если грузить каринку черезе loadBytes, то она неправильно обрабатывается, и почему-то кладётся в MovieClip, что нас не устраивает.
				switch ( this._loader.$loaderInfo.contentType ) {
					case MIME.FLASH: break;
					default: invalidSWF = true;
				}
				if ( !invalidSWF ) {
					switch ( this._contentType ) {
						case MIME.PNG: case MIME.JPEG: case MIME.GIF: break;
						default: invalidSWF = true;
					}
					if ( !invalidSWF && !( content is MovieClip ) && ( content as MovieClip ).numChildren <= 0 ) {
						invalidSWF = true;
					}
					if ( !invalidSWF ) {
						content = ( content as MovieClip ).getChildAt( 0 );
						if ( !( content is Bitmap ) ) {
							invalidSWF = true;
						}
					}
				}
			} else {
				this._contentType = this._loader.$loaderInfo.contentType;
			}

			if ( invalidSWF ) {
				this._state = _STATE_ERROR;
				super.dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, 'плохой swf подсунулся' ) );
			} else {
				switch ( this._loader.$loaderInfo.contentType ) {
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
		}

		/**
		 * @private
		 */
		private function handler_security_complete(event:Event):void {
			var loader:LoaderAsset = this.create_loader();
			loader.$loadBytes( this._loader.$loaderInfo.bytes, this.create_loaderContext() );
			this.clear_loader();	// очищаем старый лоадер
			this._loader = loader;	// записываем новый
		}

		/**
		 * @private
		 * слушает прогресс, и обвноляет его, если _frameReady установлен в true.
		 */
		private function handler_progress(event:ProgressEvent):void {
			if ( !this._frameReady ) return;
			this._frameReady = false;
			super.dispatchEvent( event );
		}
		
		/**
		 * @private
		 * устанавливает _frameReady в true. что бы избежать слишком частые обвноления со стороны загрузщиков.
		 */
		private function handler_enterFrame(event:Event):void {
			this._frameReady = true;
		}
		
		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this._state = _STATE_COMPLETE;
			super.dispatchEvent( event );
		}

		/**
		 * @private
		 * слушает ошибки
		 */
		private function handler_error(event:ErrorEvent):void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this._state = _STATE_ERROR;
			// перенапрвляем, только если есть листенер
			super.dispatchEvent( event );
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.errors.getErrorMessage;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

/**
 * @private
 */
internal const _JUNK:Sprite = new Sprite();

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
		throw new IllegalOperationError( getErrorMessage( 2071, this ), 2071 );
	}

	/**
	 * @private
	 */
	internal function get $content():DisplayObject {
		return super.content;
	}

	[Deprecated( message="свойство запрещено", replacement="$loaderInfo" )]
	/**
	 * @private
	 */
	public override function get contentLoaderInfo():LoaderInfo {
		throw new IllegalOperationError( getErrorMessage( 2071, this ), 2071 );
	}

	/**
	 * @private
	 */
	internal function get $loaderInfo():LoaderInfo {
		return super.contentLoaderInfo;
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
		throw new IllegalOperationError( getErrorMessage( 2071, this ), 2071 );
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
		throw new IllegalOperationError( getErrorMessage( 2071, this ), 2071 );
	}

	/**
	 * @private
	 */
	internal function $loadBytes(bytes:ByteArray, context:LoaderContext=null):void {
		if ( context && context.securityDomain ) {
			context = new LoaderContext( context.checkPolicyFile, context.applicationDomain );
		}
		super.loadBytes( bytes, context );
	}

	[Deprecated( message="метод запрещен", replacement="$unload" )]
	/**
	 * @private
	 */
	public override function unload():void {
		throw new IllegalOperationError( getErrorMessage( 2071, this ), 2071 );
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
		throw new IllegalOperationError( getErrorMessage( 2071, this ), 2071 );
	}

	/**
	 * @private
	 */
	public override function close():void {
		this._target.close();
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
		throw new IllegalOperationError( getErrorMessage( 2071, this ), 2071 );
	}

}