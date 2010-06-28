////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {

	import by.blooddy.core.display.dispose;
	import by.blooddy.core.net.MIME;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;

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
	public class Loader extends LoaderBase {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected_load;
		
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
		public function Loader(request:URLRequest=null, loaderContext:by.blooddy.core.net.loading.LoaderContext=null) {
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
		private var _loaderContext:by.blooddy.core.net.loading.LoaderContext;

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
		public function get loaderContext():by.blooddy.core.net.loading.LoaderContext {
			return this._loaderContext;
		}

		/**
		 * @private
		 */
		public function set loaderContext(value:by.blooddy.core.net.loading.LoaderContext):void {
			if ( this._loaderContext === value ) return;
			if ( !super.isIdle() ) throw new ArgumentError();
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
		 * @private
		 */
		private var _loaderInfo:LoaderInfo;
		
		/**
		 * @copy					flash.display.Loader#contentLoaderInfo
		 */
		public final function get loaderInfo():LoaderInfo {
			return this._loaderInfo;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$protected_load override function $load(request:URLRequest):void {
			this._loader = this.create_loader( true, true );
			this._loaderInfo = this._loader.$loaderInfo;
			this._loader.$load( request, this.create_loaderContext( _URL && _URL.test( request.url ) ) );
		}

		/**
		 * @private
		 */
		$protected_load override function $loadBytes(bytes:ByteArray):void {
			this._loader = this.create_loader();
			this._loaderInfo = this._loader.$loaderInfo;
			this._loader.$loadBytes( bytes, this.create_loaderContext() );
		}

		/**
		 * @private
		 */
		$protected_load override function $unload():Boolean {
			var unload:Boolean = Boolean( this._content || this._loader );
			this.clear_loader();
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
			return unload;
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
				li.addEventListener( Event.OPEN,				super.dispatchEvent,			false, int.MAX_VALUE );
			}
			li.addEventListener( HTTPStatusEvent.HTTP_STATUS,	super.dispatchEvent,			false, int.MAX_VALUE );
			li.addEventListener( ProgressEvent.PROGRESS,		super.progressHandler,			false, int.MAX_VALUE );
			if ( security ) { // с подозрением на секурность, используем расширенный обработчик
				li.addEventListener( Event.INIT,				this.handler_security_init,		false, int.MAX_VALUE );
			} else {
				li.addEventListener( Event.INIT,				this.handler_init,				false, int.MAX_VALUE );
			}
			li.addEventListener( Event.COMPLETE,				this.handler_loader_complete,	false, int.MAX_VALUE );
			li.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_loader_error,		false, int.MAX_VALUE );
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
		private function clear_loader():void {
			if ( this._loader ) {
				var li:LoaderInfo = this._loaderInfo;
				li.removeEventListener( Event.OPEN,						super.dispatchEvent );
				li.removeEventListener( HTTPStatusEvent.HTTP_STATUS,	super.dispatchEvent );
				li.removeEventListener( ProgressEvent.PROGRESS,			super.progressHandler );
				li.removeEventListener( Event.INIT,						this.handler_security_init );
				li.removeEventListener( Event.INIT,						this.handler_init );
				li.removeEventListener( Event.COMPLETE,					this.handler_security_complete );
				li.removeEventListener( Event.COMPLETE,					this.handler_loader_complete );
				li.removeEventListener( IOErrorEvent.IO_ERROR,			this.handler_loader_error );
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

				if ( this._loaderContext && this._loaderContext.ignoreSecurity ) {

					this._contentType = this._loaderInfo.contentType;
					this._loaderInfo.removeEventListener( Event.COMPLETE, this.handler_loader_complete );
					this._loaderInfo.addEventListener( Event.COMPLETE, this.handler_security_complete );

				} else {

					this.handler_error( new SecurityErrorEvent( SecurityErrorEvent.SECURITY_ERROR, false, false, e.toString() ) );

				}

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
			
			if ( this._contentType && this._contentType != this._loaderInfo.contentType ) { // если они не равны, то протикала загрузка через loadBytes.
				// BUGFIX: если грузить каринку черезе loadBytes, то она неправильно обрабатывается, и почему-то кладётся в MovieClip, что нас не устраивает.
				switch ( this._loaderInfo.contentType ) {
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
						content = ( content as MovieClip ).removeChildAt( 0 );
						if ( !( content is Bitmap ) ) {
							invalidSWF = true;
						}
					}
				}
			} else {
				this._contentType = this._loaderInfo.contentType;
			}

			if ( invalidSWF ) {

				if ( content ) {
					_JUNK.addChild( content );
					_JUNK.removeChild( content );
					dispose( content );
				}
				this.handler_loader_error( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, 'плохой swf подсунулся' ) );

			} else {

				switch ( this._loaderInfo.contentType ) {
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
			loader.$loadBytes( this._loaderInfo.bytes, this.create_loaderContext() );
			this.clear_loader();	// очищаем старый лоадер
			this._loader = loader;	// записываем новый
			this._loaderInfo = this._loader.$loaderInfo;
		}

		/**
		 * @private
		 */
		private function handler_loader_complete(event:Event):void {
			var bytesTotal:uint = this._loaderInfo.bytesTotal;
			super.updateProgress( bytesTotal, bytesTotal );
			super.completeHandler( event );
		}

		/**
		 * @private
		 */
		private function handler_loader_error(event:ErrorEvent):void {
			this.clear_loader();
			super.completeHandler( event );
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.utils.ClassUtils;
import by.blooddy.core.utils.time.setTimeout;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.getTimer;

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
	
	/**
	 * @private
	 */
	private static const _GC_CALL_TIMEOUT:uint = 1E3;
	
	/**
	 * @private
	 */
	private static var _lastLoader:LoaderAsset;

	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static function do$unload():void {
		_lastLoader.$unloadAndStop( true );
		_lastLoader = null;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public function LoaderAsset(target:by.blooddy.core.net.loading.Loader) {
		super();
		this._target = target;
		super.addEventListener( Event.ADDED, this.handler_added, false, int.MAX_VALUE, true );
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _target:by.blooddy.core.net.loading.Loader;

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
		Error.throwError( IllegalOperationError, 1069, 'content', ClassUtils.getClassName( this ) );
		return null;
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
		Error.throwError( IllegalOperationError, 1069, 'contentLoaderInfo', ClassUtils.getClassName( this ) );
		return null;
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
		Error.throwError( IllegalOperationError, 1001, 'load' );
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
		Error.throwError( IllegalOperationError, 1001, 'loadBytes' );
	}

	/**
	 * @private
	 */
	internal function $loadBytes(bytes:ByteArray, context:LoaderContext=null):void {
		super.loadBytes( bytes, context );
	}

	/**
	 * @private
	 */
	public override function unload():void {
		this._target.unload();
	}

	/**
	 * @private
	 */
	internal function $unload():void {
		if ( _lastLoader ) {
			_lastLoader.$unloadAndStop( false );
		} else {
			setTimeout( do$unload, _GC_CALL_TIMEOUT );
		}
		_lastLoader = this;
	}

	/**
	 * @private
	 */
	public override function unloadAndStop(gc:Boolean=true):void {
		this._target.unload();
	}

	private function $unloadAndStop(gc:Boolean=true):void {
		super.unloadAndStop( gc );
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
	private function handler_added(event:Event):void {
		if ( event.target !== this ) return;
		_JUNK.addChild( this );
		_JUNK.removeChild( this );
		Error.throwError( IllegalOperationError, 2037 );
	}

}