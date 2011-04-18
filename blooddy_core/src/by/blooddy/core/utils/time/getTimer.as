////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.time {

	import flash.utils.getTimer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public function getTimer():Number {
		return flash.utils.getTimer() + deltaTime;
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;

/**
 * эта величина хактеризует на сколько флэшой таймер сбился
 * относительно системного времени
 */
internal var deltaTime:Number = 0;

/**
 * время запуска таймера
 */
internal const startTime:Number = ( new Date() ).getTime() - getTimer();

/**
 * таймем для переодической синхронизации
 */
internal const timer:Timer = new Timer( 10e3 );
timer.addEventListener( TimerEvent.TIMER, handler_timer );
timer.start();

/**
 * метод синхронизации
 */
internal function handler_timer(event:TimerEvent):void {
	deltaTime = ( new Date() ).getTime() - startTime - getTimer();
}