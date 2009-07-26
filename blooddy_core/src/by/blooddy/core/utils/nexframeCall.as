////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.events.Event;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public function nexframeCall(func:Function, args:Array=null, priority:int=0.0):void {
		deferredCall( func, args,  enterFrameBroadcaster, Event.ENTER_FRAME, false, priority ); 
	}

}