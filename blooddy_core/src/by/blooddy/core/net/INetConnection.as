////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					iconnection, connection
	 */
	public interface INetConnection extends IConnection, IAbstractSocket {

		//----------------------------------
		//  connectionType
		//----------------------------------

		/**
		 * Тип прокси соединение.
		 *
		 * @keyword					connection.connectionType, connectionType
		 */
		function get connectionType():String;

		/**
		 * @private
		 */
		function set connectionType(value:String):void;

	}

}