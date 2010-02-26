////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data {

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
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected_data;

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
			throw new IllegalOperationError( getErrorMessage( 2071, this, 'name' ), 2071 );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		$protected_data override function setParent(value:DataContainer):void {
			throw new ArgumentError();
		}
		
	}

}