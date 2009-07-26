package by.blooddy.core.utils {

	import flash.utils.getTimer;

	public function getTimer():Number {
		return ( new Date() ).getTime() - startTime;
	}

}

import flash.utils.getTimer;

internal const startTime:Number = ( new Date() ).getTime() - flash.utils.getTimer();