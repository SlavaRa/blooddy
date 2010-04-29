////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {

	import by.blooddy.core.utils.enterFrameBroadcaster;
	import by.blooddy.core.utils.nextframeCall;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.Dictionary;

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
	[Event( name="progress", type="flash.events.ProgressEvent" )]

	/**
	 * Класс предназначен для мониторинга процесса загрузки
	 * нескольких файлов одновременно.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					loaderdispatcher, loader, dispatcher
	 */
	public class LoaderDispatcher extends EventDispatcher implements IProcessable, IProgressable {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 * Constructor
		 */
		public function LoaderDispatcher() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _toProgress:Boolean = false;

		/**
		 * @private
		 */
		private var _toLoaders:Boolean = false;

		/**
		 * @private
		 */
		private const _loaders:Vector.<IProcessable> = new Vector.<IProcessable>();

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoadable
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  complete
		//----------------------------------

		/**
		 * @private
		 */
		private var _complete:Boolean = true;

		/**
		 * @inheritDoc
		 */
		public function get complete():Boolean {
			return this._complete;
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
		//  loadersLoaded
		//----------------------------------

		/**
		 * @private
		 */
		private var _loadersLoaded:uint = 0;

		public function get loadersLoaded():uint {
			if ( this._toLoaders ) {
				this.updateLoaders();
			}
			return this._loadersLoaded;
		}

		//----------------------------------
		//  loadersTotal
		//----------------------------------

		/**
		 * @private
		 */
		private var _loadersTotal:uint = 0;

		public function get loadersTotal():uint {
			if ( this._toLoaders ) {
				this.updateLoaders();
			}
			return this._loadersTotal;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties: IProgressable
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _progress:Number = 1;

		/**
		 * @inheritDoc
		 */
		public function get progress():Number {
			return this._progress;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: ILoaderDispatcher
		//
		//--------------------------------------------------------------------------

		public function addLoaderListener(loader:IProcessable):void {
			this.$addLoaderListener( loader );
		}

		public function removeLoaderListener(loader:IProcessable):void {
			this.$removeLoaderListener( loader );
		}

		public function hasLoaderListener(loader:IProcessable):Boolean {
			return ( this._loaders.indexOf( loader ) >= 0 );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function close():void {
			while ( this._loaders.length > 0 ) {
				this.$removeLoaderListener( this._loaders[ this._loaders.length - 1 ] as ILoadable, false );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function $addLoaderListener(loader:IProcessable):void {
			if ( this._loaders.indexOf( loader ) >= 0 ) return; // проверим. может какой-то баран уже дабавил нас сюда.

			// подписываем с минимальными приоритетом. мы контэйнер, и должны отработать последними
			if ( !loader.complete ) {
				loader.addEventListener( Event.COMPLETE,						this.updateLoaded, false, int.MIN_VALUE );
				loader.addEventListener( ErrorEvent.ERROR,						this.handler_error, false, int.MIN_VALUE );
				if ( loader is ILoadable ) {
					loader.addEventListener( ProgressEvent.PROGRESS,			this.toProgress, false, int.MIN_VALUE );
				}
			}
			if ( loader is ILoader ) {
				loader.addEventListener( Event.UNLOAD,							this.handler_error, false, int.MIN_VALUE );
			}

			this._loaders.push( loader );

			this._toLoaders = true;
			this._complete = this._complete && loader.complete;
			nextframeCall( this.updateComplete );
		}

		/**
		 * @private
		 */
		private function $removeLoaderListener(loader:IProcessable, update:Boolean=true):void {
			loader.removeEventListener( Event.COMPLETE,						this.updateLoaded );
			loader.removeEventListener( ProgressEvent.PROGRESS,				this.toProgress );
			loader.removeEventListener( ErrorEvent.ERROR,					this.handler_error );
			loader.removeEventListener( Event.UNLOAD,						this.handler_error );

			var index:int = this._loaders.lastIndexOf( loader );
			if ( index < 0 ) return; // надо удалить, если такой присутвует...
			this._loaders.splice( index, 1 );

			if ( update ) {
				this._toLoaders = true;
				this.updateLoaded();
			}

		}

		/**
		 * @private
		 */
		private function updateLoaders():void {
			this._toLoaders = false;
			var arr:Vector.<ILoadable> = new Vector.<ILoadable>();
			var hash:Dictionary = new Dictionary();
			hash[ this ] = true;
			this.getUniqLoaders( arr, hash );
			this._loadersTotal = arr.length;
			var loaded:uint = 0;
			for each ( var loader:ILoadable in arr ) {
				if ( loader.complete ) loaded++;
			}
			this._loadersLoaded = loaded;
		}

		/**
		 * @private
		 */
		private function updateLoaded(event:Event=null):void {
			this._complete = true;
			for each ( var loader:ILoadable in this._loaders ) {
				if ( !loader.complete ) {
					this._complete = false;
					break;
				}
			}
			nextframeCall( this.updateComplete );
		}

		/**
		 * @private
		 */
		private function updateProgress(event:Event=null):void {
			this._toProgress = false;
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.updateProgress );
			var loaded:uint;
			var total:uint;
			var progress:Number = 0;
			var i:uint = 0;
			for each ( var loader:ILoadable in this._loaders ) {
				if ( loader.bytesTotal > 0 ) {
					loaded += loader.bytesLoaded;
					total += loader.bytesTotal;
					progress += loader.progress;
				}
				i++;
			}
			this._progress = ( i > 0 ? progress / i : 1 );
			this._bytesLoaded = loaded;
			this._bytesTotal = total;
			super.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this._bytesLoaded, this._bytesTotal ) );
		}

		/**
		 * @private
		 */
		private function toProgress(event:Event=null):void {
			if ( !this._toProgress ) {
				this._toProgress = true;
				enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.updateProgress );
			}
		}

		/**
		 * @private
		 */
		private function updateComplete():void {
			this.toProgress();
			if ( !this._complete ) return;
			// загрузилось всё. чистимся и вызываемся.
			var loader:ILoadable;
			while ( this._loaders.length > 0 ) {
				this.$removeLoaderListener( this._loaders[ this._loaders.length - 1 ] as ILoadable, false );
			}
			super.dispatchEvent( new Event( Event.COMPLETE ) );
		}

		/**
		 * @private
		 */
		private function getUniqLoaders(target:Vector.<ILoadable>, hash:Dictionary):void {
			for each ( var loader:ILoadable in this._loaders ) {
				if ( !( loader in hash ) ) {
					hash[ loader ] = true;
					if ( loader is LoaderDispatcher ) {
						( loader as LoaderDispatcher ).getUniqLoaders( target, hash );
					} else {
						target.push( loader );
					}
				}
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
		private function handler_error(event:ErrorEvent):void {
			this.$removeLoaderListener( event.target as ILoadable );
		}

	}

}