////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 BlooDHounD.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.utils {

	import flash.errors.IllegalOperationError;

	import by.blooddy.platform.utils.ui.getContextMenu;
	import flash.events.ContextMenuEvent;
	import flash.events.TimerEvent;
	import flash.events.Event;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	import flash.system.System;

	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	import flash.utils.getTimer;
	import flash.utils.Timer;

	import flash.text.TextSnapshot;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextField;

	import flash.display.LineScaleMode;
	import flash.display.Graphics;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					activitylistener, activity, listener, fps, memory
	 */
	public final class ActivityListener extends Sprite {

		//--------------------------------------------------------------------------
		//
		//  Private constants
		//
		//--------------------------------------------------------------------------

		private static const error:String = "The ActivityListener class does not implement this property or method.";

		/**
		 * @private
		 * Формат текстовых палей.
		 */
		private static const tf:TextFormat = new TextFormat("_sans", 10);

		/**
		 * @private
		 */
		private static const DEFAULT_BG_COLOR:uint = 0x80000000;

		/**
		 * @private
		 */
		private static const DEFAULT_FPS_COLOR:uint = 0xFFFFFF;

		/**
		 * @private
		 */
		private static const DEFAULT_MEMORY_COLOR:uint = 0xFFFF00;

		/**
		 * @private
		 */
		private static const DEFAULT_WIDTH:Number = 100;

		/**
		 * @private
		 */
		private static const DEFAULT_HEIGHT:Number = 50;

		/**
		 * @private
		 */
		private static const GRAPH_OFFSET_Y:Number = 30;

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Возвращает новое текстовое поле с задаными свойствами.
		 */
		private static function getNewTextField():TextField {
			var txt:TextField = new TextField();
			txt.selectable = false;
			txt.defaultTextFormat = tf;
			txt.autoSize = TextFieldAutoSize.LEFT;
			return txt;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function ActivityListener() {
			super();
			// дефолтные значения
			super.tabChildren = false;
			super.tabEnabled = false;
			super.mouseChildren = false;
			super.mouseEnabled = true;
			// установим цвета
			this.bgColor32 =	DEFAULT_BG_COLOR;		// создаёт заодно и габариты
			this.fpsColor =		DEFAULT_FPS_COLOR;
			this.memoryColor =	DEFAULT_MEMORY_COLOR;
			// переварачиваем шэйпы
			this._shape_MEM.scaleX =
			this._shape_FPS.scaleX = - 1;
			// фигачим текстовые поля
			this._txt_FPS_label.text = "FPS:";
			this._txt_MEM_label.text = "MEM:";
			this._txt_MEM_value.x =
			this._txt_FPS_value.x = 35;
			this._txt_MEM_max.x =
			this._txt_FPS_max.x = 75;
			this._txt_MEM_max.y =
			this._txt_MEM_value.y =
			this._txt_MEM_label.y = 12;
			// добавляем всё это
			super.addChild(this._shape_BG);
			super.addChild(this._shape_FPS);
			super.addChild(this._shape_MEM);
			super.addChild(this._txt_FPS_label);
			super.addChild(this._txt_FPS_value);
			super.addChild(this._txt_FPS_max);
			super.addChild(this._txt_MEM_label);
			super.addChild(this._txt_MEM_value);
			super.addChild(this._txt_MEM_max);
			// делаем небольшой хук
			this._shape_BG.width = this._shape_BG.height = 0;
			// меняем размеры
			this.width =	DEFAULT_WIDTH;
			this.height =	DEFAULT_HEIGHT;
			// вешаем листенеры
//			this.addEventListener(Event.ADDED_TO_STAGE, this.handler_addToStage);
//			this.addEventListener(Event.REMOVED_FROM_STAGE, this.handler_removeFromStage);
			this.addEventListener(Event.ADDED, this.handler_addToStage);
			this.addEventListener(Event.REMOVED, this.handler_removeFromStage);
			// стартуем отрисовку
			this.refreshTime = 40;
		}

		//--------------------------------------------------------------------------
		//
		//  DisplayObjects
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Фон.
		 */
		private const _shape_BG:Shape = new Shape();

		/**
		 * @private
		 * Рисуем графики.
		 */
		private const _shape_FPS:Shape = new Shape();

		/**
		 * @private
		 * Рисуем графики.
		 */
		private const _shape_MEM:Shape = new Shape();

		/**
		 * @private
		 * Рисуем графики.
		 */
		private const _txt_FPS_label:TextField = getNewTextField();

		/**
		 * @private
		 * Рисуем графики.
		 */
		private const _txt_FPS_value:TextField = getNewTextField();

		/**
		 * @private
		 * Рисуем графики.
		 */
		private const _txt_FPS_max:TextField = getNewTextField();

		/**
		 * @private
		 * Рисуем графики.
		 */
		private const _txt_MEM_label:TextField = getNewTextField();

		/**
		 * @private
		 * Рисуем графики.
		 */
		private const _txt_MEM_value:TextField = getNewTextField();

		/**
		 * @private
		 * Рисуем графики.
		 */
		private const _txt_MEM_max:TextField = getNewTextField();

		//--------------------------------------------------------------------------
		//
		//  Variblies
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Обновлять ли сразу после события?
		 */
		private var _updateAfterEvent:Boolean = false;

		/**
		 * @private
		 * Таймер для обновления экрана.
		 */
		private const _TIMER:Timer = new Timer(0);

		/**
		 * @private
		 * Массив для записи времнной шкалы.
		 */
		private const _TIMES:Array = new Array();

		/**
		 * @private
		 * Массив фпсов для отрисовки.
		 */
		private const _FPS:Array = new Array();

		/**
		 * @private
		 * Предыдущее время.
		 */
		private var _prevTime:uint = 0;

		/**
		 * @private
		 * Предыдущее время.
		 */
		private var _frameRate:uint;

		/**
		 * @private
		 * Использование памяти.
		 */
		private const _MEM:Array = new Array();

		/**
		 * @private
		 * Максимально занято памяти, для отрисовки графика.
		 */
		private var _memMax:Number = 0;

		//--------------------------------------------------------------------------
		//
		//  Override properties: DisplayObject
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  width
		//----------------------------------

		/**
		 * @private
		 */
		public override function get width():Number {
			return this._shape_BG.width;
		}

		/**
		 * @private
		 */
		public override function set width(value:Number):void {
			value = Math.max(value, 70);
			if (this.width == value) return;
			// меняем ширину
			super.scrollRect = new Rectangle(0, 0, value, this.height);
			this._shape_BG.width = value;
			// перемещаем зависимые элементы
			this._shape_MEM.x =
			this._shape_FPS.x = value;
			// проверяем видимость
			this._txt_FPS_max.visible =
			this._txt_MEM_max.visible = value>=100;
		}

		//----------------------------------
		//  height
		//----------------------------------

		/**
		 * @private
		 */
		public override function get height():Number {
			return this._shape_BG.height;
		}

		/**
		 * @private
		 */
		public override function set height(value:Number):void {
			value = Math.max(value, 30);
			if (this.height == value) return;
			// меняем высоту
			super.scrollRect = new Rectangle(0, 0, this.width, value);
			this._shape_BG.height = value;
			// перемещаем
			this._shape_MEM.y =
			this._shape_FPS.y = value;
			// меняем масштаб
			this._shape_FPS.scaleY = -(value-GRAPH_OFFSET_Y)/this._frameRate;
			this._shape_MEM.scaleY = -(value-GRAPH_OFFSET_Y)/((int(this._memMax/1024/1024/5)+1)*5);
			// проверяем видимость
			this._shape_MEM.visible =
			this._shape_FPS.visible = value>=50;
		}

		//----------------------------------
		//  scaleX
		//----------------------------------

		/**
		 * @private
		 */
		public override function get scaleX():Number {
			return this._shape_BG.scaleX;
		}

		/**
		 * @private
		 */
		public override function set scaleX(value:Number):void {
			this.width = DEFAULT_WIDTH * value;
		}

		//----------------------------------
		//  scaleY
		//----------------------------------

		/**
		 * @private
		 */
		public override function get scaleY():Number {
			return this._shape_BG.scaleY;
		}

		/**
		 * @private
		 */
		public override function set scaleY(value:Number):void {
			this.height = DEFAULT_HEIGHT * value;
		}

		//----------------------------------
		//  opaqueBackground
		//----------------------------------

		/**
		 * @private
		 */
		public override function set opaqueBackground(value:Object):void {
			throw new IllegalOperationError(error);
		}

		//----------------------------------
		//  scale9Grid
		//----------------------------------

		/**
		 * @private
		 */
		public override function set scale9Grid(innerRectangle:Rectangle):void {
			throw new IllegalOperationError(error);
		}

		//----------------------------------
		//  scrollRect
		//----------------------------------

		/**
		 * @private
		 */
		public override function get scrollRect():Rectangle {
			return null;
		}

		/**
		 * @private
		 */
		public override function set scrollRect(value:Rectangle):void {
			throw new IllegalOperationError(error);
		}

		//--------------------------------------------------------------------------
		//
		//  Override properties: InteractiveObject
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  contextMenu
		//----------------------------------

		/**
		 * @private
		 */
		public override function get contextMenu():ContextMenu {
			return null;
		}

		/**
		 * @private
		 */
		public override function set contextMenu(cm:ContextMenu):void {
			throw new IllegalOperationError(error);
		}

		//----------------------------------
		//  mouseEnabled
		//----------------------------------

		/**
		 * @private
		 */
		public override function set mouseEnabled(enabled:Boolean):void {
			throw new IllegalOperationError(error);
		}

		//--------------------------------------------------------------------------
		//
		//  Override properties: DisplayObjectContainer
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  mouseChildren
		//----------------------------------

		/**
		 * @private
		 */
		public override function set mouseChildren(enable:Boolean):void {
			throw new IllegalOperationError(error);
		}

		//----------------------------------
		//  tabChildren
		//----------------------------------

		/**
		 * @private
		 */
		public override function set tabChildren(enable:Boolean):void {
			throw new IllegalOperationError(error);
		}

		//----------------------------------
		//  numChildren
		//----------------------------------

		/**
		 * @private
		 */
		public override function get numChildren():int {
			return 0;
		}

		//----------------------------------
		//  textSnapshot
		//----------------------------------

		/**
		 * @private
		 */
		public override function get textSnapshot():TextSnapshot {
			throw new TextSnapshot();
		}

		//--------------------------------------------------------------------------
		//
		//  Override properties: Sprite
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  graphics
		//----------------------------------

		/**
		 * @private
		 */
		public override function get graphics():Graphics {
			throw new IllegalOperationError(error);
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  refreshTime
		//----------------------------------

		/**
		 * @private
		 */
		private var _refreshTime:uint = 0;

		/**
		 * Скорость обновления экрана в милисикундах.
		 * 
		 * @keyword				activitylistener.refreshtime, refreshtime, refresh, time, delay
		 */
		public function get refreshTime():uint {
			return this._refreshTime;
		}

		/**
		 * @private
		 */
		public function set refreshTime(time:uint):void {
			if (this._refreshTime == time) return;
			this._refreshTime = time;
			if (time>0) {
				this._TIMER.delay = time;
				this._TIMER.start();
				this._TIMER.addEventListener(TimerEvent.TIMER, this.handler_timer);
			} else {
				this._TIMER.removeEventListener(TimerEvent.TIMER, this.handler_timer);
				this._TIMER.stop();
			}
		}

		//----------------------------------
		//  fpsColor
		//----------------------------------

		/**
		 * @private
		 */
		private var _fpsColor:Number = NaN;

		/**
		 * Цвет FPS.
		 * 
		 * @keyword				activitylistener.fpscolor, fpscolor, fps, color
		 */
		public function get fpsColor():uint {
			return this._fpsColor;
		}

		/**
		 * @private
		 */
		public function set fpsColor(value:uint):void {
			if (this._fpsColor==value) return;
			this._fpsColor = value;
			this._txt_FPS_label.textColor = value;
			this._txt_FPS_value.textColor = value;
			this._txt_FPS_max.textColor = value;
		}

		//----------------------------------
		//  memoryColor
		//----------------------------------

		/**
		 * @private
		 */
		private var _memColor:Number = NaN;

		/**
		 * Цвет памяти.
		 * 
		 * @keyword				activitylistener.memorycolor, memorycolor, memory, color
		 */
		public function get memoryColor():uint {
			return this._memColor;
		}

		/**
		 * @private
		 */
		public function set memoryColor(value:uint):void {
			if (this._memColor==value) return;
			this._memColor = value;
			this._txt_MEM_label.textColor = value;
			this._txt_MEM_value.textColor = value;
			this._txt_MEM_max.textColor = value;
		}

		//----------------------------------
		//  bgColor32
		//----------------------------------

		/**
		 * @private
		 */
		private var _bgColor:Number = NaN;

		/**
		 * Цвет Фона в 32 бита.
		 * 
		 * @keyword				activitylistener.bgcolor32, bgcolor32, color
		 */
		public function get bgColor32():uint {
			return this._bgColor;
		}

		/**
		 * @private
		 */
		public function set bgColor32(value:uint):void {
			if (this._bgColor==value) return;
			var alpha:uint = value >> 24 & 0xFF;	// альфа
			var color:uint = value & 0xFFFFFF;		// цвет
			// рисуем бг
			var g:Graphics = this._shape_BG.graphics;
			g.clear();
			g.beginFill(color, alpha/255);
			g.drawRect(0, 0, DEFAULT_WIDTH, DEFAULT_HEIGHT);
			g.endFill();
		}

		//--------------------------------------------------------------------------
		//
		//  Override methods: EventDispatcher
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function dispatchEvent(event:Event):Boolean {
			throw new IllegalOperationError(error);
		}

		//--------------------------------------------------------------------------
		//
		//  Override methods: DisplayObjectContainer
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function addChild(child:DisplayObject):DisplayObject {
			throw new IllegalOperationError(error);
		}

		/**
		 * @private
		 */
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject {
			throw new IllegalOperationError(error);
		}

		/**
		 * @private
		 */
		public override function areInaccessibleObjectsUnderPoint(point:Point):Boolean {
			return super.areInaccessibleObjectsUnderPoint(point);
		}

		/**
		 * @private
		 */
		public override function contains(child:DisplayObject):Boolean {
			return false;
		}

		/**
		 * @private
		 */
		public override function getChildAt(index:int):DisplayObject {
			return super.getChildAt(-1);
		}

		/**
		 * @private
		 */
		public override function getChildByName(name:String):DisplayObject {
			return null;
		}

		/**
		 * @private
		 */
		public override function getChildIndex(child:DisplayObject):int {
			return super.getChildIndex(this);
		}

		/**
		 * @private
		 */
		public override function getObjectsUnderPoint(point:Point):Array {
			return new Array();
		}

		/**
		 * @private
		 */
		public override function removeChild(child:DisplayObject):DisplayObject {
			return super.removeChild( child ? this : null );
		}

		/**
		 * @private
		 */
		public override function removeChildAt(index:int):DisplayObject {
			return super.removeChildAt(-1);
		}

		/**
		 * @private
		 */
		public override function setChildIndex(child:DisplayObject, index:int):void {
			super.setChildIndex(this, -1);
		}

		/**
		 * @private
		 */
		public override function swapChildren(child1:DisplayObject, child2:DisplayObject):void {
			super.swapChildren(this, this);
		}

		/**
		 * @private
		 */
		public override function swapChildrenAt(index1:int, index2:int):void {
			super.swapChildrenAt(-1, -1);
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addToStage(event:Event):void {
//			super.mouseEnabled = this.loaderInfo.loaderURL.indexOf("file:///")!=0;
			// создаём свою менюшку
			// найдём первое родительское меню
			var contextMenu:ContextMenu = getContextMenu(this);
			if (contextMenu) {
				contextMenu = contextMenu.clone();
				// надо у первого кастомного элемента сделать сепаратор
				var customItems:Array = contextMenu.customItems;
				for (var i:uint = 0; i<customItems.length; i++) {
					if ((customItems[i] as ContextMenuItem).visible) {
						(customItems[i] as ContextMenuItem).separatorBefore = true;
						break;
					}
				}
			} else {
				contextMenu = new ContextMenu();
				contextMenu.hideBuiltInItems();
			}
			// вставляем наши элементы
			var item1:ContextMenuItem = new ContextMenuItem("ActivityListener");
			var item2:ContextMenuItem = new ContextMenuItem("@ 2007 BlooDHounD");
			item2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, this.handler_menuItemSelect);
			contextMenu.customItems.unshift( item1, item2 );
			super.contextMenu = contextMenu;
			// найдём сперва тут менюшку что есть выше
			this._prevTime = getTimer();
			super.addEventListener(Event.ENTER_FRAME, this.handler_enterFrame);
		}

		/**
		 * @private
		 */
		private function handler_removeFromStage(event:Event):void {
			super.contextMenu = null;
			super.removeEventListener(Event.ENTER_FRAME, this.handler_enterFrame);
		}

		/**
		 * @private
		 * Обновлялка состояния
		 */
		private function handler_enterFrame(event:Event):void {
			// обработаем FPS
			var time:uint = getTimer();
			this._TIMES.push( time );

			var fps:Number = 1E3 / ( time - this._prevTime );
			this._FPS.push( fps );

			var mem:Number = System.totalMemory/1024/1024;
			this._MEM.push( mem );

			this._prevTime = time;

			// изменился фрэймрайт
			if (this._frameRate!=this.stage.frameRate) {
				this._frameRate = this.stage.frameRate;
				this._shape_FPS.scaleY = -(this.height-GRAPH_OFFSET_Y)/this._frameRate;
				this._txt_FPS_max.text = this._frameRate.toString();
				// обновлять часще чем раз в кадр не имеет смысла,
				// если время обновления меньше чем скорость проигрывания одного кадра.
				this._updateAfterEvent = this.refreshTime > 1E3/this._frameRate;
			}

			// изменился максимуми памяти
			if (this._memMax<mem) {
				this._memMax = (int(mem/5)+1)*5;
				this._shape_MEM.scaleY = -(this.height-GRAPH_OFFSET_Y)/this._memMax;
				this._txt_MEM_max.text = this._memMax.toString();
			}

		}

		/**
		 * @private
		 * Обновлялка графики.
		 */
		private function handler_timer(event:TimerEvent):void {
			var time:uint = getTimer();
			// выкинем лишнее из временного интервала
			while (this._TIMES[0]+this.width*10+500<=time) {
				this._TIMES.shift();
				this._FPS.shift();
				this._MEM.shift();
			}
			// считаем длинну
			var l:uint = this._TIMES.length;
			// напишем текста
			this._txt_FPS_value.text = (uint(this._FPS[l-1]*10)/10).toString();
			this._txt_MEM_value.text = (uint(this._MEM[l-1]*100)/100).toString();
			// рисуем графики
			var t:Number;
			var gF:Graphics = this._shape_FPS.graphics;
			var gM:Graphics = this._shape_MEM.graphics;
			gF.clear();
			gM.clear();
			gF.lineStyle(1, this._fpsColor, 1, false, LineScaleMode.NONE);
			gM.lineStyle(1, this._memColor, 1, false, LineScaleMode.NONE);
			t = (time-this._TIMES[0])/10;
			gF.moveTo(t, this._FPS[0]);
			gM.moveTo(t, this._MEM[0]);
			for (var i:uint = 1; i<l; i++) {
				t = (time-this._TIMES[i])/10;
				gF.lineTo(t, this._FPS[i]);
				gM.lineTo(t, this._MEM[i]);
			}
			gF.lineTo(-5, this._FPS[l-1]);
			gM.lineTo(-5, this._MEM[l-1]);
			if (this._updateAfterEvent) {
				event.updateAfterEvent();
			}
		}

		/**
		 * @private
		 * Обрабатывался менюшки.
		 */
		private function handler_menuItemSelect(event:ContextMenuEvent):void {
			navigateToURL( new URLRequest("http://www.timezero.ru"), "_blank" );
		}

	}

}