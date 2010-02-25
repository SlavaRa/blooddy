////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					25.02.2010 9:40:35
	 */
	public final class NetworkMonitor {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _CLASS_NAME:String = 'mx.netmon::NetworkMonitor';

		/**
		 * @private
		 */
		private static var _CLASS:Class;
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function isMonitoring():Boolean {
			if ( !Capabilities.isDebugger ) return false;
			var c:Class = getClass();
			return ( c && c.isMonitoring() );
			return false;
		}

		public static function adjustURLRequest(urlRequest:URLRequest, rootURL:String, correlationID:String):void {
			if ( !_CLASS ) return;
			_CLASS.adjustURLRequest( urlRequest, rootURL, correlationID );
		}

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		private static function getClass():Class {
			var domain:ApplicationDomain = ApplicationDomain.currentDomain;
			if ( !_CLASS && domain.hasDefinition( _CLASS_NAME ) ) {
				_CLASS = domain.getDefinition( _CLASS_NAME ) as Class;
			}
			return _CLASS;
		}

	}
	
}