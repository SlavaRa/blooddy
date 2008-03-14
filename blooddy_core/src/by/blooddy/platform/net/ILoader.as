////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.net {

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
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]

	/**
	 * Секъюрная ошибка.
	 * 
	 * @eventType			flash.events.SecurityErrorEvent.SECURITY_ERROR
	 */
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]

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

	    [Bindable("open")]
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