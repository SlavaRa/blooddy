////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.monitor {
	
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

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy	by.blooddy.core.net.monitor.INetMonitor#isActive
		 */
		public static function get isActive():Boolean {
			return ( monitor ? monitor.isActive : false );
		}
		
	}
	
}