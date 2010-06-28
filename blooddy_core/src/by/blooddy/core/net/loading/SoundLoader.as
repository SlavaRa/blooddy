////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {

	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

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
	 * 
	 * @see						flash.media.Sound
	 */
	public class SoundLoader extends LoaderBase {

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
			return ( this._sound && this._sound.$inited ? this._sound : null );
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
			if ( !super.isIdle() ) throw new ArgumentError();
			this._loaderContext = value;
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
			this._sound = this.create_sound();
			this._sound.$load( request, this.create_soundLoaderContext() );
		}

		/**
		 * @private
		 */
		$protected_load override function $loadBytes(bytes:ByteArray):void {
			Error.throwError( IllegalOperationError, 2014 );
		}

		/**
		 * @private
		 */
		$protected_load override function $unload():Boolean {
			var unload:Boolean = Boolean( this._sound );
			this.clear_sound();
			return unload;
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
		private function create_sound():SoundAsset {
			var result:SoundAsset = new SoundAsset( this );
			result.addEventListener( Event.OPEN,						super.dispatchEvent );
			result.addEventListener( Event.ID3,							super.dispatchEvent );
			result.addEventListener( ProgressEvent.PROGRESS,			this.progressHandler );
			result.addEventListener( Event.COMPLETE,					this.handler_sound_complete );
			result.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_sound_error );
			result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_sound_error );
			return result;
		}
		
		/**
		 * @private
		 * очищает sound
		 */
		private function clear_sound():void {
			if ( this._sound ) {
				this._sound.removeEventListener( Event.OPEN,						super.dispatchEvent );
				this._sound.removeEventListener( Event.ID3,							super.dispatchEvent );
				this._sound.removeEventListener( ProgressEvent.PROGRESS,			this.progressHandler );
				this._sound.removeEventListener( ProgressEvent.PROGRESS,			super.progressHandler );
				this._sound.removeEventListener( Event.COMPLETE,					this.handler_sound_complete );
				this._sound.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_sound_error );
				this._sound.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_sound_error );
				try {
					this._sound.$close();
				} catch ( e:Error ) {
				}
				for ( var o:Object in this._sound.$hash ) {
					( o as SoundChannel ).stop();
					delete this._sound.$hash[ o ];
				}
				this._sound.$inited = false;
				this._sound = null;
			}
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

		$protected_load override function progressHandler(event:ProgressEvent):void {
			super.progressHandler( event );
			if ( this._sound.isBuffering && !this._sound.$inited ) {
				this._sound.$inited = true;
				this._sound.removeEventListener( ProgressEvent.PROGRESS,	this.progressHandler );
				this._sound.addEventListener( ProgressEvent.PROGRESS,		super.progressHandler );
				if ( super.hasEventListener( Event.INIT ) ) {
					super.dispatchEvent( new Event( Event.INIT ) );
				}
			}
		}
		
		/**
		 * @private
		 * обработка загрузки звука.
		 */
		private function handler_sound_complete(event:Event):void {
			var bytesTotal:uint = this._sound.bytesLoaded;
			super.updateProgress( bytesLoaded, bytesLoaded );
			if ( !this._sound.$inited && super.hasEventListener( Event.INIT ) ) {
				this._sound.$inited = true;
				super.dispatchEvent( new Event( Event.INIT ) );
			}
			super.completeHandler( event );
		}
		
		/**
		 * @private
		 */
		private function handler_sound_error(event:ErrorEvent):void {
			this.clear_sound();
			super.completeHandler( event );
		}
		
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.net.loading.SoundLoader;

import flash.errors.IOError;
import flash.errors.IllegalOperationError;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundLoaderContext;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

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
	internal var $inited:Boolean = false;
	
	/**
	 * @private
	 */
	internal var $hash:Dictionary = new Dictionary( true );
	
	/**
	 * @private
	 */
	private var _target:SoundLoader;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	public override function play(startTime:Number=0, loops:int=0, sndTransform:SoundTransform=null):SoundChannel {
		if ( !this.$inited ) throw new IOError(); 
		var channel:SoundChannel = super.play( startTime, loops, sndTransform );
		this.$hash[ channel ] = true;
		return channel;
	}

	[Deprecated( message="метод запрещен", replacement="$load" )]
	/**
	 * @private
	 */
	public override function load(request:URLRequest, context:SoundLoaderContext=null):void {
		Error.throwError( IllegalOperationError, 1001, 'load' );
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
		Error.throwError( IllegalOperationError, 1001, 'extract' );
		return 0;
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