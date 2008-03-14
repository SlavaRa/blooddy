package platform.external {

	import flash.errors.IllegalOperationError;

	import flash.external.ExternalInterface;

	internal function getExternalProperty(propertyName:String):* {
		if (!ExternalInterface.available) throw new IllegalOperationError();
		return ExternalInterface.call("function() { return "+propertyName+"; }");
	}

}