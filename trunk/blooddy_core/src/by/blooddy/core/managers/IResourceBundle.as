////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers {

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

		//----------------------------------
		//  empty
		//----------------------------------

	    /**
	     * Имя пучка.
	     * 
		 * @keyword					resourcebundle.name, name
	     */
		function get empty():Boolean;

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
		 * @keyword					resourcebundle.getresource, getresource
	     */
		function getResource(name:String):*;

		function hasResource(name:String):Boolean;

		[ArrayElementType('String')]
		function getResources():Array;

	}

}