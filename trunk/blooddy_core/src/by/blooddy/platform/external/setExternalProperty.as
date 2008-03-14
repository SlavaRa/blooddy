package platform.external {

	import flash.errors.IllegalOperationError;

	import flash.net.navigateToURL;
	import flash.net.URLRequest;

	import flash.external.ExternalInterface;
	import flash.system.Capabilities;

	internal function setExternalProperty(propertyName:String, value:*):void {
		if (ExternalInterface.available && false) {
			ExternalInterface.call("function(value) { "+propertyName+" = value; }", value);
		} else if (Capabilities.playerType!="StandAlone") {
			var s:String;
			if (value is String)	s = "'" + value + "'";
			else					s = value.toString();
			navigateToURL( new URLRequest("javascript: window.status='asd';") );
		} else {
			throw new IllegalOperationError();
		}
	}

}