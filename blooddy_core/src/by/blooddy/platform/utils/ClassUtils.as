////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 BlooDHounD.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.utils {

	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	
	/**
	 * Утилиты для работы с классами.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					сlassutils, class, utils
	 */
	public final class ClassUtils {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @param	value			Объект, имя класса, которого нужно узнать.
		 *
		 * @return					Имя класса.
		 *
		 * @keyword 				classutils.getclassname, getclassname, classname, class
		 *
		 * @see						flash.utils.getQualifiedClassName()
		 */
		public static function getClassName(value:Object):String {
			var name:String = getQualifiedClassName(value);
			var index:int = name.lastIndexOf("::");
			if (index>0) name = name.substr(index + 2);
			return name;
		}
		
		/**
		 * @param	value			Объект, имя класса, которого нужно узнать.
		 *
		 * @return					Имя класса.
		 *
		 * @keyword 				classutils.getsuperclassname, getsuperclassname, supercclassname, classname, class
		 *
		 * @see						flash.utils.getQualifiedSuperclassName()
		 */
		public static function getSuperclassName(value:Object):String {
			var name:String = getQualifiedSuperclassName(value);
			var index:int = name.lastIndexOf("::");
			if (index>0) name = name.substr(index + 2);
			return name;
		}
	}

}