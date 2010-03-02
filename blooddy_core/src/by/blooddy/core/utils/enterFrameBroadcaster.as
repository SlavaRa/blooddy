////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.display.Shape;
	import flash.events.EventDispatcher;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public const enterFrameBroadcaster:EventDispatcher = new Shape();

}

import by.blooddy.core.utils.enterFrameBroadcaster;

import flash.events.Event;
import flash.display.Sprite;
import flash.errors.IllegalOperationError;

enterFrameBroadcaster.addEventListener( Event.ADDED_TO_STAGE, this.handler_added );

/**
 * @private
 */
internal const _JUNK:Sprite = new Sprite();

/**
 * @private
 */
internal function handler_added(event:Event):void {
	_JUNK.addChild( this );
	_JUNK.removeChild( this );
	throw new IllegalOperationError();
}