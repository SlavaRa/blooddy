package by.blooddy.platform.utils {

	import flash.events.IEventDispatcher;

	public function deferredCall(func:Function, args:Array, target:IEventDispatcher, eventType:String, useCapture:Boolean=false, priority:int=0.0, useWeakReference:Boolean=false):void {
		target.addEventListener( eventType, createDeferredListener( func, args ), useCapture, priority, useWeakReference );
	}

}

import flash.events.IEventDispatcher;
import flash.events.Event;
import flash.events.EventPhase;

internal function createDeferredListener(func:Function, args:Array=null):Function {
	return function(event:Event):void {
		// надо себя убить из слушателей, иначе есть риск зависнуть, к тому же нам надо выполниться всего один раз
		( event.currentTarget as IEventDispatcher ).removeEventListener( event.type, arguments.callee, event.eventPhase == EventPhase.CAPTURING_PHASE );
		// вызываемся
		func.apply(null, args);
	}
}