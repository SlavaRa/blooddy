////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.net.URLRequest;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Транслируется, когда Flash Player может определить
	 * HTTP статус.
	 * 
	 * @eventType			flash.events.HTTPStatusEvent.HTTP_STATUS
	 */
	[Event( name="httpStatus", type="flash.events.HTTPStatusEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					iloader
	 */
	public interface ILoader extends ILoadable {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  url
		//----------------------------------

		/**
		 * Путь по которому загружаются данные.
		 * 
		 * @keyword					loader.url, url
		 */
		function get url():String;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy			flash.net.URLLoader#load()
		 */
		function load(request:URLRequest):void;

		/**
		 * @copy			flash.net.URLLoader#close()
		 */
		function close():void;

	}

}