////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.display.dispose;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
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
	import flash.media.SoundLoaderContext;
	import flash.media.SoundMixer;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;

	//--------------------------------------
	//  Implements events: ILoadable
	//--------------------------------------

	/**
	 * @inheritDoc
	 */
	[Event( name="complete", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]
	
	/**
	 * @inheritDoc
	 */
	[Event( name="open", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="progress", type="flash.events.ProgressEvent" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="unload", type="flash.events.Event" )]

	//--------------------------------------
	//  Implements events: ILoader
	//--------------------------------------

	/**
	 * @inheritDoc
	 */
	[Event( name="httpStatus", type="flash.events.HTTPStatusEvent" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="init", type="flash.events.Event" )]

	/**
	 * @inheritDoc
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
	public class HeuristicLoader extends EventDispatcher implements ILoader {

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
		private static const _URL:RegExp = ( _DOMAIN == 'localhost' ? null : new RegExp( '^((?!\w+://)|https?://(www\.)?' + _DOMAIN.replace( /\./g, '\\.' ) + ')', 'i' ) );

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
		public function HeuristicLoader(request:URLRequest=null, loaderContext:by.blooddy.core.net.LoaderContext=null) {
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
		 * @inheritDoc
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
		 * @inheritDoc
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
		 * @inheritDoc
		 */
		public function get bytesTotal():uint {
			return this._bytesTotal;
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
		 * @inheritDoc
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
					this._loader = this.create_loader( true, true, true );
					this._loader.load( this._request );
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
		 * @inheritDoc
		 */
		public function loadBytes(bytes:ByteArray):void {
			throw new IllegalOperationError(); // TODO: дописать
		}

		/**
		 * @inheritDoc
		 */
		public function close():void {
			if ( this._state != _STATE_PROGRESS ) throw new ArgumentError();
			this.clear();
		}

		/**
		 * @inheritDoc
		 */
		public function unload():void {
			if ( this._state <= _STATE_PROGRESS ) throw new ArgumentError();
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
		private function create_loader(url:Boolean=false, open:Boolean=false, security:Boolean=false):LoaderAsset {
			var result:LoaderAsset = new LoaderAsset( this );
			result.loaderContext = this._loaderContext;
			if ( open ) {	// событие уже могло быть послано
				result.addEventListener( Event.OPEN,					super.dispatchEvent );
			}
			result.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
			result.addEventListener( ProgressEvent.PROGRESS,			this.handler_progress );
			result.addEventListener( Event.INIT,						this.handler_loader_init );
			result.addEventListener( Event.COMPLETE,					this.handler_loader_complete );
			result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
			if ( url ) { // если загрущик инитиализатор, то загрузка идёт по урлу
				result.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_loader_url_ioError );
			} else {
				result.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_loader_input_ioError );
			}
			return result;
		}

		/**
		 * @private
		 * создаём звук для загрузки
		 */
		private function create_sound(open:Boolean=false):SoundAsset {
			var result:SoundAsset = new SoundAsset( this );
			result.loaderContext = this._loaderContext;
			if ( open ) {
				result.addEventListener( Event.OPEN,					super.dispatchEvent );
			}
			result.addEventListener( ProgressEvent.PROGRESS,			this.handler_progress );
			result.addEventListener( Event.COMPLETE,					this.handler_sound_complete );
			result.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
			result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
			return result;
		}

		/**
		 * @private
		 * очисщает данные
		 */
		private function clear():void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
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
				this._loader.removeEventListener( Event.OPEN,					super.dispatchEvent );
				this._loader.removeEventListener( HTTPStatusEvent.HTTP_STATUS,	super.dispatchEvent );
				this._loader.removeEventListener( ProgressEvent.PROGRESS,		this.handler_progress );
				this._loader.removeEventListener( Event.INIT,					this.handler_loader_init );
				this._loader.removeEventListener( Event.COMPLETE,				this.handler_loader_complete );
				this._loader.removeEventListener( IOErrorEvent.IO_ERROR,		this.handler_loader_url_ioError );
				this._loader.removeEventListener( IOErrorEvent.IO_ERROR,		this.handler_loader_input_ioError );
				if ( unload ) {
					this._loaderInfo = null;
					if ( this._loader.loaded ) {
						this._loader.$unload();
					} else {
						this._loader.$close();
					}
					this._loader.loaderContext = null;
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
				this._sound.removeEventListener( Event.OPEN,						super.dispatchEvent );
				this._sound.removeEventListener( ProgressEvent.PROGRESS,			this.handler_progress );
				this._sound.removeEventListener( Event.COMPLETE,					this.handler_sound_complete );
				this._sound.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
				this._sound.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
				if ( unload ) {
					if ( this._sound.loaded ) {
						this._sound.unload();
					} else {
						this._sound.$close();
					}
					this._sound.loaderContext = null;
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
						this._loader = this.create_loader( true );
						this._loader.load( this._request );
						break;

					case MIME.MP3:
						this.clear_stream();	// закрываем поток
						this.clear_input();
						this._sound = this.create_sound();
						this._sound.load( this._request );
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
					this._loader.loadBytes( this._input );
					break;

				case MIME.MP3:
					this._sound = this.create_sound();
					//this._sound.loadBytes( this._input ); // TODO: не забыть включить
					this._sound.load( this._request );
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
					this._loader = this.create_loader( true, true, true );
					this._loader.load( this._request );
					break;

				case MIME.MP3:
					this._sound = this.create_sound( true );
					this._sound.load( this._request );
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
		 * обычная инитиализация loader.
		 */
		private function handler_loader_init(event:Event):void {

			this._loaderInfo = this._loader.loaderInfo;
			this._contentType = this._loader.contentType;
			this._content = this._loader.content;
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
			this.updateProgress( this._loader.bytesLoaded, this._loader.bytesTotal );
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
			this._content = this._sound.content;
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

import by.blooddy.core.media.SoundLoader;
import by.blooddy.core.net.HeuristicLoader;
import by.blooddy.core.net.Loader;

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
		super.unload();
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
internal final class SoundAsset extends SoundLoader {

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
	//  Methods
	//
	//--------------------------------------------------------------------------

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