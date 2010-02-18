////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.display.dispose;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.errors.InvalidSWFError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLStream;
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

	/**
	 * @copy					by.blooddy.core.net.ILoadable#progress
	 */
	[Event( name="unload", type="flash.events.Event" )]

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
		private static const _ERROR_LOADER:RegExp = /^Error #2124:/;

		/**
		 * @private
		 */
		private static const _DOMAIN:String = ( new flash.net.LocalConnection() ).domain;

		/**
		 * @private
		 */
		private static const _URL:RegExp = ( _DOMAIN == 'localhost' ? null : new RegExp( '^https?://(www\.)?' + _DOMAIN.replace( /\./g, '\\.' ), 'i' ) );

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
		 * то они продолжают сюда грузится
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
			if ( this._loaderContext === value ) return;
			if ( this._state != _STATE_IDLE ) throw new ArgumentError();
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

		//----------------------------------
		//  contentType
		//----------------------------------

		/**
		 * @private
		 */
		private var _contentType:String;

		/**
		 * MIME-type загруженного содержания
		 */
		public function get contentType():String {
			return this._contentType;
		}

		//----------------------------------
		//  url
		//----------------------------------

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

		//----------------------------------
		//  bytesLoaded
		//----------------------------------

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

		//----------------------------------
		//  bytesTotal
		//----------------------------------

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

		//----------------------------------
		//  loaded
		//----------------------------------
		
		/**
		 * загрузился ли уже файл?
		 */
		public function get loaded():Boolean {
			return this._state >= _STATE_COMPLETE;
		}
		
		//----------------------------------
		//  content
		//----------------------------------

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

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

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

			this._request = copyURLRequest( request );

			// определяем первоначальны контэнт по расширению
			this._contentType = MIME.analyseURL( this._request.url );
			switch ( this._contentType ) {

				case MIME.FLASH:
				case MIME.PNG:
				case MIME.JPEG:
				case MIME.GIF:	// для отображаемых типов сразу же пытаемся использовать обычный Loader
					this._loader = this.create_loader( true, true );
					this._loader.$load( this._request, this._loaderContext );
					break;

				default:		// для остальных используем загрузку через stream
					this._input = new ByteArray();
					this._stream = this.create_stream( true, !_URL || _URL.test( this._request.url ) );
					this._stream.load( this._request );
					break;

			}
			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
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
		 * создаёт URLStream для загрузки
		 */
		private function create_stream(open:Boolean=false, progress:Boolean=false):flash.net.URLStream {
			var result:flash.net.URLStream = new flash.net.URLStream();
			if ( open ) {
				result.addEventListener( Event.OPEN,					super.dispatchEvent );
			}
			result.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
			if ( progress ) { // если беда с доменами, то пытаемся выебнуться
				result.addEventListener( ProgressEvent.PROGRESS,		this.handler_stream_init_progress );
			} else {
				result.addEventListener( ProgressEvent.PROGRESS,		this.handler_progress );
			}
			result.addEventListener( Event.COMPLETE,					this.handler_stream_init_complete );
			result.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
			result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_stream_init_securityError );
			return result;
		}

		/**
		 * @private
		 * создаёт лоадер для загрузки
		 */
		private function create_loader(open:Boolean=false, security:Boolean=false):LoaderAsset {
			var result:LoaderAsset = new LoaderAsset( this );
			var li:LoaderInfo = result.$loaderInfo;
			if ( open ) {	// событие уже могло быть послано
				li.addEventListener( Event.OPEN,				super.dispatchEvent,				false, int.MAX_VALUE );
			}
			li.addEventListener( HTTPStatusEvent.HTTP_STATUS,	super.dispatchEvent,				false, int.MAX_VALUE );
			li.addEventListener( ProgressEvent.PROGRESS,		this.handler_progress,				false, int.MAX_VALUE );
			if ( security ) { // с подозрением на секурность, используем расширенный обработчик
				li.addEventListener( Event.INIT,				this.handler_loader_security_init,	false, int.MAX_VALUE );
			} else {
				li.addEventListener( Event.INIT,				this.handler_loader_init,			false, int.MAX_VALUE );
			}
			li.addEventListener( Event.COMPLETE,				this.handler_loader_complete,		false, int.MAX_VALUE );
			if ( open ) { // если загрущик инитиализатор, то загрузка идёт по урлу
				li.addEventListener( IOErrorEvent.IO_ERROR,		this.handler_loader_url_ioError,	false, int.MAX_VALUE );
			} else {
				li.addEventListener( IOErrorEvent.IO_ERROR,		this.handler_loader_input_ioError,	false, int.MAX_VALUE );
			}
			return result;
		}

		/**
		 * @private
		 * создаём звук для загрузки
		 */
		private function create_sound(open:Boolean=false):SoundAsset {
			var result:SoundAsset = new SoundAsset( this );
			if ( open ) {
				result.addEventListener( Event.OPEN,			super.dispatchEvent );
			}
			result.addEventListener( ProgressEvent.PROGRESS,	this.handler_progress );
			result.addEventListener( Event.COMPLETE,			this.handler_sound_complete );
			result.addEventListener( IOErrorEvent.IO_ERROR,		this.handler_error );
			return result;
		}


		/**
		 * @private
		 * очисщает данные
		 */
		private function clear():void {
			var unload:Boolean = Boolean( this._content || this._stream || this._loader || this._sound );
			this.clear_stream();
			this.clear_loader();
			this.clear_sound();
			this.clear_input();
			this._request = null;
			this._bytesLoaded = 0;
			this._bytesTotal = 0;
			if ( this._content ) {
				if ( this._content is DisplayObject ) {
					var d:DisplayObject = this._content as DisplayObject;
					_JUNK.addChild( d );
					_JUNK.removeChild( d );
					dispose( d );
				} else if ( this._content is BitmapData ) {
					( this._content as BitmapData ).dispose();
				} else if ( this._content is ByteArray ) {
					( this._content as ByteArray ).clear();
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
				var li:LoaderInfo = this._loader.$loaderInfo;
				li.removeEventListener( Event.OPEN,						super.dispatchEvent );
				li.removeEventListener( HTTPStatusEvent.HTTP_STATUS,	super.dispatchEvent );
				li.removeEventListener( ProgressEvent.PROGRESS,			this.handler_progress );
				li.removeEventListener( Event.COMPLETE,					this.handler_loader_complete );
				li.removeEventListener( Event.COMPLETE,					this.handler_loader_security_complete );
				li.removeEventListener( IOErrorEvent.IO_ERROR,			this.handler_loader_url_ioError );
				li.removeEventListener( IOErrorEvent.IO_ERROR,			this.handler_loader_input_ioError );
				li.removeEventListener( Event.INIT,						this.handler_loader_init );
				li.removeEventListener( Event.INIT,						this.handler_loader_security_init );
				if ( unload ) {
					this._loaderInfo = null;
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

		/**
		 * @private
		 * обвновление прогресса
		 */
		private function updateProgress(bytesLoaded:uint, bytesTotal:uint):void {
			this._bytesLoaded = bytesLoaded;
			this._bytesTotal = bytesTotal;
			super.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this._bytesLoaded, this._bytesTotal ) );
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
		 * слушает прогресс, и обвноляет его, если _frameReady установлен в true.
		 */
		private function handler_progress(event:ProgressEvent):void {
			if ( !this._frameReady ) return;
			this._frameReady = false;
			this.updateProgress( event.bytesLoaded, event.bytesTotal );
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
		 * слушает ошибки
		 */
		private function handler_error(event:ErrorEvent):void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this._state = _STATE_ERROR;
			super.dispatchEvent( event );
		}

		//----------------------------------
		//  stream init
		//----------------------------------

		/**
		 * @private
		 * слушает событие progress от stream.
		 * и пытается в процессе, понять, кто же это.
		 * при успешном определение меняет поведение загрузки.
		 */
		private function handler_stream_init_progress(event:ProgressEvent):void {
			this._stream.readBytes( this._input, this._input.length );
			this._contentType = MIME.analyseBytes( this._input ); // пытаемся узнать что за говно мы грузим
			if ( this._contentType ) {
				switch ( this._contentType ) {

					case MIME.FLASH:
					case MIME.PNG:
					case MIME.JPEG:
					case MIME.GIF:
						this.clear_stream();	// закрываем поток
						this.clear_input();
						this._loader = this.create_loader();
						this._loader.$load( this._request, this._loaderContext );
						break;

					case MIME.MP3:
						this.clear_stream();	// закрываем поток
						this.clear_input();
						this._sound = this.create_sound();
						this._sound.$load( this._request, this._loaderContext );
						break;

					case MIME.ZIP:
						// TODO: ZIP
						//break;

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
		 * слушает событие complete от stream.
		 * и пытается в процессе, понять, кто же это.
		 * если неудаётся определить по содержанию, запускается механизм определение по расширению.
		 */
		private function handler_stream_init_complete(event:Event):void {
			this._stream.readBytes( this._input, this._input.length );
			var bytesTotal:uint = this._input.length;
			this.clear_stream();	// закрываем поток
			// данные закончились, а мы так и не знали, что у нас тут за дерьмо
			this._contentType = MIME.analyseBytes( this._input ) || MIME.analyseURL( this._request.url ); // пытаемся узнать что за говно мы грузим
			switch ( this._contentType ) {

				case MIME.FLASH:
				case MIME.PNG:
				case MIME.JPEG:
				case MIME.GIF:
					this._loader = this.create_loader();
					this._loader.$loadBytes( this._input, this._loaderContext );
					break;

				case MIME.MP3:
					this._sound = this.create_sound();
					this._sound.$load( this._request, this._loaderContext );
					this.clear_input();
					break;

				case MIME.ZIP:
					// TODO: ZIP
					break;

				case MIME.BINARY:
					enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
					this._input.position = 0;
					this._content = this._input;
					this._input = null;
					if ( super.hasEventListener( Event.INIT ) ) {
						super.dispatchEvent( new Event( Event.INIT ) );
					}
					this.updateProgress( bytesTotal, bytesTotal );
					this._state = _STATE_COMPLETE;
					super.dispatchEvent( event );
					break;

				case MIME.VARS:
				case MIME.CSS:
				case MIME.TEXT:
				case MIME.HTML:
				case MIME.RSS:
				case MIME.XML:
					var isText:Boolean = true;

				default:
					// а вот хз, что это
					enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
					this._input.position = 0;
					try { // попытаемся узреть в нём текст
						this._content = ( this._input.length > 0
							?	this._input.readUTFBytes( this._input.length )
							:	''
						);
						this._contentType = MIME.TEXT;
						this.clear_input();
					} catch ( e:Error ) { // не вышло :(
						this._contentType = MIME.BINARY;
						this._content = this._input;
						this._input = null;
					}
					if ( super.hasEventListener( Event.INIT ) ) {
						super.dispatchEvent( new Event( Event.INIT ) );
					}
					this.updateProgress( bytesTotal, bytesTotal );
					this._state = _STATE_COMPLETE;
					super.dispatchEvent( event );
					break;

			}
		}

		/**
		 * @private
		 * слушает событие securityError от stream.
		 * так как загрузка на этом заканчивается, мы прежмепринимает отчаенную попытку определения содержания по расширению.
		 */
		private function handler_stream_init_securityError(event:SecurityErrorEvent):void {
			this.clear_stream();	// закрываем поток
			this.clear_input();
			// опа :( нам это низя прочитать. ну что ж ... давайте попробуем по расширению узнать что это цаца
			this._contentType = MIME.analyseURL( this._request.url ) || MIME.BINARY; // пытаемся узнать что за говно мы грузим
			switch ( this._contentType ) {

				case MIME.FLASH:
				case MIME.PNG:
				case MIME.JPEG:
				case MIME.GIF:
					this._loader = this.create_loader( true, true );
					this._loader.$load( this._request, this._loaderContext );
					break;

				case MIME.MP3:
					this._sound = this.create_sound( true );
					this._sound.$load( this._request, this._loaderContext );
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
		 * загрузились бинарные данные.
		 */
		private function handler_stream_complete(event:Event):void {
			// мы знаем кто нам нужен. нужно просто вычитать всё что там лежит
			var bytesTotal:uint = this._input.length;
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this._stream.readBytes( this._input, this._input.length );
			this.clear_stream();
			this._input.position = 0;
			switch ( this._contentType ) {

				case MIME.TEXT:
				case MIME.HTML:
				case MIME.RSS:
				case MIME.XML:
					try {
						this._content = ( this._input.length > 0
							?	this._input.readUTFBytes( this._input.length )
							:	''
						);
						this.clear_input();
						break;
					} catch ( e:Error ) {
						this._contentType = MIME.BINARY;
					}

				default:
					this._content = this._input;
					this._input = null;
					break;

			}
			if ( super.hasEventListener( Event.INIT ) ) {
				super.dispatchEvent( new Event( Event.INIT ) );
			}
			this._state = _STATE_COMPLETE;
			this.updateProgress( bytesTotal, bytesTotal );
			super.dispatchEvent( event );
		}

		//----------------------------------
		//  loader
		//----------------------------------

		/**
		 * @private
		 * произошла инитиализация loader.
		 * если вдруг происходит ошибка SecurityError, то переключаемся в режим байтовой загрузки. 
		 */
		private function handler_loader_security_init(event:Event):void {
			try {

				this._loader.$content;
				this.handler_loader_init( event );

			} catch ( e:SecurityError ) {

				var li:LoaderInfo = this._loader.$loaderInfo;
				this._contentType = li.contentType;
				li.removeEventListener( Event.COMPLETE, this.handler_loader_complete );
				li.addEventListener( Event.COMPLETE, this.handler_loader_security_complete );

			}
		}

		/**
		 * @private
		 * вызывается, если произошло SecurityError в handler_loader_security_init.
		 */
		private function handler_loader_security_complete(event:Event):void {
			var loader:LoaderAsset = this.create_loader();
			loader.$loadBytes( this._loader.$loaderInfo.bytes, this._loaderContext );
			this.clear_loader();	// очищаем старый лоадер
			this._loader = loader;	// записываем новый
		}

		/**
		 * @private
		 * обычная инитиализация loader.
		 */
		private function handler_loader_init(event:Event):void {

			this._loaderInfo = this._loader.$loaderInfo;

			var content:DisplayObject = this._loader.$content; // получаем контэнт.

			_JUNK.addChild( content ); // хачим его.
			_JUNK.removeChild( content );

			if ( this._contentType != this._loader.$loaderInfo.contentType ) { // если они не равны, то протикала загрузка через loadBytes.
				// BUGFIX: если грузить каринку черезе loadBytes, то она неправильно обрабатывается, и почему-то кладётся в MovieClip, что нас не устраивает.
				switch ( this._loader.$loaderInfo.contentType ) {
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
			}

			switch ( this._contentType ) {
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
		 * слушает событие complete у loader.
		 */
		private function handler_loader_complete(event:Event):void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this.updateProgress( this._loader.$loaderInfo.bytesLoaded, this._loader.$loaderInfo.bytesTotal );
			this.clear_loader( false );
			this._state = _STATE_COMPLETE;
			super.dispatchEvent( event );
		}

		/**
		 * @private
		 * слушает событие ioError у loader.
		 * если оно срабатывается, значит мы грузим не swf.
		 */
		private function handler_loader_url_ioError(event:IOErrorEvent):void {
			if ( _ERROR_LOADER.test( event.text ) ) {
				this.clear_loader();
				this._input = new ByteArray();
				this._stream = this.create_stream( false, !_URL || _URL.test( this._request.url ) );
				this._stream.load( this._request );
			} else {
				this.handler_error( event );
			}
		}

		/**
		 * @private
		 * слушает событие ioError у loader.
		 * если оно срабатывается, значит мы грузим не swf.
		 */
		private function handler_loader_input_ioError(event:IOErrorEvent):void {
			if ( _ERROR_LOADER.test( event.text ) ) {
				this.clear_loader();
				// загрузка не прошла. пробуем сделать из этой пижни бинарник
				enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
				this._input.position = 0;
				try { // попытаемся узреть в нём текст
					this._content = ( this._input.length > 0
						?	this._input.readUTFBytes( this._input.length )
						:	''
					);
					this._contentType = MIME.TEXT;
					this.clear_input();
				} catch ( e:Error ) { // не вышло :(
					this._contentType = MIME.BINARY;
					this._content = this._input;
					this._input = null;
				}
				if ( super.hasEventListener( Event.INIT ) ) {
					super.dispatchEvent( new Event( Event.INIT ) );
				}
				this.updateProgress( bytesTotal, bytesTotal );
				this._state = _STATE_COMPLETE;
				super.dispatchEvent( new Event( Event.COMPLETE ) );
			} else {
				this.handler_error( event );
			}
		}

		//----------------------------------
		//  sound
		//----------------------------------

		/**
		 * @private
		 * обработка загрузка звука.
		 */
		private function handler_sound_complete(event:Event):void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this.updateProgress( this._sound.bytesLoaded, this._sound.bytesTotal );
			this._content = this._sound;
			this.clear_sound( false );
			if ( super.hasEventListener( Event.INIT ) ) {
				super.dispatchEvent( new Event( Event.INIT ) );
			}
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

import by.blooddy.core.errors.getErrorMessage;
import by.blooddy.core.net.HeuristicLoader;

import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.media.SoundMixer;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.getTimer;

/**
 * @private
 * сюда складываются контенты от Loader'ов
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
	public function LoaderAsset(target:HeuristicLoader) {
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
	private var _target:HeuristicLoader;

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
		var time:uint = getTimer();
		if ( _gcCallTime < time + _GC_CALL_TIMEOUT ) {
			_gcCallTime = time;
			super.unloadAndStop( true );
		} else {
			super.unloadAndStop( false );
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
	public function SoundAsset(target:HeuristicLoader) {
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

	[Deprecated( message="метод запрещен", replacement="$load" )]
	/**
	 * @private
	 */
	public override function load(request:URLRequest, context:SoundLoaderContext=null):void {
		throw new IllegalOperationError( getErrorMessage( 2071, this ), 2071 );
	}

	/**
	 * @private
	 */
	internal function $load(request:URLRequest, context:LoaderContext=null):void {
		super.load( request, ( context ? new SoundLoaderContext( SoundMixer.bufferTime, context.checkPolicyFile ) : null ) );
	}

	[Deprecated( message="метод запрещен" )]
	/**
	 * @private
	 */
	public override function extract(target:ByteArray, length:Number, startPosition:Number=-1):Number {
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

}