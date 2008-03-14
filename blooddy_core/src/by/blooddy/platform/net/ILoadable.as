////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.net {

	import flash.events.IEventDispatcher;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Транслируется, когда загрузка заканчивается.
	 * 
	 * @eventType			flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")]

	/**
	 * Ошибка.
	 * 
	 * @eventType			flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")]

	/**
	 * Транслируется, когда начинается загрузка.
	 * 
	 * @eventType			flash.events.Event.OPEN
	 */
	[Event(name="open", type="flash.events.Event")]

	/**
	 * Транслиуется, когда приходят байты данных.
	 * 
	 * @eventType			flash.events.ProgressEvent.PROGRESS
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					iloadable
	 */
	public interface ILoadable extends IEventDispatcher {
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  loaded
		//----------------------------------

	    [Bindable("complete")]
		/**
		 * @copy			flash.net.URLLoader#loaded
		 */
		function get loaded():Boolean;

		//----------------------------------
		//  bytesLoaded
		//----------------------------------

	    [Bindable("progress")]
		/**
		 * @copy			flash.net.URLLoader#bytesLoaded
		 */
		function get bytesLoaded():uint;

		//----------------------------------
		//  bytesTotal
		//----------------------------------

	    [Bindable("complete")]
		/**
		 * @copy			flash.net.URLLoader#bytesTotal
		 */
		function get bytesTotal():uint;

	}

}