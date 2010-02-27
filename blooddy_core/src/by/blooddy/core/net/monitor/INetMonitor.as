////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.monitor {

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
		
		function adjustURLRequest(request:URLRequest, correlationID:String=null):void;
		
	}
	
}