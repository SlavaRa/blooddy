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
	 * @created					Feb 26, 2010 12:34:08 PM
	 */
	public final class NetMonitor {
		
		//--------------------------------------------------------------------------
		//
		//  Class properties
		//
		//--------------------------------------------------------------------------

		public static var monitor:INetMonitor;

		/**
		 * @copy	by.blooddy.core.net.monitor.INetMonitor#isActive
		 */
		public static function get isActive():Boolean {
			return ( monitor ? monitor.isActive : false );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @copy	by.blooddy.core.net.monitor.INetMonitor#adjustURL()
		 */
		public static function adjustURL(url:String, correlationID:String=null):String {
			if ( !monitor ) return url;
			return monitor.adjustURL( url, correlationID );
		}
		
		/**
		 * @copy	by.blooddy.core.net.monitor.INetMonitor#adjustURLRequest()
		 */
		public static function adjustURLRequest(correlationID:String, request:URLRequest):void {
			if ( !monitor ) return;
			monitor.adjustURLRequest( correlationID, request );
		}
		
		/**
		 * @copy	by.blooddy.core.net.monitor.INetMonitor#monitorInvocation()
		 */
		public static function monitorInvocation(correlationID:String, request:URLRequest, loader:ILoadable):void {
			if ( !monitor ) return;
			monitor.monitorInvocation( correlationID, request, loader );
		}

	}
	
}