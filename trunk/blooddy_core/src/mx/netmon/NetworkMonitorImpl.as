////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 q1
//
////////////////////////////////////////////////////////////////////////////////

package mx.netmon {

	import by.blooddy.core.net.NetworkMonitor;

	[Mixin]
	[ExcludeClass]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Feb 25, 2010 5:24:51 PM
	 */
	public class NetworkMonitorImpl {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public static function init(...rest):void {
			trace( by.blooddy.core.net.NetworkMonitor + ' initialization...' );
		}

	}
	
}