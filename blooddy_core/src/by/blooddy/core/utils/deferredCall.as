////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.events.IEventDispatcher;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public function deferredCall(func:Function, args:Array, target:IEventDispatcher, eventType:String, useCapture:Boolean=false, priority:int=0.0, useWeakReference:Boolean=false):void {
		target.addEventListener( eventType, ( new Listener( func, args ) ).handler, useCapture, priority, useWeakReference );
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.events.IEventDispatcher;
import flash.events.Event;
import flash.events.EventPhase;
import by.blooddy.core.utils.Caller;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: Listener
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 */
internal final class Listener extends Caller {

	public function Listener(listener:Function, args:Array) {
		super( listener, args );
	}

	public function handler(event:Event):void {
		// надо себя убить из слушателей, иначе есть риск зависнуть, к тому же нам надо выполниться всего один раз
		( event.currentTarget as IEventDispatcher ).removeEventListener( event.type, this.handler, event.eventPhase == EventPhase.CAPTURING_PHASE );
		// вызываемся
		this.call();
	}

}