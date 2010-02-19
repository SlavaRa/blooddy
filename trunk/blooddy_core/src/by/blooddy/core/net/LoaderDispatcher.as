////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.managers.IProgressable;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
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
	 * @inheritDoc
	 */
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]

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
	public class LoaderDispatcher extends EventDispatcher implements ILoadable, IProgressable {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 * Constructor
		 *
		 * @param	enabled			Включать ли по умолчанию лоадер.
		 *
		 * @see						#enabled
		 */
		public function LoaderDispatcher() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Includes
		//
		//--------------------------------------------------------------------------

		include "../../../../includes/override_EventDispatcher.as"

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
		private const _loaders:Vector.<ILoadable> = new Vector.<ILoadable>();

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoadable
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  loaded
		//----------------------------------

		/**
		 * @private
		 */
		private var _loaded:Boolean = true;

		/**
		 * @copy					by.blooddy.core.net.ILoadable#loaded
		 */
		public function get loaded():Boolean {
			return this._loaded;
		}

		//----------------------------------
		//  bytesLoaded
		//----------------------------------

		/**
		 * @private
		 */
		private var _bytesLoaded:uint = 0;

		/**
		 * @copy					by.blooddy.core.net.ILoadable#bytesLoaded
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
		 * @copy					by.blooddy.core.net.ILoadable#bytesTotal
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

		public function get progress():Number {
			return this._progress;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: ILoaderDispatcher
		//
		//--------------------------------------------------------------------------

		public function addLoaderListener(loader:ILoadable):void {
			this.$addLoaderListener( loader );
		}

		public function removeLoaderListener(loader:ILoadable):void {
			this.$removeLoaderListener( loader );
		}

		public function hasLoaderListener(loader:ILoadable):Boolean {
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
		private function $addLoaderListener(loader:ILoadable):void {
			if ( this._loaders.indexOf( loader ) >= 0 ) return; // проверим. может какой-то баран уже дабавил нас сюда.

			if ( !loader.loaded ) {
				loader.addEventListener( Event.COMPLETE,					this.updateLoaded );
				loader.addEventListener( ProgressEvent.PROGRESS,			this.toProgress );
				loader.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
				loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
			}
			loader.addEventListener( Event.UNLOAD,							this.handler_unload );

			this._loaders.push( loader );

			this._toLoaders = true;
			this._loaded = this._loaded && loader.loaded;
			if ( this._loaded ) {
				this.updateComplete();
			} else {
				this.toProgress();
			}
		}

		/**
		 * @private
		 */
		private function $removeLoaderListener(loader:ILoadable, update:Boolean=true):void {
			loader.removeEventListener( Event.COMPLETE,						this.updateLoaded );
			loader.removeEventListener( ProgressEvent.PROGRESS,				this.toProgress );
			loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
			loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
			loader.removeEventListener( Event.UNLOAD,						this.handler_unload );

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
				if ( loader.loaded ) loaded++;
			}
			this._loadersLoaded = loaded;
		}

		/**
		 * @private
		 */
		private function updateLoaded(event:Event=null):void {
			this._loaded = true;
			for each ( var loader:ILoadable in this._loaders ) {
				if ( !loader.loaded ) {
					this._loaded = false;
					break;
				}
			}
			if ( this._loaded ) {
				this.updateComplete();
			} else {
				this.toProgress();
			}
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
					progress += loader.bytesLoaded / loader.bytesTotal;
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
			this.updateProgress();
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
			if ( super.hasEventListener( event.type ) ) {
				if ( event is IOErrorEvent ) {
					super.dispatchEvent( new EventContainer( new IOErrorEventAsset( event.target, event.type, event.bubbles, event.cancelable, event.text ) ) );
				}
			}
			this.handler_unload( event );
		}

		/**
		 * @private
		 */
		private function handler_unload(event:Event):void {
			this.$removeLoaderListener( event.target as ILoadable );
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.events.Event;
import flash.events.IOErrorEvent;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: EventContainer
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 * 
 * Является контэйнером, для евента.
 * Хук, для того, что бы передать нормальный таргет средствами стандартного EventDispatcher'а.
 */
internal final class EventContainer extends Event {

	//--------------------------------------------------------------------------
	//
	//  Private class constants
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static const TARGET:Object = new Object();

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
		 * Constructor
	 */
	public function EventContainer(event:Event) {
		super( event.type, event.bubbles, event.cancelable );
		this._event = event;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _event:Event;

	//--------------------------------------------------------------------------
	//
	//  Overridden properties: Event
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Возвращает левый таргет, для того что бы обмануть EventDispatcher.
	 */
	public override function get target():Object {
		return TARGET;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Event
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Возвращаем наш евент.
	 */
	public override function clone():Event {
		return this._event;
	}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: IOErrorEventAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Класс прослойка для создания события бублинга.
 * Происходит переопределения target.
 * 
 * @author					BlooDHounD
 * @version					1.0
 * @playerversion			Flash 9
 * @langversion				3.0
 */
internal final class IOErrorEventAsset extends IOErrorEvent {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
		 * Constructor
	 */
	public function IOErrorEventAsset(target:Object, type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String="") {
		super( type, bubbles, cancelable, text );
		this._target = target;
	}

	//--------------------------------------------------------------------------
	//
	//  Overriden properties: Event
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  target
	//----------------------------------

	/**
	 * @private
	 */
	private var _target:Object;

	/**
	 * @private
	 * Сцылка на таргет.
	 */
	public override function get target():Object {
		return this._target || super.target;
	}

	//--------------------------------------------------------------------------
	//
	//  Overriden methods: Event
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public override function clone():Event {
		return new IOErrorEventAsset( this._target, super.type, super.bubbles, super.cancelable );
	}

}