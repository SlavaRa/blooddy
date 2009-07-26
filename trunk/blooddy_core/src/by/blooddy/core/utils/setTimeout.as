package by.blooddy.core.utils {

	import flash.utils.setTimeout;

	public function setTimeout(closure:Function, delay:Number, ...paramets):uint {
		var asset:TimeoutAsset = new TimeoutAsset( closure, paramets );
		asset.id = flash.utils.setTimeout( asset.call, delay );
		return asset.id;
	}

}

import by.blooddy.core.utils.Caller;
import flash.utils.clearTimeout;

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