////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.managers {

	/**
	 * Интерфейс пучка ресурсов.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					resourcebundle, resource, bundle
	 */
	public interface IResourceBundle {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  name
		//----------------------------------

	    /**
	     * Имя пучка.
	     * 
		 * @keyword					resourcebundle.name, name
	     */
		function get name():String;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

	    /**
	     * Запрашивает ресурс по имени.
	     * 
	     * @param	name			Имя ресурса.
	     * 
	     * @return					Возвращает ресурс.
	     * 
		 * @keyword					resourcebundle.getobject, getobject
	     */
		function getObject(name:String):*;

	}

}