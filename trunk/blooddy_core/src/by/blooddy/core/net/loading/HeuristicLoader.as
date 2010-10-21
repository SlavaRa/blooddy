////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {

	import by.blooddy.core.net.MIME;
	import by.blooddy.core.utils.dispose;
	import by.blooddy.core.utils.net.copyURLRequest;
	
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
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
	public class HeuristicLoader extends LoaderBase {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected_load;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _ERROR_LOADER:RegExp = /^Error #2124:/;

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
		public function HeuristicLoader(request:URLRequest=null, loaderContext:by.blooddy.core.net.loading.LoaderContext=null) {
			super();
			this._loaderContext = loaderContext;
			if ( request ) this.load( request );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _request:URLRequest;
		
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

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoader
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  uri
		//----------------------------------
		
		/**
		 * @inheritDoc
		 */
		public override function get url():String {
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
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$protected_load override function $load(request:URLRequest):void {
			this._request = copyURLRequest( request );
			// определяем первоначальны контэнт по расширению
			this._contentType = MIME.analyseURL( this._request.url );
			switch ( this._contentType ) {

				case MIME.FLASH:
				case MIME.PNG:
				case MIME.JPEG:
				case MIME.GIF:	// для отображаемых типов сразу же пытаемся использовать обычный Loader
					this._loader = this.create_loader( true, true );
					this._loader.load( this._request );
					break;

				default:		// для остальных используем загрузку через stream
					this._input = new ByteArray();
					this._stream = this.create_stream( true, !_URL || _URL.test( this._request.url ) );
					this._stream.load( this._request );
					break;

			}
		}

		/**
		 * @private
		 */
		$protected_load override function $loadBytes(bytes:ByteArray):void {
			var bytesTotal:uint = bytes.length;
			switch ( this._contentType ) {
				
				case MIME.FLASH:
				case MIME.PNG:
				case MIME.JPEG:
				case MIME.GIF:
					this._loader = this.create_loader();
					this._loader.loadBytes( bytes );
					break;
				
				case MIME.MP3:
					this._sound = this.create_sound();
					this._sound.loadBytes( bytes );
					break;
				
				case MIME.ZIP:
					// TODO: ZIP
					break;
				
				case MIME.BINARY:
					this._content = bytes;
					if ( super.hasEventListener( Event.INIT ) ) {
						super.dispatchEvent( new Event( Event.INIT ) );
					}
					super.updateProgress( bytesTotal, bytesTotal );
					super.completeHandler( new Event( Event.COMPLETE ) );
					break;
				
				default:
					// а вот хз, что это
					try { // попытаемся узреть в нём текст
						this._content = ( bytes.length > 0
							?	bytes.readUTFBytes( bytes.length )
							:	''
						);
						this._contentType = MIME.TEXT;
						this.clear_input();
					} catch ( e:* ) { // не вышло :(
						this._contentType = MIME.BINARY;
						this._content = bytes;
					}
					
					if ( super.hasEventListener( Event.INIT ) ) {
						super.dispatchEvent( new Event( Event.INIT ) );
					}
					super.updateProgress( bytesTotal, bytesTotal );
					super.completeHandler( new Event( Event.COMPLETE ) );
					break;
				
			}
		}

		/**
		 * @private
		 */
		$protected_load override function $unload():Boolean {
			var unload:Boolean = Boolean( this._content || this._stream || this._loader || this._sound || this._input );
			this.clear_asset();
			this._request = null;
			if ( this._content ) {
				dispose( this._content );
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
		 * создаёт URLStream для загрузки
		 */
		private function create_stream(open:Boolean=false, progress:Boolean=false):flash.net.URLStream {
			var result:flash.net.URLStream = new flash.net.URLStream();
			if ( open ) {
				result.addEventListener( Event.OPEN,					super.dispatchEvent );
			}
			result.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
			if ( _HTTP_RESPONSE_STATUS ) {
				result.addEventListener( _HTTP_RESPONSE_STATUS,			super.dispatchEvent );
			}
			if ( progress ) { // если беда с доменами, то пытаемся выебнуться
				result.addEventListener( ProgressEvent.PROGRESS,		this.handler_stream_init_progress );
			} else {
				result.addEventListener( ProgressEvent.PROGRESS,		super.progressHandler );
			}
			result.addEventListener( Event.COMPLETE,					this.handler_stream_init_complete );
			result.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_common_error );
			result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_stream_init_securityError );
			return result;
		}

		/**
		 * @private
		 * создаёт лоадер для загрузки
		 */
		private function create_loader(url:Boolean=false, open:Boolean=false):LoaderAsset {
			var result:LoaderAsset = new LoaderAsset( this._loaderContext );
			result._target = this;
			if ( open ) {	// событие уже могло быть послано
				result.addEventListener( Event.OPEN,					super.dispatchEvent );
			}
			result.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
			result.addEventListener( ProgressEvent.PROGRESS,			super.progressHandler );
			result.addEventListener( Event.INIT,						this.handler_loader_init );
			result.addEventListener( Event.COMPLETE,					this.handler_common_complete );
			if ( url ) { // если загрущик инитиализатор, то загрузка идёт по урлу
				result.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_loader_url_ioError );
			} else {
				result.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_loader_input_ioError );
			}
			result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_common_error );
			return result;
		}

		/**
		 * @private
		 */
		private function clear_asset():void {
			this.clear_stream();
			this.clear_loader();
			this.clear_sound();
			this.clear_input();
		}
		
		/**
		 * @private
		 * создаём звук для загрузки
		 */
		private function create_sound(open:Boolean=false):SoundAsset {
			var result:SoundAsset = new SoundAsset( this._loaderContext );
			result._target = this;
			if ( open ) {
				result.addEventListener( Event.OPEN,					super.dispatchEvent );
			}
			result.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
			result.addEventListener( ProgressEvent.PROGRESS,			super.progressHandler );
			result.addEventListener( Event.INIT,						this.handler_sound_init );
			result.addEventListener( Event.COMPLETE,					this.handler_common_complete );
			result.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_common_error );
			result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_common_error );
			return result;
		}

		/**
		 * @private
		 * очищает stream
		 */
		private function clear_stream():void {
			if ( this._stream ) {
				this._stream.removeEventListener( Event.OPEN,							super.dispatchEvent );
				this._stream.removeEventListener( HTTPStatusEvent.HTTP_STATUS,			super.dispatchEvent );
				if ( _HTTP_RESPONSE_STATUS ) {
					this._stream.removeEventListener( _HTTP_RESPONSE_STATUS,			super.dispatchEvent );
				}
				this._stream.removeEventListener( ProgressEvent.PROGRESS,				this.handler_stream_init_progress );
				this._stream.removeEventListener( ProgressEvent.PROGRESS,				super.progressHandler );
				this._stream.removeEventListener( Event.COMPLETE,						this.handler_stream_init_complete );
				this._stream.removeEventListener( Event.COMPLETE,						this.handler_stream_complete );
				this._stream.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_common_error );
				this._stream.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_stream_init_securityError );
				try {
					this._stream.close();
				} catch ( e:* ) {
				}
				this._stream = null;
			}
		}

		/**
		 * @private
		 * очищает loader
		 */
		private function clear_loader():void {
			if ( this._loader ) {
				this._loader._target = null;
				this._loader.removeEventListener( Event.OPEN,							super.dispatchEvent );
				this._loader.removeEventListener( HTTPStatusEvent.HTTP_STATUS,			super.dispatchEvent );
				this._loader.removeEventListener( ProgressEvent.PROGRESS,				super.progressHandler );
				this._loader.removeEventListener( Event.INIT,							this.handler_loader_init );
				this._loader.removeEventListener( Event.COMPLETE,						this.handler_common_complete );
				this._loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_loader_url_ioError );
				this._loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_loader_input_ioError );
				this._loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_common_error );
				this._loaderInfo = null;
				if ( this._loader.complete ) {
					this._loader._unload();
				} else {
					this._loader._close();
				}
				this._loader.loaderContext = null;
				this._loader = null;
			}
		}

		/**
		 * @private
		 * очищает sound
		 */
		private function clear_sound():void {
			if ( this._sound ) {
				this._sound._target = null;
				this._sound.removeEventListener( Event.OPEN,						super.dispatchEvent );
				this._sound.removeEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
				this._sound.removeEventListener( ProgressEvent.PROGRESS,			super.progressHandler );
				this._sound.removeEventListener( Event.INIT,						this.handler_sound_init );
				this._sound.removeEventListener( Event.COMPLETE,					this.handler_common_complete );
				this._sound.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_common_error );
				this._sound.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_common_error );
				if ( this._sound.complete ) {
					this._sound._unload();
				} else {
					this._sound._close();
				}
				this._sound.loaderContext = null;
				this._sound = null;
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
		private function handler_common_complete(event:Event):void {
			var bytesTotal:uint = ( event.target as LoaderBase ).bytesTotal;
			super.updateProgress( bytesTotal, bytesTotal );
			super.completeHandler( event );
		}
		
		/**
		 * @private
		 */
		private function handler_common_error(event:ErrorEvent):void {
			this.clear_asset();
			super.completeHandler( event );
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
						this._stream.addEventListener( ProgressEvent.PROGRESS,		super.progressHandler );
						this._stream.addEventListener( Event.COMPLETE,				this.handler_stream_complete );
						break;

				}

			}
			super.progressHandler( event );
		}

		/**
		 * @private
		 * слушает событие complete от stream.
		 * и пытается в процессе, понять, кто же это.
		 * если неудаётся определить по содержанию, запускается механизм определение по расширению.
		 */
		private function handler_stream_init_complete(event:Event):void {
			this._stream.readBytes( this._input, this._input.length );
			this._input.position = 0;
			this.clear_stream();	// закрываем поток
			// данные закончились, а мы так и не знали, что у нас тут за дерьмо
			this._contentType = MIME.analyseBytes( this._input ) || MIME.analyseURL( this._request.url ); // пытаемся узнать что за говно мы грузим
			this.$loadBytes( this._input );
			this._input = null;
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
					this._loader.load( this._request );
					break;

				case MIME.MP3:
					this._sound = this.create_sound( true );
					this._sound.load( this._request );
					break;

				default:
					// усё. пипец
					super.completeHandler( event );
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
					} catch ( e:* ) {
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
			super.updateProgress( bytesTotal, bytesTotal );
			super.completeHandler( event );
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
		 * слушает событие ioError у loader.
		 * если оно срабатывается, значит мы грузим не swf.
		 */
		private function handler_loader_url_ioError(event:IOErrorEvent):void {
			this.clear_loader();
			if ( _ERROR_LOADER.test( event.text ) ) {
				this._input = new ByteArray();
				this._stream = this.create_stream( false, !_URL || _URL.test( this._request.url ) );
				this._stream.load( this._request );
			} else {
				super.completeHandler( event );
			}
		}

		/**
		 * @private
		 * слушает событие ioError у loader.
		 * если оно срабатывается, значит мы грузим не swf.
		 */
		private function handler_loader_input_ioError(event:IOErrorEvent):void {
			this.clear_loader();
			if ( _ERROR_LOADER.test( event.text ) ) {
				// загрузка не прошла. пробуем сделать из этой пижни бинарник
				this._input.position = 0;
				try { // попытаемся узреть в нём текст
					this._content = ( this._input.length > 0
						?	this._input.readUTFBytes( this._input.length )
						:	''
					);
					this._contentType = MIME.TEXT;
					this.clear_input();
				} catch ( e:* ) { // не вышло :(
					this._contentType = MIME.BINARY;
					this._content = this._input;
					this._input = null;
				}
				if ( super.hasEventListener( Event.INIT ) ) {
					super.dispatchEvent( new Event( Event.INIT ) );
				}
				super.updateProgress( bytesTotal, bytesTotal );
				super.completeHandler( new Event( Event.COMPLETE ) );
			} else {
				super.completeHandler( event );
			}
		}

		//----------------------------------
		//  sound
		//----------------------------------

		/**
		 * @private
		 */
		private function handler_sound_init(event:Event):void {
			this._content = this._sound.content;
			if ( super.hasEventListener( Event.INIT ) ) {
				super.dispatchEvent( event );
			}
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.net.loading.HeuristicLoader;
import by.blooddy.core.net.loading.Loader;
import by.blooddy.core.net.loading.LoaderContext;
import by.blooddy.core.net.loading.SoundLoader;

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
	public function LoaderAsset(loaderContext:LoaderContext) {
		super( null, loaderContext );
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	internal var _target:HeuristicLoader;

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
	public override function unload():void {
		this._target.unload();
	}

	//--------------------------------------------------------------------------
	//
	//  Internal methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	internal function _close():void {
		super.close();
	}

	/**
	 * @private
	 */
	internal function _unload():void {
		super.unload();
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
	public function SoundAsset(loaderContext:LoaderContext) {
		super( null, loaderContext );
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	internal var _target:HeuristicLoader;

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
	public override function unload():void {
		this._target.unload();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Internal methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	internal function _close():void {
		super.close();
	}

	/**
	 * @private
	 */
	internal function _unload():void {
		super.unload();
	}
	
}