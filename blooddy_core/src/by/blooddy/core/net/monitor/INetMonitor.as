////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.monitor {

	import by.blooddy.core.net.ILoadable;
	
	import flash.net.URLRequest;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Feb 26, 2010 11:52:23 AM
	 */
	public interface INetMonitor {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		function get isActive():Boolean;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		function adjustURL(url:String, correlationID:String=null):String;
		
		function adjustURLRequest(correlationID:String, request:URLRequest):void;
		
		function monitorInvocation(correlationID:String, request:URLRequest, loader:ILoadable, context:*=null):void;

	}
	
}