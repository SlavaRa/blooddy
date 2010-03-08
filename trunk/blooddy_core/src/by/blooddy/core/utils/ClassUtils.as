////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.utils.getDefinitionByName;
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

		public static function cutClassName(name:String):String {
			var index:int = name.lastIndexOf( '::' );
			if ( index > 0 ) name = name.substr( index + 2 );
			return name;
		}

		/**
		 * @param	value			Объект, имя класса, которого нужно узнать.
		 *
		 * @return					Имя класса.
		 *
		 * @keyword 				classutils.getclassname, getclassname, classname, class
		 *
		 * @see						flash.utils.getQualifiedClassName()
		 */
		public static function getClassName(o:Object):String {
			return cutClassName( getQualifiedClassName( o ) );
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
		public static function getSuperclassName(o:Object):String {
			return cutClassName( getQualifiedSuperclassName( o ) );
		}

		public static function getClass(o:Object):Class {
			try {
				return getDefinitionByName( getQualifiedClassName( o ) ) as Class;
			} catch ( e:Error ) {
			}
			return null;
		}

		public static function getSuperclass(o:Object):Class {
			var name:String = getQualifiedSuperclassName( o );
			if ( name ) {
				try {
					return getDefinitionByName( name ) as Class;
				} catch ( e:Error ) {
				}
			}
			return null;
		}

	}

}