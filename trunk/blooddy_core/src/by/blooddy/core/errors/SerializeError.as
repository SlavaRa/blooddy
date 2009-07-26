package by.blooddy.core.errors {

	import by.blooddy.core.errors.ParserError;

	/**
	 * Ошибка парсинга.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					serializeerror, serialize, error
	 */
	public class SerializeError extends ParserError {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function SerializeError(message:String="", id:int=0, data:*=null) {
			super(message, id);
			this.data = data;
		}

		public var data:*;

	}

}