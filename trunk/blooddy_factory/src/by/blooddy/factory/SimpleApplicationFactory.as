////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.factory {

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.errors.InvalidSWFError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.system.ApplicationDomain;
	import flash.text.TextSnapshot;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @see		flash.display.Stage#resize 
	 */
	[Event( name="resize", type="flash.events.Event" )]
	
	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="property", name="name" )]
	[Exclude( kind="property", name="parent" )]
	[Exclude( kind="property", name="root" )]
	[Exclude( kind="property", name="stage" )]
	[Exclude( kind="property", name="doubleClickEnabled" )]
	[Exclude( kind="property", name="focusRect" )]
	[Exclude( kind="property", name="mouseEnabled" )]
	[Exclude( kind="property", name="tabEnabled" )]
	[Exclude( kind="property", name="tabIndex" )]
	[Exclude( kind="property", name="buttonMode" )]
	[Exclude( kind="property", name="hitArea" )]
	[Exclude( kind="property", name="useHandCursor" )]
	[Exclude( kind="property", name="soundTransform" )]

	[Exclude( kind="method", name="startDrag" )]
	[Exclude( kind="method", name="stopDrag" )]
	[Exclude( kind="method", name="addFrameScript" )]
	[Exclude( kind="method", name="gotoAndPlay" )]
	[Exclude( kind="method", name="gotoAndStop" )]
	[Exclude( kind="method", name="play" )]
	[Exclude( kind="method", name="stop" )]
	[Exclude( kind="method", name="nextFrame" )]
	[Exclude( kind="method", name="nextScene" )]
	[Exclude( kind="method", name="prevFrame" )]
	[Exclude( kind="method", name="prevScene" )]

	/**
	 * Создатель приложения.
	 * 
	 * Может присутвовать только у запускаемого приложения.
	 * Подключаемые модули не могут иметь SimpleApplicationFactory.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * @created					25.03.2010 23:56:43
	 * 
	 * @keyword					applicationfactory, application, factory
	 */
	public class SimpleApplicationFactory extends MovieClip {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var inited:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function SimpleApplicationFactory(rootClassName:String=null) {
			super();

			super.mouseEnabled = false;
			super.tabEnabled = false;
			super.enabled = false;

			super.stop();

			// сохраним наш класс для дальнейшей работы
			this._rootClassName = rootClassName;

			super.addEventListener( Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MAX_VALUE );

		}

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {

			super.removeEventListener( Event.ADDED_TO_STAGE, this.handler_addedToStage );

			if ( inited ) {
				throw new ReferenceError( '' );
			} else if ( super.totalFrames != 2 || super.currentFrame != 1 )  {
				throw new ReferenceError( '' );
			} else if ( super.parent is Loader ) {
				var c:Class = ( super.parent as Loader ).loaderInfo.applicationDomain.getDefinition( 'by.blooddy.factory::ApplicationFactoryLoader' ) as Class;
				if ( c || !( super.parent.parent is c ) ) throw new ReferenceError( '' ); 
			} else if ( super.parent != super.stage ) {
				throw new ReferenceError( '' );
			}
	
			inited = true;

			super.addEventListener( Event.REMOVED_FROM_STAGE, this.handler_removedFromStage, false, int.MAX_VALUE );

			super.loaderInfo.addEventListener( Event.COMPLETE, this.handler_complete );
			super.loaderInfo.addEventListener( IOErrorEvent.IO_ERROR, this.handler_ioError );

		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _rootClassName:String;

		//----------------------------------
		//  stageWidth
		//----------------------------------

		/**
		 * @see		flash.display.Stage#stageWidth
		 */
		public final function get stageWidth():Number {
			return super.stage.stageWidth;
		}

		//----------------------------------
		//  stageHeight
		//----------------------------------

		/**
		 * @see		flash.display.Stage#stageHeight
		 */
		public final function get stageHeight():Number {
			return super.stage.stageHeight;
		}

		//----------------------------------
		//  stageAlign
		//----------------------------------
		
		/**
		 * @see		flash.display.Stage#align
		 */
		public final function get stageAlign():String {
			return super.stage.align;
		}

		/**
		 * @private
		 */
		public final function set stageAlign(value:String):void {
			super.stage.align = value;
		}
		
		//----------------------------------
		//  stageScaleMode
		//----------------------------------
		
		/**
		 * @see		flash.display.Stage#scaleMode
		 */
		public final function get stageScaleMode():String {
			return super.stage.scaleMode;
		}
		
		/**
		 * @private
		 */
		public final function set stageScaleMode(value:String):void {
			super.stage.scaleMode = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected function initialize():void {

			// надо получить имя рутового класса
			var rootClassName:String = this._rootClassName;

			var appd:ApplicationDomain = super.loaderInfo.applicationDomain;
			if ( !rootClassName ) {
				rootClassName = ( super.currentScene.labels.pop() as FrameLabel ).name.replace( /_(?=[^_]$)/, '::' ).replace( /_/g, '.' );
				if ( !appd.hasDefinition( rootClassName ) ) rootClassName = null;
			}
			if ( !rootClassName ) {
				rootClassName = super.loaderInfo.url.match( /[^\\\/]*?(?=(\.[^\.]*)?$)/ )[0] as String;
				if ( !appd.hasDefinition( rootClassName ) ) rootClassName = null;
			}
			var Root:Class = appd.getDefinition( rootClassName ) as Class;
			if ( Root ) {
				// вернём stage где был
				var stage:Stage = super.stage;
				if ( DisplayObject.prototype.isPrototypeOf( Root.prototype ) ) {
					// сделаем рут
					$root = new Root();
					stage.addChild( $root as DisplayObject );
				} else {
					$root = new Root( stage );
				}
				// удалим себя
				super.removeEventListener( Event.REMOVED_FROM_STAGE, this.handler_removedFromStage );
				if ( super.parent is Loader ) ( new Sprite() ).addChild( this ); // стараемся для FactoryLoader
				else super.parent.removeChild( this );

			} else {
				throw new InvalidSWFError(); // TODO: описать ошибку
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
		private function handler_complete(event:Event):void {
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			loaderInfo.removeEventListener( Event.COMPLETE, this.handler_complete );
			loaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, this.handler_ioError );
			super.nextFrame();
			this.initialize();
		}

		/**
		 * @private
		 * прерывает все загрузки и выкидывает исключение
		 */
		private function handler_ioError(event:IOErrorEvent):void {
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			loaderInfo.removeEventListener( Event.COMPLETE, this.handler_complete );
			loaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, this.handler_ioError );
			if ( !loaderInfo.hasEventListener( event.type ) ) {
				loaderInfo.dispatchEvent( event );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  DisplayObject
		//----------------------------------

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function set name(value:String):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство запрещено" )]
		/**
		 * @private
		 */
		public override final function get parent():DisplayObjectContainer {
			return null;
		}

		[Deprecated( message="свойство запрещено" )]
		/**
		 * @private
		 */
		public override final function get root():DisplayObject {
			return null;
		}

		[Deprecated( message="свойство запрещено" )]
		/**
		 * @private
		 */
		public override final function get stage():Stage {
			return null;
		}

		//----------------------------------
		//  InteractiveObject
		//----------------------------------

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function set doubleClickEnabled(enabled:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function set focusRect(focusRect:Object):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function set mouseEnabled(enabled:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function set tabEnabled(enabled:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function set tabIndex(index:int):void {
			throw new IllegalOperationError();
		}

		//----------------------------------
		//  DisplayObjectContainer
		//----------------------------------

		/**
		 * @private
		 */
		public override final function get textSnapshot():TextSnapshot {
			return null;
		}

		//----------------------------------
		//  Sprite
		//----------------------------------

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function set buttonMode(value:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function set hitArea(value:Sprite):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function set useHandCursor(value:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function set soundTransform(sndTransform:SoundTransform):void {
			throw new IllegalOperationError();
		} 

		//----------------------------------
		//  MovieClip
		//----------------------------------

		/**
		 * @private
		 */
		public override final function get currentFrame():int {
			return 1;
		}

		/**
		 * @private
		 */
		public override final function get currentLabel():String {
			return null;
		}

		/**
		 * @private
		 */
		public override final function get currentLabels():Array {
			return new Array();
		}

		/**
		 * @private
		 */
		public override final function get currentScene():Scene {
			return null;
		}

		/**
		 * @private
		 */
		public override final function get framesLoaded():int {
			return 0;
		}

		/**
		 * @private
		 */
		public override final function get scenes():Array {
			return new Array();
		}

		/**
		 * @private
		 */
		public override final function get totalFrames():int {
			return 0;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  EventDispatcher
		//----------------------------------

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function dispatchEvent(event:Event):Boolean {
			throw new IllegalOperationError();
		}

		public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			if ( type == Event.RESIZE ) {
				super.stage.addEventListener( type, listener, useCapture, priority, useWeakReference );
			} else {
				super.addEventListener( type, listener, useCapture, priority, useWeakReference );
			}
		}
		
		public override function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			if ( type == Event.RESIZE ) {
				super.stage.addEventListener( type, listener, useCapture );
			} else {
				super.addEventListener( type, listener, useCapture );
			}
		}

		public override function hasEventListener(type:String):Boolean {
			if ( type == Event.RESIZE ) {
				return super.stage.hasEventListener( type );
			}
			return super.hasEventListener( type );
		}

		public override function willTrigger(type:String):Boolean {
			if ( type == Event.RESIZE ) {
				return super.stage.willTrigger( type );
			}
			return super.willTrigger( type );
		}
		
		//----------------------------------
		//  Sprite
		//----------------------------------

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function startDrag(lockCenter:Boolean=false, bounds:Rectangle=null):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function stopDrag():void {
			throw new IllegalOperationError();
		}

		//----------------------------------
		//  MovieClip
		//----------------------------------

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function addFrameScript(...args):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function gotoAndPlay(frame:Object, scene:String=null):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function gotoAndStop(frame:Object, scene:String=null):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function play():void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function stop():void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function nextFrame():void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function nextScene():void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function prevFrame():void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throw	IllegalOperationError
		 */
		public override final function prevScene():void {
			throw new IllegalOperationError();
		}

	}

}

internal var $root:Object;
