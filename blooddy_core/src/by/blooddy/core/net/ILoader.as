////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Транслируется, когда Flash Player может определить HTTP статус.
	 * 
	 * @eventType			flash.events.HTTPStatusEvent.HTTP_STATUS
	 */
	[Event( name="httpStatus", type="flash.events.HTTPStatusEvent" )]

	/**
	 * Транслируется, когда Flash Player может определить получиться HTTP-заголовки
	 * 
	 * @eventType			flash.events.HTTPStatusEvent.HTTP_RESPONSE_STATUS
	 */
	[Event( name="httpResponseStatus", type="flash.events.HTTPStatusEvent" )]
	
	[Event( name="init", type="flash.events.Event" )]
	
	[Event( name="unload", type="flash.events.Event" )]
	
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
		 * начинает загрузку файла
		 * 
		 * @param	bytes		бинарник
		 * 
		 * @event	open
		 * @event	httpStatus
		 * @event	progress
		 * @event	complete
		 * @event	ioError
		 * @event	securityError
		 * 
		 * @throw	ArgumentError	если мы не в состоянии idle
		 * 
		 * @copy			flash.net.URLLoader#load()
		 */
		function load(request:URLRequest):void;

		/**
		 * орабатывает бинарник. локальная загрузка
		 * 
		 * @param	request		запрос
		 * 
		 * @event	open
		 * @event	httpStatus
		 * @event	progress
		 * @event	complete
		 * @event	ioError
		 * @event	securityError
		 * 
		 * @throw	ArgumentError	если мы не в состоянии idle
		 * 
		 * @copy			flash.net.Loader#loadBytes()
		 */
		function loadBytes(bytes:ByteArray):void;
		
		/**
		 * останавливает загрузку, и выгружает данные
		 * @copy			flash.net.URLLoader#close()
		 */
		function close():void;

		/**
		 * выгружает загруженный контент
		 * @copy			flash.net.Loader#unload()
		 */
		function unload():void;
		
	}

}