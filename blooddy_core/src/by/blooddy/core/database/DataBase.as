////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.database {

	import by.blooddy.core.errors.getErrorMessage;
	
	import flash.errors.IllegalOperationError;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					database, data
	 */
	public final class DataBase extends DataContainer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function DataBase() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: Data
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  id
		//----------------------------------

		/**
		 * @private
		 */
		public override function set name(value:String):void {
			throw new IllegalOperationError( getErrorMessage( 2071 ), 2071 );
		}

	}

}