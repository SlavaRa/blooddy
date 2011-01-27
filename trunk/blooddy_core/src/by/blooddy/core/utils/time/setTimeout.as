////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.time {

	import flash.utils.setTimeout;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					setTimeout, time, timeout
	 */
	public function setTimeout(closure:Function, delay:Number, ...paramets):uint {
		var asset:TimeoutAsset = new TimeoutAsset( closure, paramets );
		asset.id = flash.utils.setTimeout( asset.call, delay );
		return asset.id;
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.utils.Caller;

import flash.utils.clearTimeout;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: TimeoutAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class TimeoutAsset extends Caller {

	public function TimeoutAsset(listener:Function, args:Array=null) {
		super( listener, args );
	}

	public var id:uint;

	public override function call():* {
		clearTimeout( this.id );
		return super.call();
	}

}