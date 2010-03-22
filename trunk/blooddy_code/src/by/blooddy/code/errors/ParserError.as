////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.errors {

	import by.blooddy.core.utils.ClassUtils;

	/**
	 * Ошибка парсинга.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					parsererror, parser, error
	 */
	public class ParserError extends Error {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function ParserError(message:String='', id:int=0) {
			super( message, id );
			this.name = ClassUtils.getClassName( this );
		}

		public function toString():String {
			return this.name + ' #' + super.errorID + ': ' + super.message;
		}

	}

}