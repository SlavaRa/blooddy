////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.net {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					iloaderdispatcher, loaderdispatcher, loader
	 * 
	 * @see						platform.net.ILoadable
	 */
	public interface ILoaderDispatcher extends ILoadable {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  enabled
		//----------------------------------

		[Inspectable( type="Boolean" )]
		/**
		 * Включен ли наш обработчик.
		 * 
		 * @keyword					loaderdispatcher.enabled, enabled
		 */
		function get enabled():Boolean;

		/**
		 * @private
		 */
		function set enabled(value:Boolean):void;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Добавляет в слежку лоадер.
		 * 
		 * @param	loader			Лоадер.
		 * 
		 * @keyword					loaderdispatcher.addLoaderListener, addLoaderListener
		 */
		function addLoaderListener(loader:ILoadable):void;

		/**
		 * Удаляет из слежки лоадер.
		 * 
		 * @param	loader			Лоадер.
		 * 
		 * @keyword					loaderdispatcher.removeLoaderListener, removeLoaderListener
		 */
		function removeLoaderListener(loader:ILoadable):void;

		/**
		 * Проверяет наличие в слежке лоадера.
		 * 
		 * @param	loader			Лоадер.
		 * 
		 * @return					true, если есть, false, если нету.
		 * 
		 * @keyword					loaderdispatcher.hasLoaderListener, hasLoaderListener
		 */
		function hasLoaderListener(loader:ILoadable):Boolean;
		
	}

}