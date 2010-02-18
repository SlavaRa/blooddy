////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.controllers {

	import by.blooddy.core.commands.CommandDispatcher;
	import by.blooddy.core.data.DataBase;
	import by.blooddy.core.errors.getErrorMessage;
	import by.blooddy.core.net.ProxySharedObject;
	
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					basecontroller, controller
	 */
	public class BaseController extends CommandDispatcher implements IBaseController {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BaseController(container:DisplayObjectContainer!, dataBase:DataBase!, sharedObject:ProxySharedObject!) {
			super();
			if ( !container )		throw new ArgumentError( getErrorMessage( 2007, this, 'BaseController', 'container' ),		2007 );
			if ( !dataBase )		throw new ArgumentError( getErrorMessage( 2007, this, 'BaseController', 'dataBase' ),		2007 );
			if ( !sharedObject )	throw new ArgumentError( getErrorMessage( 2007, this, 'BaseController', 'sharedObject' ),	2007 );
			this._dataBase = dataBase;
			this._container = container;
			this._sharedObject = sharedObject;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  container
		//----------------------------------

		/**
		 * @private
		 */
		private var _container:DisplayObjectContainer;

		/**
		 * @inheritDoc
		 */
		public function get container():DisplayObjectContainer {
			return this._container;
		}

		//----------------------------------
		//  baseController
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get baseController():IBaseController {
			return this;
		}

		//----------------------------------
		//  database
		//----------------------------------

		/**
		 * @private
		 */
		private var _dataBase:DataBase;

		/**
		 * @inheritDoc
		 */
		public function get dataBase():DataBase {
			return this._dataBase;
		}
		
		//----------------------------------
		//  sharedObject
		//----------------------------------

		/**
		 * @private
		 */
		private var _sharedObject:ProxySharedObject;

		/**
		 * @inheritDoc
		 */
		public function get sharedObject():Object {
			return this._sharedObject;
		}		

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public virtual function call(commandName:String, ...arguments):* {
			throw new IllegalOperationError( getErrorMessage( 2071, this, 'call' ), 2071 );
		}

	}

}