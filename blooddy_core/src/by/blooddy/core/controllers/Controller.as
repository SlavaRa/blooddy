////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.controllers {

	import by.blooddy.core.database.DataBase;
	
	import flash.events.EventDispatcher;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class Controller extends EventDispatcher implements IController {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function Controller(controller:IBaseController) {
			super();
			this._baseConstroller = controller;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _baseConstroller:IBaseController;

		/**
		 * @inheritDoc
		 */
		public function get baseController():IBaseController {
			return this._baseConstroller;
		}

		/**
		 * @inheritDoc
		 */
		public function get dataBase():DataBase {
			return this._baseConstroller.dataBase;
		}

		/**
		 * @inheritDoc
		 */
		public function get sharedObject():Object {
			return this._baseConstroller.sharedObject;
		}

	}

}