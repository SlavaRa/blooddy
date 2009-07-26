////////////////////////////////////////////////////////////////////////////////
//
//  © 2004—2008 TimeZero LLC.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.events.IEventDispatcher;
	import by.blooddy.core.utils.IAbstractRemoter;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					iremoter
	 */
	public interface IRemoter extends IEventDispatcher, IAbstractRemoter {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  client
		//----------------------------------

		/**
		 * Тута будут вызываться функи.
		 * 
		 * @keyword					iremoter.client, client
		 */
		function get client():Object;

		/**
		 * @private
		 */
		function set client(value:Object):void;

	}

}