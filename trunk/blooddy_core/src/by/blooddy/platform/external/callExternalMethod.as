package platform.external {

	import flash.errors.IllegalOperationError;

	import flash.net.navigateToURL;
	import flash.net.URLRequest;

	import flash.external.ExternalInterface;
	import flash.system.Capabilities;

	internal function callExternalMethod(methodName:String, ...args):* {
		if (ExternalInterface.available) {
			return ExternalInterface.call(methodName, args);
		} else if (Capabilities.playerType!="StandAlone") {
			var arr:Array = new Array();
			for (var i:uint = 0; i<args.length; i++) {
				if (!args[i]) continue;
				if (args[i] is String) {
					arr[i] = "'" + args[i] + "'";
				} else {
					arr[i] = args[i].toString();
				}
			}
			navigateToURL( new URLRequest("javascript:"+methodName+"("+arr.join(",")+"); void(0);'") );
			return undefined;
		}
		throw new IllegalOperationError();
	}

}