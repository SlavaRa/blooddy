////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

	import platform.events.isIntrinsicEvent;

	import flash.events.Event;

	//--------------------------------------------------------------------------
	//
	//  Override methods: EventDispatcher
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public override function dispatchEvent(event:Event):Boolean {
		if ( isIntrinsicEvent(this, event) ) return true;
		return super.dispatchEvent( event );
	}

	/**
	 * @private
	 */
	protected final function $dispatchEvent(event:Event):Boolean {
		return super.dispatchEvent(event);
	}
	