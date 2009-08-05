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
	import by.blooddy.core.events.time.TimeEvent;
	import by.blooddy.core.managers.IProgressable;
	import by.blooddy.core.net.AbstractRemoter;
	import by.blooddy.core.utils.time.RelativeTime;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import ru.avangardonline.database.battle.BattleData;
	import ru.avangardonline.database.character.CharacterData;

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
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const TICK_TIME:uint = 1E3;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleLogicalController(controller:IBaseController!, time:RelativeTime!) {
			super();
			this._baseController = controller;
			this._time = time;
			this._time.addEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.handler_timeRelativityChange );
			var dataBase:DataBase = this._baseController.dataBase;
			var child:Data = dataBase.getChildByName( 'battleData' );
			if ( child ) {
				if ( child is BattleData ) this._data = child as BattleData;
				else dataBase.removeChild( child );
			}
			if ( !this._data ) {
				this._data = new BattleData();

				this._data.world.field.width = 9;
				this._data.world.field.height = 5;

				var id:uint = 0;
				var x:int;
				var y:int;
				var character:CharacterData;
				for ( y=0; y<5; y++ ) {
					for ( x = -4; x < -1; x++ ) {
						character = new CharacterData( ++id );
						character.x = x;
						character.y = y;
						this._data.world.characters.addChild( character );
					}
				}

				dataBase.addChild( this._data );
			}
			this._timer.addEventListener( TimerEvent.TIMER, this.updateTick );
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

		/**
		 * @private
		 */
		private const _timer:Timer = new Timer( 0 );

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

		public function get progress():Number {
			return this._totalTicks * TICK_TIME / this._time.currentTime;
		}

		/**
		 * @private
		 */
		public function set progress(value:Number):void {
			this._time.currentTime = this._totalTicks * ( value || 0 ) * TICK_TIME;
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
		private var _time:RelativeTime;

		public function get time():RelativeTime {
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
			if ( value >= this._totalTicks ) throw new RangeError(); 
			if ( this._currentTick == value ) return;
			this._time.currentTime = value * TICK_TIME;
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
		private function updateTick(event:Event=null):void {
			var newTick:uint = this._time.currentTime / TICK_TIME;
			if ( newTick == this._currentTick ) return;
			this._currentTick = newTick;
			// TODO: update model
			super.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this._currentTick, this._totalTicks ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_timeRelativityChange(event:TimeEvent):void {
			if ( this._time.speed ) {
				this._timer.delay = TICK_TIME / this._time.speed / 4;
				if ( !this._timer.running ) {
					this._timer.start();
				}
			} else {
				if ( this._timer.running ) {
					this._timer.stop();
				}
			}
			this.updateTick( event );
		}

	}

}