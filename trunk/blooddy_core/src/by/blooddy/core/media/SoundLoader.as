////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.media {

	import by.blooddy.core.net.ILoader;
	import by.blooddy.core.net.LoaderContext;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
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
	
	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Транслируется, когда загружаются ID3 тэги.
	 * 
	 * @eventType			flash.events.Event.ID3
	 */
	[Event( name="id3", type="flash.events.Event" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					sound
	 */
	public class SoundLoader extends EventDispatcher implements ILoader {

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
		public function SoundLoader(request:URLRequest=null, loaderContext:LoaderContext=null) {
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
		private var _sound:SoundAsset;

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
		//  Implements properties: ILoader
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  url
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get url():String {
			return ( this._sound ? this._sound.url : '' );
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

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  content
		//----------------------------------

		/**
		 * 
		 */
		public function get content():Sound {
			return this._sound;
		}

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
		 * 
		 * @default					null
		 * 
		 * @keyword					sound.loadercontext, loadercontext
		 * 
		 * @see						flash.media.SoundLoaderContext
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

		//--------------------------------------------------------------------------
		//
		//  Implements methods: ILoader
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function load(request:URLRequest):void {
			if ( this._state != _STATE_IDLE ) throw new ArgumentError();
			//else if ( this._state > _STATE_PROGRESS ) this.clear();
			this._state = _STATE_PROGRESS;

			this._sound = this.create_sound( true );
			this._sound.$load( request, this.create_soundLoaderContext() );

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
		 * создаём звук для загрузки
		 */
		private function create_sound(open:Boolean=false):SoundAsset {
			var result:SoundAsset = new SoundAsset( this );
			if ( open ) {
				result.addEventListener( Event.OPEN,					super.dispatchEvent );
			}
			result.addEventListener( Event.ID3,							super.dispatchEvent );
			result.addEventListener( ProgressEvent.PROGRESS,			this.handler_progress );
			result.addEventListener( Event.COMPLETE,					this.handler_complete );
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
			var unload:Boolean = Boolean( this._sound );
			this.clear_sound();
			this._bytesLoaded = 0;
			this._bytesTotal = 0;
			this._state = _STATE_IDLE;
			if ( unload && super.hasEventListener( Event.UNLOAD ) ) {
				super.dispatchEvent( new Event( Event.UNLOAD ) );
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
				this._sound.removeEventListener( Event.COMPLETE,					this.handler_complete );
				this._sound.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
				this._sound.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
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
		 * обвновление прогресса
		 */
		private function updateProgress(bytesLoaded:uint, bytesTotal:uint):void {
			this._bytesLoaded = bytesLoaded;
			this._bytesTotal = bytesTotal;
			super.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this._bytesLoaded, this._bytesTotal ) );
		}
		
		/**
		 * @private
		 */
		private function create_soundLoaderContext():SoundLoaderContext {
			if (
				this._loaderContext &&
				this._loaderContext.checkPolicyFile
			) {
				return new SoundLoaderContext( SoundMixer.bufferTime, this._loaderContext.checkPolicyFile );
			}
			return null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

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
		
		/**
		 * @private
		 * обработка загрузка звука.
		 */
		private function handler_complete(event:Event):void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this.updateProgress( this._sound.bytesLoaded, this._sound.bytesTotal );
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
import by.blooddy.core.media.SoundLoader;

import flash.errors.IllegalOperationError;
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.net.URLRequest;
import flash.utils.ByteArray;

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
	public function SoundAsset(target:SoundLoader) {
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
	private var _target:SoundLoader;
	
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
	internal function $load(request:URLRequest, context:SoundLoaderContext=null):void {
		super.load( request, context );
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