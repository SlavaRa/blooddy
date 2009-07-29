////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.controllers.battle {

	import by.blooddy.core.controllers.IBaseController;
	import by.blooddy.core.controllers.IController;
	import by.blooddy.core.database.Data;
	import by.blooddy.core.database.DataBase;
	import by.blooddy.core.managers.IProgressable;
	import by.blooddy.core.net.AbstractRemoter;
	
	import flash.events.ProgressEvent;
	
	import ru.avangardonline.database.battle.BattleData;
	import by.blooddy.core.utils.time.RelativeTime;
	import by.blooddy.core.utils.time.Time;
	import by.blooddy.core.events.time.TimeEvent;

	[Event(name="progress", type="flash.events.ProgressEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class BattleLogicalController extends AbstractRemoter implements IController, IProgressable {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleLogicalController(controller:IBaseController, time:Time) {
			super();
			this._baseController = controller;
			this._time = time;
			this._time.addEventListener( TimeEvent.RELATIVITY_CHANGE, this.handler_relativityChange );
			var dataBase:DataBase = this._baseController.dataBase;
			var child:Data = dataBase.getChildByName( 'battleData' );
			if ( child ) {
				if ( child is BattleData ) this._data = child as BattleData;
				else dataBase.removeChild( child );
			}
			if ( !this._data ) {
				this._data = new BattleData();
				dataBase.addChild( this._data );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _data:BattleData;

		//--------------------------------------------------------------------------
		//
		//  Implements properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  baseController
		//----------------------------------

		/**
		 * @private
		 */
		private var _baseController:IBaseController;

		/**
		 * @inheritDoc
		 */
		public function get baseController():IBaseController {
			return this._baseController;
		}

		//----------------------------------
		//  dataBase
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get dataBase():DataBase {
			return this._baseController.dataBase;
		}
		
		//----------------------------------
		//  sharedObject
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get sharedObject():Object {
			return this._baseController.sharedObject;
		}

		//----------------------------------
		//  progress
		//----------------------------------

		/**
		 * @private
		 */
		private var _progress:Number = 0;

		public function get progress():Number {
			return this._progress;
		}

		/**
		 * @private
		 */
		public function set progress(value:Number):void {
			if ( this._progress == value ) return;
			this.currentTick = this._totalTicks * ( value || 0 );
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
		//  currentTick
		//----------------------------------

		/**
		 * @private
		 */
		private var _currentTick:uint = 0;

		public function get currentTick():uint {
			return this._currentTick;
		}

		/**
		 * @private
		 */
		public function set currentTick(value:uint):void {
			if ( this._currentTick == value ) return;
			if ( value > this._totalTicks ) value = ( totalTicks ? totalTicks - 1 : 0 );
			if ( this._currentTick == value ) return;
			this._currentTick = value;
			this._progress = ( this._totalTicks ? this._currentTick / ( this._totalTicks - 1 ) : 0 );
			this.updateTick();
			super.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this._currentTick, this._totalTicks ) );
		}

		//----------------------------------
		//  totalTicks
		//----------------------------------

		/**
		 * @private
		 */
		private var _totalTicks:uint = 1;

		public function get totalTicks():uint {
			return this._totalTicks;
		}

		//----------------------------------
		//  currentTurn
		//----------------------------------

		public function get currentTurn():uint {
			return 0;
		}

		/**
		 * @private
		 */
		public function set currentTurn(value:uint):void {
		}

		//----------------------------------
		//  totalTurns
		//----------------------------------

		public function get totalTurns():uint {
			return 0;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updateTick():void {
			// TODO: пресчёт модели в зависимости от времени
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_relativityChange(event:TimeEvent):void {
			this.time.currentTime; //
		}

	}

}