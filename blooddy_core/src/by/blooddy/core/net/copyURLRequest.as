package by.blooddy.core.net {

	import by.blooddy.core.utils.copyObject;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;

	internal function copyURLRequest(request:URLRequest):URLRequest {
		var result:URLRequest = new URLRequest();
		result.url = request.url;
		result.method = request.method;
		result.contentType = request.contentType;
		result.digest = request.digest;
		if ( request.requestHeaders ) {
			result.requestHeaders = new Array();
			var l:uint = request.requestHeaders.length;
			var header:URLRequestHeader;
			for ( var i:uint = 0; i<l; i++ ) {
				header = request.requestHeaders[ i ] as URLRequestHeader;
				if ( header ) {
					result.requestHeaders.push(
						new URLRequestHeader(
							header.name,
							header.value
						)
					);
				}
			}
		}
		if ( request.data ) {
			if ( request.data is URLVariables ) {
				result.data = new URLVariables( ( request.data as URLVariables ).toString() );
			} else {
				result.data = copyObject( request.data );
			}
		}
		return result;
	}

}