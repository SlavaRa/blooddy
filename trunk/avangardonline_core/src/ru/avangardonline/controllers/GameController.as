////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.controllers {

	import by.blooddy.core.controllers.BaseController;
	import by.blooddy.core.database.DataBase;
	import by.blooddy.core.net.ProxySharedObject;
	import by.blooddy.core.utils.time.RelativeTime;
	
	import flash.display.DisplayObjectContainer;
	
	import ru.avangardonline.controllers.battle.BattleController;
	import ru.avangardonline.controllers.battle.BattleLogicalController;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class GameController extends BaseController {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function GameController(container:DisplayObjectContainer) {
			super( container, new DataBase(), ProxySharedObject.getLocal( 'avangard' ) );

			this._battleLogicalController =	new BattleLogicalController	( this, this._relativeTime );
			this._battleController =		new BattleController		( this, this._relativeTime, this._battleLogicalController, container );
			
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _battleController:BattleController;

		/**
		 * @private
		 */
		private var _battleLogicalController:BattleLogicalController;

		/**
		 * @private
		 */
		private const _relativeTime:RelativeTime = new RelativeTime();

	}

}