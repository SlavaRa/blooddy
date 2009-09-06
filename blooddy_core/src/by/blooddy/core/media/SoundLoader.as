package by.blooddy.core.media {

	import by.blooddy.core.net.ILoader;
	
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;

	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;

	//--------------------------------------
	//  Implements events: ILoader
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
	[Event( name="open", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="progress", type="flash.events.ProgressEvent" )]

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
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	request			Если надо, то сразу передадим и начнётся загрузка.
		 * @param	loaderContext	Если надо грузить, то возможно пригодится.
		 */
		public function SoundLoader(request:URLRequest=null, loaderContext:SoundLoaderContext=null) {
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
		private var _sound:Sound;

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
			return ( this._sound ? this._sound.url : "" );
		}

		//----------------------------------
		//  loaded
		//----------------------------------

		/**
		 * @private
		 */
		private var _loaded:Boolean = false;

		/**
		 * @inheritDoc
		 */
		public function get loaded():Boolean {
			return false;
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
		//  sound
		//----------------------------------

		/**
		 * 
		 */
		public function get sound():Sound {
			return this._sound;
		}

		//----------------------------------
		//  loaderContext
		//----------------------------------

		/**
		 * @private
		 */
		private var _loaderContext:SoundLoaderContext;

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
		public function get loaderContext():SoundLoaderContext {
			return this._loaderContext;
		}

		/**
		 * @private
		 */
		public function set loaderContext(value:SoundLoaderContext):void {
			if (this._loaderContext === value) return;
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
			this.clearVariables();
			this._sound = new Sound();
			this.registerEventHandlers( this._sound );
			this._sound.load(request, this._loaderContext);
		}

		/**
		 * @inheritDoc
		 */
		public function close():void {
			if (!this._sound) throw new ArgumentError();
			this._sound.close();
			this.unregisterEventHandlers( this._sound );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function registerEventHandlers(sound:Sound):void {
			sound.addEventListener(Event.COMPLETE, this.handler_complete, false, int.MAX_VALUE);
			sound.addEventListener(Event.OPEN, this.handler_redirect, false, int.MAX_VALUE);
			sound.addEventListener(IOErrorEvent.IO_ERROR, this.handler_error, false, int.MAX_VALUE);
			sound.addEventListener(ProgressEvent.PROGRESS, this.handler_progress, false, int.MAX_VALUE);
			sound.addEventListener(Event.ID3, this.handler_redirect, false, int.MAX_VALUE);
		}

		/**
		 * @private
		 */
		private function unregisterEventHandlers(sound:Sound):void {
			sound.removeEventListener(Event.COMPLETE, this.handler_complete);
			sound.removeEventListener(Event.OPEN, this.handler_redirect);
			sound.removeEventListener(IOErrorEvent.IO_ERROR, this.handler_error);
			sound.removeEventListener(ProgressEvent.PROGRESS, this.handler_progress);
			sound.removeEventListener(Event.ID3, this.handler_redirect);
		}

		/**
		 * @private
		 */
		private function clearVariables():void {
			this._bytesLoaded = 0;
			this._bytesTotal = 0;
			this.unregisterEventHandlers( this._sound );
			if (this._sound) {
				try {
					this._sound.close();
				} catch (e:Error) {
				}
			}	
			this._sound = null;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			this.unregisterEventHandlers( event.target as Sound );
			if ( this._sound !== event.target ) return;
			this._loaded = true;
			super.dispatchEvent( event );
		}

		/**
		 * @private
		 */
		private function handler_progress(event:ProgressEvent):void {
			if ( event.target !== this._sound ) {
				this.unregisterEventHandlers( event.target as Sound );
				return;
			}
			this._bytesLoaded = event.bytesLoaded;
			this._bytesTotal = event.bytesTotal;
			super.dispatchEvent( event );
		}

		/**
		 * @private
		 */
		private function handler_error(event:Event):void {
			this.unregisterEventHandlers( event.target as Sound );
			if ( event.target !== this._sound ) return;
			
			super.dispatchEvent( event );
		}

		/**
		 * @private
		 */
		private function handler_redirect(event:Event):void {
			if ( event.target !== this._sound ) {
				this.unregisterEventHandlers( event.target as Sound );
				return;
			}
			super.dispatchEvent( event );
		}

	}

}