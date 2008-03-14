////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 BlooDHounD.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.errors {

	import by.blooddy.platform.utils.getCallerInfo;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					errorsmanager, error, manager
	 */
	public class ErrorsManager {

		//--------------------------------------------------------------------------
		//
		//  Private class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const PATTERNT_CLASS_NAME:RegExp = /%className/g;

		/**
		 * @private
		 */
		private static const PATTERNT_METHOD_NAME:RegExp = /%methodName|%className/g;

		/**
		 * @private
		 */
		private static const PATTERNT_PROPERTY_NAME:RegExp = /%propertyName|%methodName/g;

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @param	errorID		Код ршибки.
		 * @param	replaces	Замены.
		 * 
		 * @return				Возращает текстовый вид ошибки с заменами.
		 */
		public static function getErrorMessage(errorID:int, ...replaces):String {
			if (messages.hasOwnProperty(errorID)) {
				var message:String = messages[errorID];
				var info:XML = getCallerInfo();
				// определим всякие родные свойства
				var className:String = info.@name.toXMLString();
				if (className) message = message.replace( PATTERNT_CLASS_NAME, className );
				var methodName:String = info.method.@name.toXMLString();
				if (methodName) message = message.replace( PATTERNT_METHOD_NAME, methodName );
				var propertyName:String = info.accessor.@name.toXMLString();
				if (propertyName) message = message.replace( PATTERNT_PROPERTY_NAME, propertyName );
				// пройдёмся про реплэйсам
				for (var i:uint = 0; i<replaces.length; i++) {
					message = message.replace(new RegExp("%s"+i, "g"), replaces[i]);
				}
				return "Error #"+errorID+": "+message;
			}
			return "";
		}

		//--------------------------------------------------------------------------
		//
		//  Private class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Сюда записываем коды ошибок.
		 */
		private static const messages:Object = {

			1034: "Type Coercion failed: cannot convert %s0 to %s1.",
			1056: "Cannot create property %propertyName on %className.",
			1069: "Property %propertyName not found on %className and there is no default value.",

			2002: "Operation attempted on invalid socket.",
			2006: "The supplied index is out of bounds.",
			2007: "Parameter child must be non-null.",
			2012: "%className class cannot be instantiated.",
			2024: "An object cannot be added as a child of itself.",
			2025: "The supplied %className must be a child of the caller.",
			2029: "This %className object does not have a stream opened.",
			2071: "The %className class does not implement this property or method.",
			2124: "Loaded file is an unknown type.",
			2150: "An object cannot be added as a child to one of it's children (or children's children, etc.)."
			// наши ошибки

		}

	}

}