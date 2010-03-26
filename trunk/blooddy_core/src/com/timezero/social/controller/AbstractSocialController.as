////////////////////////////////////////////////////////////////////////////////
//
//  © 2004—2008 TimeZero LLC.
//
////////////////////////////////////////////////////////////////////////////////

package com.timezero.social.controller {

	import com.timezero.platform.controllers.IBaseController;
	import com.timezero.platform.controllers.IController;
	import com.timezero.platform.database.DataBase;
	import com.timezero.platform.net.AbstractRemoter;
	import com.timezero.platform.utils.Command;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class AbstractSocialController extends AbstractRemoter implements IController {
		
		//--------------------------------------------------------------------------
		//
		// Class Varibles
		//
		//--------------------------------------------------------------------------
		
		public static const SOCIAL_FACEBOOK:uint	= 3;
		public static const SOCIAL_VKONTAKTE:uint	= 4;
		public static const SOCIAL_MYWORLD:uint		= 5;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function AbstractSocialController(controller:IBaseController) {
			super();
			this._baseConstroller = controller;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  baseController
		//----------------------------------

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

		//----------------------------------
		//  dataBase
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get dataBase():DataBase {
			return this._baseConstroller.dataBase;
		}

		//----------------------------------
		//  sharedObject
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get sharedObject():Object {
			return this._baseConstroller.sharedObject;
		}

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		protected namespace social;

		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		protected override function $callOutputCommand(command:Command):* {
			return command.call( this, social );
		}

	}

}