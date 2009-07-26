////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.logging.ConnectionLogger;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					iconnection, connection
	 */
	public interface IConnection extends IRemoter {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  connected
		//----------------------------------

		/**
		 * true, если соединение установленно.
		 * false, если разорванно, или ещё не установленно.
		 *
		 * @keyword					iconnection.connected, connected
		 */
		function get connected():Boolean;

		//----------------------------------
		//  logger
		//----------------------------------

		/**
		 * Логгер команд.
		 *
		 * @keyword					iconnection.logger, logger
		 */
		function get logger():ConnectionLogger;

		//----------------------------------
		//  logging
		//----------------------------------

		/**
		 * Логгер команд.
		 *
		 * @keyword					iconnection.logging, logging
		 */
		function get logging():Boolean;

		/**
		 * @private
		 */
		function set logging(value:Boolean):void;

	}

}