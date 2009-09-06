////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Пришли данные от сервера.
	 *
	 * @eventType				flash.events.DataEvent.DATA
	 */
	[Event( name="data", type="flash.events.DataEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					ixmlsocket, xmlsocket, socket, xml
	 */
	public interface IXMLSocket extends IAbstractSocket {

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Отсылает данные на сервер.
		 * 
		 * @param	object			Отсылается на сервер.
		 * 
		 * @throw	ArgumentError	Мы не приконектились ещё.
		 * 
		 * @keyword					xmlsocket.send, send
		 * 
		 * @see						#connect()
		 */
		function send(object:*):void;

	}

}