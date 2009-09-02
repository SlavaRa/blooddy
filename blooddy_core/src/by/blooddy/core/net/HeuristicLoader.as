////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
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

	/**
	 * @copy					by.blooddy.core.net.ILoadable#progress
	 */
	[Event(name="unload", type="flash.events.Event")]

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
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					loader
	 * 
	 * @see						flash.display.Loader
	 */
	public class HeuristicLoader extends EventDispatcher implements ILoader {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * сюда складываются контенты от Loader'ов
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
		private static const _STATE_PROGRESS:uint =	1 + _STATE_IDLE;

		/**
		 * @private
		 * статус загрузки. всё зашибись
		 */
		private static const _STATE_COMPLETE:uint =	1 + _STATE_PROGRESS;

		/**
		 * @private
		 * статус загрузки. ошибка
		 */
		private static const _STATE_ERROR:uint =		1 + _STATE_COMPLETE;

		//--------------------------------------------------------------------------
		//
		//  Cosntructor
		//
		//--------------------------------------------------------------------------

		/**
 		 * Constructor
		 * 
		 * @param	request
		 * @param	loaderContext
		 */
		public function HeuristicLoader(request:URLRequest=null, loaderContext:LoaderContext=null) {
			super();
			if ( loaderContext ) this._loaderContext = loaderContext;
			if ( request ) this.load( request );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * сюда грузится данные для анализа, если анализ неудовлетваряет требованию,
		 * то они продолжают сюда грзится
		 */
		private var _stream:flash.net.URLStream;

		/**
		 * @private
		 * сюда грзится swf, а так же картинки
		 */
		private var _loader:LoaderAsset;

		/**
		 * @private
		 * сюда грзятся звуки
		 */
		private var _sound:SoundAsset;

		/**
		 * @private
		 * буфер загруженных данных
		 */
		private var _input:ByteArray;

		/**
		 * @private
		 * состояние загрзщика
		 */
		private var _state:uint = _STATE_IDLE;
		
		/**
		 * @private
		 */
		private var _frameReady:Boolean = false;

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
			if (this._loaderContext === value) return;
			this._loaderContext = value;
		}

		//----------------------------------
		//  loaderInfo
		//----------------------------------

		/**
		 * @private
		 */
		private var _loaderInfo:LoaderInfo;

		/**
		 * ссылка на информацию о Loader
		 */
		public function get loaderInfo():LoaderInfo {
			return this._loaderInfo;
		}

		/**
		 * @private
		 */
		private var _contentType:String;

		/**
		 * MIME-type загруженного содержания
		 */
		public function get contentType():String {
			if ( this._loader ) {
				return this._loader.contentLoaderInfo.contentType;
			}
			return this._contentType;
		}

		/**
		 * @private
		 */
		private var _request:URLRequest;

		/**
		 * урыл на файл
		 */
		public function get url():String {
			return ( this._request ? this._request.url : null );
		}

		/**
		 * загрузился ли уже файл?
		 */
		public function get loaded():Boolean {
			return this._state > _STATE_PROGRESS;
		}

		/**
		 * @private
		 */
		private var _bytesLoaded:uint = 0;

		/**
		 * сколько байт загружено
		 */
		public function get bytesLoaded():uint {
			return this._bytesLoaded;
		}

		/**
		 * @private
		 */
		private var _bytesTotal:uint = 0;

		/**
		 * сколько байт всего
		 */
		public function get bytesTotal():uint {
			return this._bytesTotal;
		}

		/**
		 * @private
		 */
		private var _content:*;

		/**
		 * загруженный контент
		 */
		public function get content():* {
			return this._content;
		}

		/**
		 * начинает загрузку файла
		 * 
		 * @param	request		запрос
		 * 
		 * @event	open
		 * @event	httpStatus
		 * @event	progress
		 * @event	complete
		 * @event	ioError
		 * @event	securityError
		 * 
		 * @throw	ArgumentError	если мы не в состоянии idle
		 */
		public function load(request:URLRequest):void {
			if ( this._state != _STATE_IDLE ) throw new ArgumentError();
			//else if ( this._state > _STATE_PROGRESS ) this.clear();
			this._state = _STATE_PROGRESS;
			if ( !this._input ) this._input = new ByteArray();
			this._request = copyURLRequest( request );
			this._stream = new flash.net.URLStream();
			this._stream.addEventListener( Event.OPEN,							super.dispatchEvent );
			this._stream.addEventListener( HTTPStatusEvent.HTTP_STATUS,			super.dispatchEvent );
			this._stream.addEventListener( ProgressEvent.PROGRESS,				this.handler_stream_init_progress );
			this._stream.addEventListener( Event.COMPLETE,						this.handler_stream_init_complete );
			this._stream.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
			this._stream.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_stream_init_securityError );
			enterFrameBroadcaster.addEventListener(Event.ENTER_FRAME, 			this.handler_enterFrame);
			this._stream.load( this._request );
		}

		/**
		 * выгружает загруженный контент
		 */
		public function unload():void {
			if ( this._state <= _STATE_PROGRESS ) throw new ArgumentError();
			this.clear();
		}

		/**
		 * останавливает загрузку, и выгружает данные
		 */
		public function close():void {
			if ( this._state != _STATE_PROGRESS ) throw new ArgumentError();
			this.clear();
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
		 * очисщает данные
		 */
		private function clear():void {
			var unload:Boolean = ( this._content || this._stream || this._loader || this._sound );
			this.clear_stream();
			this.clear_loader();
			this.clear_sound();
			this._request = null;
			this._bytesLoaded = 0;
			this._bytesTotal = 0;
			this._content = undefined;
			this._contentType = null;
			this._state = _STATE_IDLE;
			this.clear_input();
			if ( unload ) {
				super.dispatchEvent( new Event( Event.UNLOAD ) );
			}
		}
		
		/**
		 * @private
		 */
		private function updateProgress(bytesLoaded:uint, bytesTotal:uint):void {
//			if (this._bytesLoaded == bytesLoaded && this._bytesTotal == bytesTotal) return;
			this._bytesLoaded = bytesLoaded;
			this._bytesTotal = bytesTotal;
			super.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, this._bytesLoaded, this._bytesTotal));
		}

		/**
		 * @private
		 * очищает stream
		 */
		private function clear_stream():void {
			if ( this._stream ) {
				if ( this._stream.connected ) {
					this._stream.close();
				}
				this._stream.removeEventListener( Event.OPEN,							super.dispatchEvent );
				this._stream.removeEventListener( HTTPStatusEvent.HTTP_STATUS,			super.dispatchEvent );
				this._stream.removeEventListener( ProgressEvent.PROGRESS,				this.handler_stream_init_progress );
				this._stream.removeEventListener( ProgressEvent.PROGRESS,				this.handler_progress );
				this._stream.removeEventListener( Event.COMPLETE,						this.handler_stream_init_complete );
				this._stream.removeEventListener( Event.COMPLETE,						this.handler_stream_complete );
				this._stream.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
				this._stream.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_stream_init_securityError );
				this._stream = null;
			}
		}

		/**
		 * @private
		 * очищает loader
		 * 
		 * @param	unload	выгружать ли данные?
		 */
		private function clear_loader(unload:Boolean=true):void {
			if ( this._loader ) {
				var loaderInfo:LoaderInfo = this._loader.contentLoaderInfo;
				loaderInfo.removeEventListener( Event.OPEN,						super.dispatchEvent );
				loaderInfo.removeEventListener( HTTPStatusEvent.HTTP_STATUS,	super.dispatchEvent );
				loaderInfo.removeEventListener( ProgressEvent.PROGRESS,			this.handler_progress );
				loaderInfo.removeEventListener( Event.COMPLETE,					this.handler_loader_complete );
				loaderInfo.removeEventListener( IOErrorEvent.IO_ERROR,			this.handler_error );
				loaderInfo.removeEventListener( Event.INIT,						this.handler_loader_init );
				if ( unload ) {
					try {
						this._loader.$close();
					} catch ( e:Error ) {
					}
					try {
						this._loader.$unload();
					} catch ( e:Error ) {
					}
					this._loaderInfo = null;
					this._loader = null;
				}
			}
		}

		/**
		 * @private
		 * очищает sound
		 * 
		 * @param	unload	выгружать ли данные?
		 */
		private function clear_sound(unload:Boolean=true):void {
			if ( this._sound ) {
				this._sound.removeEventListener( Event.OPEN,				super.dispatchEvent );
				this._sound.removeEventListener( ProgressEvent.PROGRESS,	this.handler_progress );
				this._sound.removeEventListener( Event.COMPLETE,			this.handler_sound_complete );
				this._sound.removeEventListener( IOErrorEvent.IO_ERROR,		this.handler_error );
				
				if ( unload ) {
					try {
						this._sound.$close();
					} catch ( e:Error ) {
					}
					this._sound = null;
				}
			}
		}

		/**
		 * @private
		 * очищает буфер
		 */
		private function clear_input():void {
			if ( this._input ) {
				this._input.clear();
				this._input = null;
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  common
		//----------------------------------

		/**
		 * @private
		 */
		private function handler_progress(event:ProgressEvent):void {
			this._bytesLoaded = event.bytesLoaded;
			this._bytesTotal = event.bytesTotal;
			if (!this._frameReady) return;
			this._frameReady = false;
			super.dispatchEvent( event );
		}
		
		/**
		 * @private
		 */
		private function handler_enterFrame(event:Event):void {
			this._frameReady = true;
		}

		/**
		 * @private
		 */
		private function handler_error(event:ErrorEvent):void {
			enterFrameBroadcaster.removeEventListener(Event.ENTER_FRAME, this.handler_enterFrame);
			this._state = _STATE_ERROR;
			if ( super.hasEventListener( event.type ) ) super.dispatchEvent( event );
		}

		//----------------------------------
		//  init
		//----------------------------------

		/**
		 * @private
		 */
		private function handler_stream_init_progress(event:ProgressEvent):void {
			this._stream.readBytes( this._input, this._input.length );
			var type:String = MIME.analyseBytes( this._input ); // пытаемся узнать что за говно мы грузим
			if ( type ) {
				this._contentType = type;
				switch ( this._contentType ) {
					case MIME.FLASH:
					case MIME.PNG:
					case MIME.JPEG:
					case MIME.GIF:
						this.clear_stream();	// закрываем поток
						this.clear_input();
						this._loader = new LoaderAsset();
						var loaderInfo:LoaderInfo = this._loader.contentLoaderInfo;
						loaderInfo.addEventListener( HTTPStatusEvent.HTTP_STATUS,	super.dispatchEvent,			false, int.MAX_VALUE );
						loaderInfo.addEventListener( ProgressEvent.PROGRESS,		this.handler_progress,			false, int.MAX_VALUE );
						loaderInfo.addEventListener( Event.COMPLETE,				this.handler_loader_complete,	false, int.MAX_VALUE );
						loaderInfo.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_error,				false, int.MAX_VALUE );
						loaderInfo.addEventListener( Event.INIT,					this.handler_loader_init,		false, int.MAX_VALUE );
						this._loader.$load( this._request, this._loaderContext );
						break;
					case MIME.MP3:
						this.clear_stream();	// закрываем поток
						this.clear_input();
						this._sound = new SoundAsset();
						this._sound.addEventListener( ProgressEvent.PROGRESS,		this.handler_progress );
						this._sound.addEventListener( Event.COMPLETE,				this.handler_sound_complete );
						this._sound.addEventListener( IOErrorEvent.IO_ERROR,		this.handler_error );
						this._sound.$load( this._request, null ); // TODO: SoundLoaderContext
						break;
					case MIME.ZIP:
						// TODO: ZIP
						break;
					case MIME.TEXT:
					case MIME.HTML:
					case MIME.XML:
					case MIME.BINARY:
					default:
						// усё. стало всё попроще
						this._stream.removeEventListener( ProgressEvent.PROGRESS,	this.handler_stream_init_progress );
						this._stream.removeEventListener( Event.COMPLETE,			this.handler_stream_init_complete );
						this._stream.addEventListener( ProgressEvent.PROGRESS,		this.handler_progress );
						this._stream.addEventListener( Event.COMPLETE,				this.handler_stream_complete );
						break;
				}
			}
			this.handler_progress( event );
		}

		/**
		 * @private
		 */
		private function handler_stream_init_complete(event:Event):void {
			var bytesTotal:uint = this._input.length;
			this.clear_stream();	// закрываем поток
			// данные закончились, а мы так и не знали, что у нас тут за дерьмо
			this._contentType = MIME.analyseURL( this._request.url );
			switch ( this._contentType ) {
				case MIME.FLASH:
				case MIME.PNG:
				case MIME.JPEG:
				case MIME.GIF:
					this._loader = new LoaderAsset();
					loaderInfo.addEventListener( ProgressEvent.PROGRESS,		this.handler_progress,			false, int.MAX_VALUE );
					loaderInfo.addEventListener( Event.COMPLETE,				this.handler_loader_complete,	false, int.MAX_VALUE );
					loaderInfo.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_error,				false, int.MAX_VALUE );
					loaderInfo.addEventListener( Event.INIT,					this.handler_loader_init,		false, int.MAX_VALUE );
					this._loader.$loadBytes( this._input, this._loaderContext ); // TODO: если ошибка, то адо сделать бинарником
					this.clear_input();
					break;
				case MIME.MP3:
					this._sound = new SoundAsset();
					this._sound.addEventListener( ProgressEvent.PROGRESS,		this.handler_progress );
					this._sound.addEventListener( Event.COMPLETE,				this.handler_sound_complete );
					this._sound.addEventListener( IOErrorEvent.IO_ERROR,		this.handler_error );
					this._sound.$load( this._request, null ); // TODO: SoundLoaderContext, extract
					this.clear_input();
					break;
				case MIME.ZIP:
					// TODO: ZIP
					break;
				case MIME.VARS:
				case MIME.CSS:
				case MIME.TEXT:
				case MIME.HTML:
				case MIME.RSS:
				case MIME.XML:
					enterFrameBroadcaster.removeEventListener(Event.ENTER_FRAME, this.handler_enterFrame);
					this._input.position = 0;
					this._content = this._input.readUTFBytes( this._input.length ); // TODO: вдруг не текст?
					this.clear_input();
					super.dispatchEvent( new Event( Event.INIT ) );
					this.updateProgress(bytesTotal, bytesTotal);
					this._state = _STATE_COMPLETE;
					super.dispatchEvent( event );
					break;
				case MIME.BINARY:
					enterFrameBroadcaster.removeEventListener(Event.ENTER_FRAME, this.handler_enterFrame);
					this._input.position = 0;
					this._content = this._input;
					this._input = null;
					super.dispatchEvent( new Event( Event.INIT ) );
					this.updateProgress(bytesTotal, bytesTotal);
					this._state = _STATE_COMPLETE;
					super.dispatchEvent( event );
					break;
				default:
					// а вот хз, что это
					enterFrameBroadcaster.removeEventListener(Event.ENTER_FRAME, this.handler_enterFrame);
					this._input.position = 0;
					try { // попытаемся узреть в нём текст
						this._content = this._input.readUTFBytes( this._input.length );
						this._contentType = MIME.TEXT;
						this.clear_input();
					} catch ( e:Error ) { // не вышло :(
						this._content = this._input;
						this._input = null;
					}
					super.dispatchEvent( new Event( Event.INIT ) );
					this.updateProgress(bytesTotal, bytesTotal);
					this._state = _STATE_COMPLETE;
					super.dispatchEvent( event );
			}
		}

		/**
		 * @private
		 */
		private function handler_stream_init_securityError(event:SecurityErrorEvent):void {
			this.clear_stream();	// закрываем поток
			this.clear_input();
			// опа :( нам это низя прочитать. ну что ж ... давайте попробуем по расширению узнать что это цаца
			var type:String = MIME.analyseURL( this._request.url ) || MIME.BINARY; // пытаемся узнать что за говно мы грузим
			this._contentType = type;
			switch ( this._contentType ) {
				case MIME.FLASH:
				case MIME.PNG:
				case MIME.JPEG:
				case MIME.GIF:
					this._loader = new LoaderAsset();
					var loaderInfo:LoaderInfo = this._loader.contentLoaderInfo;
					loaderInfo.addEventListener( Event.OPEN,					super.dispatchEvent,			false, int.MAX_VALUE );
					loaderInfo.addEventListener( HTTPStatusEvent.HTTP_STATUS,	super.dispatchEvent,			false, int.MAX_VALUE );
					loaderInfo.addEventListener( ProgressEvent.PROGRESS,		this.handler_progress,			false, int.MAX_VALUE );
					loaderInfo.addEventListener( Event.COMPLETE,				this.handler_loader_complete,	false, int.MAX_VALUE );
					loaderInfo.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_error,				false, int.MAX_VALUE );
					loaderInfo.addEventListener( Event.INIT,					this.handler_loader_init,		false, int.MAX_VALUE );
					this._loader.$load( this._request, this._loaderContext );
					break;
				case MIME.MP3:
					this._sound = new SoundAsset();
					this._sound.addEventListener( Event.OPEN,					super.dispatchEvent );
					this._sound.addEventListener( ProgressEvent.PROGRESS,		this.handler_progress );
					this._sound.addEventListener( Event.COMPLETE,				this.handler_sound_complete );
					this._sound.addEventListener( IOErrorEvent.IO_ERROR,		this.handler_error );
					this._sound.$load( this._request, null ); // TODO: SoundLoaderContext
					break;
				default:
					// усё. пипец
					this.handler_error( event );
					break;
			}
		}

		//----------------------------------
		//  stream
		//----------------------------------

		/**
		 * @private
		 */
		private function handler_stream_complete(event:Event):void {
			// мы знаем кто нам нужен. нужно просто вычитать всё что там лежит
			var bytesTotal:uint = this._input.length;
			enterFrameBroadcaster.removeEventListener(Event.ENTER_FRAME, this.handler_enterFrame);
			this._stream.readBytes( this._input, this._input.length );
			this.clear_stream();
			this._input.position = 0;
			switch ( this._contentType ) {
				case MIME.TEXT:
				case MIME.HTML:
				case MIME.XML:
					this._content = this._input.readUTFBytes( this._input.length );
					this.clear_input();
					break; 
				case MIME.BINARY:
				default:
					this._content = this._input;
					this._input = null;
					break;
			}
			super.dispatchEvent( new Event( Event.INIT ) );
			this._state = _STATE_COMPLETE;
			this.updateProgress(bytesTotal, bytesTotal);
			super.dispatchEvent( event );
		}

		//----------------------------------
		//  loader
		//----------------------------------

		/**
		 * @private
		 */
		private function handler_loader_init(event:Event):void {

			this._loaderInfo = this._loader.contentLoaderInfo;

			var content:DisplayObject = this._loader.$content;

			_JUNK.addChild( content );
			_JUNK.removeChild( content );

			switch ( this.contentType ) {
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
		private function handler_loader_complete(event:Event):void {
			enterFrameBroadcaster.removeEventListener(Event.ENTER_FRAME, this.handler_enterFrame);
			this.updateProgress(this._loader.contentLoaderInfo.bytesLoaded, this._loader.contentLoaderInfo.bytesTotal);
			this.clear_loader( false );
			this._state = _STATE_COMPLETE;
			super.dispatchEvent( event );
		}

		//----------------------------------
		//  sound
		//----------------------------------

		/**
		 * @private
		 */
		private function handler_sound_complete(event:Event):void {
			enterFrameBroadcaster.removeEventListener(Event.ENTER_FRAME, this.handler_enterFrame);
			this.updateProgress(this._sound.bytesLoaded, this._sound.bytesTotal);
			this._content = this._sound;
			this.clear_sound( false );
			super.dispatchEvent( new Event( Event.INIT ) );
			this._state = _STATE_COMPLETE;
			super.dispatchEvent( event );
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.net.HeuristicLoader;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.errors.IllegalOperationError;
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.getTimer;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: LoaderAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 * 
 * необходим, что бы при попытки обратится через различные ссылки, типа loaderInfo,
 * свойства были перекрыты
 */
internal final class LoaderAsset extends Loader {

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
	private static var _gcCallTime:uint = getTimer();

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor
	 */
	public function LoaderAsset(target:HeuristicLoader=null) {
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
	private var _target:HeuristicLoader;

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
		throw new IllegalOperationError();
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
		throw new IllegalOperationError();
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
		throw new IllegalOperationError();
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
		throw new IllegalOperationError();
	}

	/**
	 * @private
	 */
	internal function $unload():void {
		var time:uint = getTimer();
		if ( _gcCallTime < time + _GC_CALL_TIMEOUT ) {
			_gcCallTime = time;
			super.unloadAndStop( true );
		} else {
			super.unloadAndStop( false );
		}
	}

	[Deprecated(message="метод запрещен", replacement="$unload")]
	/**
	 * @private
	 */
	public override function unloadAndStop(gc:Boolean=true):void {
		throw new IllegalOperationError();
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

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: SoundAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 * 
 * необходим, что бы при попытки обратится через различные ссылки
 * свойства были перекрыты
 */
internal final class SoundAsset extends Sound {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor
	 */
	public function SoundAsset(target:HeuristicLoader=null) {
		if ( !true ) { // суки из адобы, вызывают load в любом случаи. идиоты.
			super();
		}
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
	private var _target:HeuristicLoader;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	[Deprecated(message="метод запрещен", replacement="$load")]
	/**
	 * @private
	 */
	public override function load(request:URLRequest, context:SoundLoaderContext=null):void {
		throw new IllegalOperationError();
	}

	/**
	 * @private
	 */
	internal function $load(request:URLRequest, context:SoundLoaderContext=null):void {
		super.load( request, context );
	}

	/**
	 * @private
	 */
	public override function close():void {
		if ( this._target ) {
			this._target.close();
		} else {
			if ( super.bytesLoaded < super.bytesTotal ) {
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