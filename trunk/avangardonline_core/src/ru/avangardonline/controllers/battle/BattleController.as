////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.controllers.battle {

	import by.blooddy.core.controllers.AbstractController;
	import by.blooddy.core.controllers.IBaseController;
	import by.blooddy.core.utils.IAbstractRemoter;
	import by.blooddy.core.utils.time.Time;
	
	import flash.display.DisplayObjectContainer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class BattleController extends AbstractController {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleController(controller:IBaseController, time:Time, remoter:IAbstractRemoter, container:DisplayObjectContainer) {
			super( controller );
			this._time = time;
			this._container = container;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  time
		//----------------------------------

		/**
		 * @private
		 */
		private var _time:Time;

		public function get time():Time {
			return this._time;
		}

		//----------------------------------
		//  container
		//----------------------------------

		/**
		 * @private
		 */
		private var _container:DisplayObjectContainer;

		public function get container():DisplayObjectContainer {
			return this._container;
		}

	}

}