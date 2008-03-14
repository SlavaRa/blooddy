////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 BlooDHounD.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.utils {

	import flash.events.TimerEvent;

	import flash.utils.Timer;

	import flash.utils.getTimer;

	/**
	 * Утилиты для работы с классами.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					timerdispatcher, timer, dispatcher
	 */
	public class TimerDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 * 
		 * @param	delay		Задержка.
		 */
		public function TimerDispatcher(delay:uint=100) {
			super();
			this._timer.delay = delay;
		}

		//--------------------------------------------------------------------------
		//
		//  Private constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _timer:Timer = new Timer(Number.MAX_VALUE);

		/**
		 * @private
		 */
		private const _listeners:Array = new Array();

		/**
		 * @private
		 */
		private var _stopListener:Function;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  delay
		//----------------------------------

		/**
		 * Задержка между вызовами методов.
		 * Функции из очереди будут вызываться тактами равные задержке.
		 * 
		 * @keyword				timerdispatcher.delay, delay
		 */
		public function get delay():uint {
			return this._timer.delay;
		}

		/**
		 * @private
		 */
		public function set delay(value:uint):void {
			this._timer.delay = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Добавить метод в очередь.
		 * 
		 * @param	listener	Слушатель.
		 * @param	args		Аргументы.
		 * 
		 * @keyword				timerdispatcher.addqueuelistener, addqueuelistener, addqueue, listener, queue
		 */
		public function addQueueListener(listener:Function, args:Array=null, useWeakReference:Boolean=false):uint {
			var length:uint = this._listeners.push( new QueueListener(listener, args, useWeakReference) );
			if (this._listeners.length==1) { // появился первый элемент. надо запускать таймер
				this.start();
			}
			return length-1;
		}

		public function addQueueTimerDispatcher(dispatcher:TimerDispatcher):uint {
			var length:uint = this._listeners.push( dispatcher );
			if (this._listeners.length==1) { // появился первый элемент. надо запускать таймер
				this.start();
			}
			return length-1;
		}

		public function removeQueueItem(index:uint):void {
			this._listeners.splice(index, 1);
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function start():void {
			this._timer.addEventListener(TimerEvent.TIMER, this.handler_timer);
			this._timer.start();
		}

		/**
		 * @private
		 */
		private function stop():void {
			this._timer.stop();
			this._timer.removeEventListener(TimerEvent.TIMER, this.handler_timer);
			if (Boolean(this._stopListener)) {
				this._stopListener();
				this._stopListener = null;
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Хэндлер таймера.
		 */
		private function handler_timer(event:TimerEvent):void {
			var t:uint = getTimer();
			var item:Object;
			var ql:QueueListener;
			var td:TimerDispatcher;
			while (getTimer()-t<=this._timer.delay && this._listeners.length>=0) {
				item = this._listeners.shift();
				if (item is QueueListener) {
					ql = item as QueueListener;
					if (Boolean(item.listener)) {
						item.listener.apply(null, item.args);
					}
				} else {
					this.stop();
					td = item as TimerDispatcher;
					td._stopListener = this.start; // стартанём нас по окончании
					td.start();
				}
			}
			if (this._listeners.length<=0) {
				this.stop();
			}
		}

	}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: QueueListener
//
////////////////////////////////////////////////////////////////////////////////

import flash.utils.Dictionary;

/**
 * @private
 * Вспомогательный класс очереди слушателей.
 * Нследник Dictionary для того что бы отслеживать
 * мягкие сслыки.
 */
internal final class QueueListener extends Dictionary {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor.
	 * 
	 * @param	listener			Слушатель.
	 * @param	args				Аргументы.
	 * @param	useWeakReference	Мягкая ссылка.
	 */
	public function QueueListener(listener:Function, args:Array=null, useWeakReference:Boolean=false) {
		super(useWeakReference);
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  listener
	//----------------------------------

	/**
	 * @private
	 * Слушатель.
	 */
	public function get listener():Function {
		for (var result:Object in super) {
			return result as Function;
		}
		return null;
	}

	//----------------------------------
	//  args
	//----------------------------------

	/**
	 * @private
	 * Аргументы слушателя.
	 */
	public function get args():Array {
		for each (var result:Array in super) {
			return result;
		}
		return null;
	}

}