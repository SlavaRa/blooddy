////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.time {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public function getTimer():Number {
		return ( new Date() ).getTime() - startTime;
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.utils.getTimer;

/**
 * @private
 */
internal const startTime:Number = ( new Date() ).getTime() - getTimer();