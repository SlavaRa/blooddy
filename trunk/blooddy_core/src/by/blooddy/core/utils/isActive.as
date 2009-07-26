package by.blooddy.core.utils {

	public function isActive():Boolean {
		return active;
	}

}

import flash.events.EventDispatcher;
import flash.events.Event;

internal var active:Boolean = true;

internal const dispatcher:EventDispatcher = new EventDispatcher();

dispatcher.addEventListener(Event.ACTIVATE, handler_activate, false, int.MAX_VALUE);
dispatcher.addEventListener(Event.DEACTIVATE, handler_deactivate, false, int.MAX_VALUE);

internal function handler_activate(event:Event):void {
	active = true;
}

internal function handler_deactivate(event:Event):void {
	active = false;
}