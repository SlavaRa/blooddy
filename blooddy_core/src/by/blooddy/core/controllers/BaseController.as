////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.controllers {

	import by.blooddy.core.database.DataBase;
	import by.blooddy.core.net.ProxySharedObject;
	
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					basecontroller, controller
	 */
	public class BaseController extends EventDispatcher implements IBaseController {

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
			if ( !container || !dataBase || !sharedObject ) throw new ArgumentError();
			this._dataBase = dataBase;
			this._container = container;
			this._sharedObject = sharedObject;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties: IGameController
		//
		//--------------------------------------------------------------------------

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
		//  Overriden methods: SocketConnection
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public virtual function call(commandName:String, ...arguments):* {
			throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  Server handlers
		//
		//--------------------------------------------------------------------------

	}

}