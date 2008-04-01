////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 BlooDHounD.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.factory {

	import flash.errors.IOError;
	import flash.errors.IllegalOperationError;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Scene;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	import flash.net.URLRequest;

	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	import flash.utils.getQualifiedClassName;
	import flash.text.TextSnapshot;
	import flash.ui.ContextMenu;

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude(name="name", kind="property")]
	[Exclude(name="stage", kind="property")]
	[Exclude(name="parent", kind="property")]
	[Exclude(name="mouseEnabled", kind="property")]
	[Exclude(name="tabEnabled", kind="property")]
	[Exclude(name="textSnapshot", kind="property")]
	[Exclude(name="buttonMode", kind="property")]
	[Exclude(name="hitArea", kind="property")]
	[Exclude(name="useHandCursor", kind="property")]
	[Exclude(name="currentFrame", kind="property")]
	[Exclude(name="currentLabel", kind="property")]
	[Exclude(name="currentLabels", kind="property")]
	[Exclude(name="currentScene", kind="property")]
	[Exclude(name="framesLoaded", kind="property")]
	[Exclude(name="scenes", kind="property")]

	[Exclude(name="startDrag", kind="method")]
	[Exclude(name="stopDrag", kind="method")]
	[Exclude(name="addFrameScript", kind="method")]
	[Exclude(name="gotoAndPlay", kind="method")]
	[Exclude(name="gotoAndStop", kind="method")]
	[Exclude(name="play", kind="method")]
	[Exclude(name="stop", kind="method")]
	[Exclude(name="nextFrame", kind="method")]
	[Exclude(name="nextScene", kind="method")]
	[Exclude(name="prevFrame", kind="method")]
	[Exclude(name="prevScene", kind="method")]

	/**
	 * Создатель приложения. Покаывает процесс загрузки как самого
	 * приложения так и его библиотек необходимых для инициализации.
	 * 
	 * Может присутвовать только у запускаемого приложения.
	 * Подключаемые модули не могутиметь не могут иметь ApplicationFactory.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					applicationfactory, application, factory
	 */
	public class ApplicationFactory extends MovieClip {

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
		public function ApplicationFactory(rootClassName:String=null) {

			super();

			if ( inited || !super.stage || super.stage != super.parent || super.totalFrames!=2 || super.currentFrame != 1 ) {
				throw new ReferenceError("The " + getQualifiedClassName( ( this as Object ).constructor ) + "" );
			}

			inited = true;

			super.name = getQualifiedClassName( this );
			super.mouseEnabled = false;
			super.tabEnabled = false;
			super.enabled = false;
			super.buttonMode = false;
			super.hitArea = null;
			super.useHandCursor = false;

			super.stop();

			this._stageAlign = super.stage.align;
			this._stageScaleMode = super.stage.scaleMode;

			super.stage.align = StageAlign.TOP_LEFT;
			super.stage.scaleMode = StageScaleMode.NO_SCALE;
			super.stage.addEventListener(Event.RESIZE, this.handler_resize);

			this._context = new LoaderContext( false, super.loaderInfo.applicationDomain );

			// сохраним наш класс для дальнейшей работы
			this._rootClassName = rootClassName;

			// рузим себя
			this.addLoader( super.loaderInfo );

			super.addEventListener(Event.ADDED, this.handler_added_removed, false, int.MAX_VALUE)
			super.addEventListener(Event.ADDED, this.handler_added_removed, true, int.MAX_VALUE)
			super.addEventListener(Event.REMOVED, this.handler_added_removed, false, int.MAX_VALUE)
			super.addEventListener(Event.REMOVED, this.handler_added_removed, true, int.MAX_VALUE)

			this.showPreloader = true;

		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _stageScaleMode:String;

		/**
		 * @private
		 */
		private var _stageAlign:String;

		/**
		 * @private
		 */
		private var _rootClassName:String;

		/**
		 * @private
		 */
		private const _loaded:Array = new Array();

		/**
		 * @private
		 */
		private const _loaders:Array = new Array();

		/**
		 * @private
		 */
		private var _context:LoaderContext;

		/**
		 * @private
		 */
		private var _info:Sprite;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  bytesLoaded
		//----------------------------------

		/**
		 * @private
		 */
		private var _bytesLoaded:uint = 0;

		/**
		 * Количество считанных байт
		 * 
		 * @keyword					applicationfactory.bytesloaded, bytesloaded
		 */
		public final function get bytesLoaded():uint {
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
		 * Всего байт
		 * 
		 * @keyword					applicationfactory.bytestotal, bytestotal
		 */
		public final function get bytesTotal():uint {
			return this._bytesTotal;
		}

		//----------------------------------
		//  loaded
		//----------------------------------

		/**
		 * Загрузились ли мы?
		 * 
		 * @keyword					applicationfactory.loaded, loaded
		 */
		public final function get loaded():Boolean {
			for (var i:uint = 0; i<this._loaders.length; i++) {
				if (!this._loaded[i]) return false;
			}
			return true;
		}

		//----------------------------------
		//  showPreloader
		//----------------------------------

		/**
		 * @private
		 */
		private var _showPreloader:Boolean = false;

		/**
		 * Показывать ли прелоадер?
		 * 
		 * @keyword					applicationfactory.showpreloader, showpreloader
		 */
		public final function get showPreloader():Boolean {
			return this._showPreloader;
		}

		/**
		 * @private
		 */
		public final function set showPreloader(value:Boolean):void {
			if (this._showPreloader==value) return;
			this._showPreloader = value;
			if (this._showPreloader) {
				if (!this._info) {
					this._info = new PreloaderSprite( 0, this._color );
				}
				if ( !super.contains(this._info) ) {
					super.addChildAt( this._info, 0 );
				}
				this.updateInfoPosition();
				if ( this._info is PreloaderSprite ) {
					( this._info as PreloaderSprite ).progress = this._bytesLoaded / this._bytesTotal
				}
			} else {
				if (this._info) {
					super.removeChild( this._info );
				}
			}
		}

		//----------------------------------
		//  color
		//----------------------------------

		/**
		 * @private
		 */
		private var _color:uint=0xFFFFFF;

		/**
		 * Цвет
		 * 
		 * @keyword					applicationfactory.color, color
		 */
		public final function get color():uint {
			return this._color;
		}

		/**
		 * @private
		 */
		public final function set color(value:uint):void {
			this._color = value;
			if ( this._info is PreloaderSprite ) {
				(this._info as PreloaderSprite ).color = this._color;
			} else if ( this._info is ErrorSprite ) {
				(this._info as ErrorSprite ).color = this._color;
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Событие окончания загрузки.
		 * 
		 * @parma	event			Событие.
		 *  
		 * @keyword					applicationfactory.oncomplete, oncomplete
		 * 
		 * @see						flash.display.LoaderInfo#complete
		 */
		protected function onComplete(event:Event):void {
		}

		/**
		 * Событие процесса загрузки загрузки.
		 * 
		 * @parma	event			Событие.
		 *  
		 * @keyword					applicationfactory.onprogress, onprogress
		 * 
		 * @see						flash.display.LoaderInfo#progress
		 */
		protected function onProgress(event:ProgressEvent):void {
		}

		/**
		 * Какая-то ошибка произошла.
		 * 
		 * @parma	e				Ошибка.
		 *  
		 * @keyword					applicationfactory.onerror, onerror
		 */
		protected function onError(e:Error):void {
			this._info = new ErrorSprite( e.message, this._color );
			this.updateInfoPosition();
			super.addChildAt( this._info, 0 );
		}

		/**
		 * Загрузить новую свф.
		 * 
		 * @param	url			Урыл по которому грузить.
		 * 
		 * @return				LoaderInfo свфки, которую грузим.
		 * 
		 * @see					flash.display.Loader#load()
		 * @see					flash.display.Loader#contentLoaderInfo
		 */
		protected final function load(request:URLRequest, context:LoaderContext=null):LoaderInfo {
			var loader:Loader = new Loader();
			this.addLoader( loader.contentLoaderInfo );
			loader.load( request, context || this._context );
			return loader.contentLoaderInfo;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updateInfoPosition():void {
			if (!this._info) return;
			var p:Point = super.globalToLocal( new Point( super.stage.stageWidth / 2, super.stage.stageHeight / 2 ) );
			this._info.x = p.x;
			this._info.y = p.y;
		}

		/**
		 * @private
		 */
		private function addLoader(loaderInfo:LoaderInfo):void {
			if ( this._loaders.indexOf( loaderInfo ) >=0 ) return;
			loaderInfo.addEventListener(Event.COMPLETE, this.handler_comlete);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.handler_ioError);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, this.handler_progress);
			this._loaders.push( loaderInfo );
			if (loaderInfo.bytesTotal > 0) {
				this._bytesLoaded += loaderInfo.bytesLoaded;
				this._bytesTotal += loaderInfo.bytesTotal;
				this.onProgress( new ProgressEvent(ProgressEvent.PROGRESS, false, false, this._bytesLoaded, this._bytesTotal) );
			}
		}

		/**
		 * @private
		 */
		private function removeLoader(loaderInfo:LoaderInfo):void {
			loaderInfo.removeEventListener(Event.COMPLETE, this.handler_comlete);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.handler_ioError);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, this.handler_progress);
			var index:int = this._loaders.indexOf( loaderInfo );
			if (index>=0) {
				this._loaders.splice(index, 1);
				this._loaded.splice(index, 1);
			}
			if (loaderInfo.bytesTotal > 0) {
				this._bytesLoaded -= loaderInfo.bytesLoaded;
				this._bytesTotal -= loaderInfo.bytesTotal;
				this.onProgress( new ProgressEvent(ProgressEvent.PROGRESS, false, false, this._bytesLoaded, this._bytesTotal) );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * стопаем всякіе штуки
		 */
		private function handler_added_removed(event:Event):void {
			if ( event.target === this._info ) event.stopImmediatePropagation();
		}

		/**
		 * @private
		 */
		private function handler_comlete(event:Event):void {
			var loaderInfo:LoaderInfo = ( event.target as LoaderInfo );
			var index:uint = this._loaders.indexOf( loaderInfo );
			if (index>=0) this._loaded[index] = true;
			if ( this.loaded ) {
				// убъем лоадеры
				for each (loaderInfo in this._loaders) {
					this.removeLoader( loaderInfo );
				}

				super.nextFrame();

				if ( this._info ) super.removeChild( this._info );
				// надо получить имя рутового класса
				var rootClassName:String = this._rootClassName;

				var appd:ApplicationDomain = super.loaderInfo.applicationDomain;
				if (!rootClassName) {
					rootClassName = super.loaderInfo.loaderURL.match( /[^\\\/]*?(?=(\.[^\.]*)?$)/ )[0] as String;
					if ( !appd.hasDefinition(rootClassName) ) rootClassName = null;
				}
				if (!rootClassName) {
					rootClassName = ( super.currentLabels.pop() as FrameLabel ).name.replace( /_(?=[^_]$)/, "::" ).replace( /_/g, "." );
					if ( !appd.hasDefinition(rootClassName) ) rootClassName = null;
				}
			    var Root:Class;
				try {
					Root = appd.getDefinition( rootClassName ) as Class;
				} catch (e:Error) {
					this.onError(e);
				}
				if (Root) {
					// вернём stage где был
					var stage:Stage = super.stage;
					stage.align = this._stageAlign;
					stage.scaleMode = this._stageScaleMode;
					stage.removeEventListener(Event.RESIZE, this.handler_resize);
					// отошлём евент
					this.onComplete( event.clone() );
					// сделаем рут
					super.parent.removeChild( this );
					stage.addChild( new Root() as DisplayObject );
				}
			}
		}

		/**
		 * @private
		 * прерывает все загрузки и выкидывает исключение
		 */
		private function handler_ioError(event:IOErrorEvent):void {
			for each ( var loaderInfo:LoaderInfo in this._loaders ) {
				this.removeLoader( loaderInfo );
			}
			if ( this._info ) super.removeChild( this._info );
			this.onError( new IOError(event.text, parseInt( event.text.match( /(?<=^Error #)\d+(?=:.*)/ )[0] ) ) );
		}

		/**
		 * @private
		 */
		private function handler_progress(event:ProgressEvent):void {
			this._bytesLoaded = 0;
			this._bytesTotal = 0;
			for each ( var loaderInfo:LoaderInfo in this._loaders ) {
				if (loaderInfo.bytesTotal > 0) {
					this._bytesLoaded += loaderInfo.bytesLoaded;
					this._bytesTotal += loaderInfo.bytesTotal;
				}
			}
			if ( this._info is PreloaderSprite ) {
				(this._info as PreloaderSprite ).progress = this._bytesLoaded / this._bytesTotal
			}
			this.onProgress( new ProgressEvent(ProgressEvent.PROGRESS, false, false, this._bytesLoaded, this._bytesTotal) );
		}

		/**
		 * @private
		 */
		private function handler_resize(event:Event):void {
			this.updateInfoPosition();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: DisplayObject
		//
		//--------------------------------------------------------------------------

		[Deprecated(message="свойство не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function set name(value:String):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @private
		 */
		public override function get stage():Stage {
			return null;
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @private
		 */
		public override function get parent():DisplayObjectContainer {
			return null;
		}

		/**
		 * @private
		 */
		public override function set x(value:Number):void {
			if ( super.x == value ) return;
			super.x = value;
			this.updateInfoPosition();
		}

		/**
		 * @private
		 */
		public override function set y(value:Number):void {
			if ( super.y == value ) return;
			super.y = value;
			this.updateInfoPosition();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: InteractiveObject
		//
		//--------------------------------------------------------------------------

		[Deprecated(message="свойство не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function set mouseEnabled(enabled:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function set tabEnabled(enabled:Boolean):void {
			throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: DisplayObjectContainer
		//
		//--------------------------------------------------------------------------

		[Deprecated(message="свойство не используется")]
		/**
		 * @private
		 */
		public override function get textSnapshot():TextSnapshot {
			return null;
		}

		/**
		 * @private
		 */
		public override function get numChildren():int {
			if ( this._info && super.contains( this._info) ) return super.numChildren - 1;
			return super.numChildren;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: Sprite
		//
		//--------------------------------------------------------------------------

		[Deprecated(message="свойство не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function set buttonMode(value:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function set hitArea(value:Sprite):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function set useHandCursor(value:Boolean):void {
			throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: MovieClip
		//
		//--------------------------------------------------------------------------

		[Deprecated(message="свойство не используется")]
		/**
		 * @private
		 */
		public override function get currentFrame():int {
			return 1;
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @private
		 */
		public override function get currentLabel():String {
			return null;
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @private
		 */
		public override function get currentLabels():Array {
			return new Array();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @private
		 */
		public override function get currentScene():Scene {
			return null;
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @private
		 */
		public override function get framesLoaded():int {
			return 0;
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @private
		 */
		public override function get scenes():Array {
			return new Array();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @private
		 */
		public override function get totalFrames():int {
			return 0;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: DisplayObjectContainer
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject {
			if ( this._showPreloader ) index++;
			return super.addChildAt( child, index );
		}

		/**
		 * @private
		 */
		public override function removeChildAt(index:int):DisplayObject {
			if ( this._showPreloader ) index--;
			return super.removeChildAt( index );
		}

		/**
		 * @private
		 */
		public override function getChildAt(index:int):DisplayObject {
			if ( this._showPreloader ) index--;
			return super.getChildAt( index );
		}

		/**
		 * @private
		 */
		public override function getChildIndex(child:DisplayObject):int {
			return super.getChildIndex( child ) + ( this._showPreloader ? -1 : 0 );
		}

		/**
		 * @private
		 */
		public override function getObjectsUnderPoint(point:Point):Array {
			var result:Array = super.getObjectsUnderPoint( point );
			if ( this._showPreloader) {
				var index:int = result.indexOf( this._info );
				if (index>=0) result.splice( index, 1 );
			}
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: Sprite
		//
		//--------------------------------------------------------------------------

		[Deprecated(message="метод не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function startDrag(lockCenter:Boolean=false, bounds:Rectangle=null):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="метод не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function stopDrag():void {
			throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: MovieClip
		//
		//--------------------------------------------------------------------------

		[Deprecated(message="метод не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function addFrameScript(...args):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="метод не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function gotoAndPlay(frame:Object, scene:String=null):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="метод не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function gotoAndStop(frame:Object, scene:String=null):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="метод не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function play():void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="метод не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function stop():void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="метод не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function nextFrame():void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="метод не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function nextScene():void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="метод не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function prevFrame():void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="метод не используется")]
		/**
		 * @throw	IllegalOperationError
		 */
		public override function prevScene():void {
			throw new IllegalOperationError();
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.display.Sprite;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: PreloaderSprite
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Отображалка загрузки. 
 * 
 * @author					BlooDHounD
 */
internal final class PreloaderSprite extends Sprite {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor
	 */
	public function PreloaderSprite(progress:Number=0.0, color:uint=0xFFFFFF):void {
		super();
		super.mouseEnabled = false;
		super.mouseChildren = false;
		super.tabEnabled = false;
		this._label.width = 100;
		this._label.y = - 20;
		this._label.x = - this._label.width / 2;
		super.addChild( this._label );
		this._progress = progress;
		this.color = color;
	}

	//--------------------------------------------------------------------------
	//
	//  Constants
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private const _label:FactoryTextFiled = new FactoryTextFiled("Initialization...");

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  color
	//----------------------------------

	/**
	 * @private
	 */
	public function get color():uint {
		return this._label.textColor;
	}

	/**
	 * @private
	 */
	public function set color(value:uint):void {
		if (this.color == value) return;
		this._label.textColor = value;
		this.redraw();
	}

	//----------------------------------
	//  progress
	//----------------------------------

	/**
	 * @private
	 */
	private var _progress:Number = 0;

	/**
	 * @private
	 */
	public function get progress():Number {
		return this._progress;
	}

	/**
	 * @private
	 */
	public function set progress(value:Number):void {
		value = Math.min( Math.max( 0, value ), 1 ); 
		if (this._progress == value) return;
		this._progress = value;
		this.redraw();
	}

	//--------------------------------------------------------------------------
	//
	//  Private methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function redraw():void	{
		var w:Number = this._progress * 100;
		with (super.graphics) {
			clear();
			beginFill(this.color, 0.5);
			moveTo(-50, -5);
			lineTo(-50 + w, -5);
			lineTo(-50 + w, 5);
			lineTo(-50, 5);
			lineTo(-50, -5);
			endFill();
			lineStyle(1, this.color);
			moveTo(-50, -5);
			lineTo(50, -5);
			lineTo(50, 5);
			lineTo(-50, 5);
			lineTo(-50, -5);
		}
	}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ErrorSprite
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Отображалка ошибок. 
 * 
 * @author					BlooDHounD
 */
internal final class ErrorSprite extends Sprite {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor
	 */
	public function ErrorSprite(text:String=null, color:uint=0xFFFFFF):void {
		super();
		super.mouseEnabled = false;
		super.mouseChildren = false;
		super.tabEnabled = false;
		this._label.wordWrap = true;
		this._label.multiline = true;
		this._label.width = 200;
		this._label.x = - this._label.width / 2;
		this.text = text;
		super.addChild( this._label );
		this.color = color;
	}

	//--------------------------------------------------------------------------
	//
	//  Constants
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private const _label:FactoryTextFiled = new FactoryTextFiled();

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  color
	//----------------------------------

	/**
	 * @private
	 */
	public function get color():uint {
		return this._label.textColor;
	}

	/**
	 * @private
	 */
	public function set color(value:uint):void {
		this._label.textColor = value;
	}

	//----------------------------------
	//  text
	//----------------------------------

	/**
	 * @private
	 */
	public function get text():String {
		return this._label.text;
	}

	/**
	 * @private
	 */
	public function set text(value:String):void {
		this._label.text = value || "";
		this._label.y =  - this._label.height / 2;
	}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: FactoryTextFiled
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Текстовое поле для надписей. 
 * 
 * @author					BlooDHounD
 */
internal final class FactoryTextFiled extends TextField {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor
	 */
	public function FactoryTextFiled(text:String=null) {
		super();
		super.selectable = false;
		var format:TextFormat = new TextFormat("_sans", 10);
		format.align = TextFormatAlign.CENTER;
		super.defaultTextFormat = format;
		super.autoSize = TextFieldAutoSize.CENTER;
		super.text = text || "";
	}

}