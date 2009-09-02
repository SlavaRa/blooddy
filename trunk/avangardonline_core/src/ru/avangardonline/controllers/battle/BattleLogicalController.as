////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.controllers.battle {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.controllers.IBaseController;
	import by.blooddy.core.controllers.IController;
	import by.blooddy.core.data.DataBase;
	import by.blooddy.core.events.time.TimeEvent;
	import by.blooddy.core.managers.IProgressable;
	import by.blooddy.core.net.AbstractRemoter;
	import by.blooddy.core.utils.time.RelativeTime;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import ru.avangardonline.data.battle.BattleData;
	import ru.avangardonline.data.battle.actions.BattleActionData;
	import ru.avangardonline.data.battle.actions.BattleWorldElementActionData;
	import ru.avangardonline.data.battle.turns.BattleTurnData;
	import ru.avangardonline.data.battle.turns.BattleTurnWorldElementCollectionData;
	import ru.avangardonline.data.battle.turns.BattleTurnWorldElementContainerData;
	import ru.avangardonline.data.battle.world.BattleWorldElementCollectionData;

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
		public function BattleLogicalController(controller:IBaseController!) {
			super();
			this._baseController = controller;
			this._timer.addEventListener( TimerEvent.TIMER, this.updateBattle );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _lastUpdate:Number = 0;

		/**
		 * @private
		 */
		private var _inBattle:Boolean = false;

		/**
		 * @private
		 */
		private var _collections:BattleTurnWorldElementCollectionData;

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
			return 0;//this._time.currentTime / ( this.totalTicks * TICK_TIME );
		}

		/**
		 * @private
		 */
		public function set progress(value:Number):void {
			//this._time.currentTime = this.totalTicks * ( value || 0 ) * TICK_TIME;
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
		//  currentTurn
		//----------------------------------

		/**
		 * @private
		 */
		private var _currentTurn:uint = 0;

		public function get currentTurn():uint {
			return this._currentTurn;
		}

		/**
		 * @private
		 */
		public function set currentTurn(value:uint):void {
			if ( this._currentTurn == value ) return;
			if ( this._currentTurn > this._battle.numTurns ) throw new RangeError();
			//this.currentTick = value * BattleTurnData.TURN_DELAY;
		}

		//----------------------------------
		//  totalTurns
		//----------------------------------

		public function get totalTurns():uint {
			return this._battle.numTurns;
		}

		//----------------------------------
		//  totalTurns
		//----------------------------------

		/**
		 * @private
		 */
		private var _battle:BattleData;

		public function get battle():BattleData {
			return this._battle;
		}

		/**
		 * @private
		 */
		public function set battle(value:BattleData):void {
			if ( this._battle === value ) return;

			if ( this._battle ) {

				if ( this._inBattle ) {
					this.exitBattle();
				}

				this._time.removeEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.handler_timeRelativityChange );
				this._time = null;

				this._collections.removeChild( this._collections );
				this._collections = null;

				this._baseController.dataBase.removeChild( this._battle );

			}
			
			this._battle = value;

			if ( this._battle ) {

				this._baseController.dataBase.addChild( this._battle );

				this._collections = new BattleTurnWorldElementCollectionData();
				this._collections.addChild( new BattleTurnWorldElementContainerData( 0, this._battle.world.elements.clone() as BattleWorldElementCollectionData ) );
				this._baseController.dataBase.addChild( this._collections );

				this._time = this._battle.time;
				this._time.currentTime = 0;
				this._time.speed = 0;
				this._time.addEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.handler_timeRelativityChange );

				if ( this._inBattle ) {
					this.call_enterBattle();
				}

			}
		}


		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		protected override function $callOutputCommand(command:Command):* {
			( this[ command.name ] as Function ).apply( this, command );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function $call(commandName:String, ...parameters):* {
			return this.$invokeCallInputCommand( new Command( commandName, parameters ), false );
		}

		/**
		 * @private
		 */
		private function updateBattle(event:Event=null):void {

			var prevUpdate:Number = this._lastUpdate;
			var nextUpdate:Number = this._time.currentTime;
			this._lastUpdate = nextUpdate;

			var prevTurn:int = this._currentTurn;
			var nextTurn:int = nextUpdate / BattleTurnData.TURN_DELAY;
			if ( nextTurn >= this._battle.numTurns ) {
				nextTurn = this._battle.numTurns;
				if ( prevTurn == nextTurn && this._lastUpdate >= ( nextTurn * BattleTurnData.TURN_DELAY ) ) { 
					if ( this._time.currentTime >= ( ( nextTurn - 1 ) * BattleTurnData.TURN_DELAY ) + BattleTurnData.TURN_LENGTH ) {
						this._time.speed = 0;
					}
					return;
				}
			}
			this._currentTurn = nextTurn;
			// поизошёл сильный скачёк. надо сбросить всё нафиг
			var dt:int = nextTurn - prevTurn;
			if ( dt != 0 && dt != 1 ) { // поизошёл тотальный пиздец :(
				this._lastUpdate = nextTurn * BattleTurnData.TURN_DELAY;
				prevTurn = nextTurn;
				this.syncElements();
			}
			// надо запустить все экшены, которые подходят по времени
			var turn:BattleTurnData;
			var actions:Vector.<BattleActionData>;
			turn = this._battle.getTurn( prevTurn );
			if ( turn ) {
				actions = turn.getActions();
			}
			turn = this._battle.getTurn( nextTurn );
			if ( turn ) {
				if ( actions ) {
					actions = actions.concat( turn.getActions() );
				} else {
					actions = turn.getActions();
				}
			}
			var command:Command;
			for each ( var action:BattleActionData in actions ) {
				if ( action.startTime >= prevUpdate && action.startTime < nextUpdate ) {
					for each ( command in action.getCommands() ) {
						this.$invokeCallInputCommand( command );
					}
				}
			}
		}

		/**
		 * @private
		 */
		private function syncElements():void {
			this.syncTurns();
			this.$call(
				'syncElements',
				this._collections.getCollection( this._currentTurn ).collection
			);
		}

		/**
		 * @private
		 */
		private function syncTurns():void {

			var i:uint = this._collections.numTurns;
			var l:uint = this._currentTurn;

			if ( i > l ) return;
			// состояние этого хода ещё не рассчитывалось

			var action:BattleActionData;
			var collection:BattleWorldElementCollectionData = this._collections.getCollection( i-1 ).collection;

			for ( i; i<=l; i++ ) {
				collection = collection.clone() as BattleWorldElementCollectionData;
				for each ( action in this._battle.getTurn( i ).getActions() ) {
					if ( action is BattleWorldElementActionData ) {
						( action as BattleWorldElementActionData ).apply( collection );
					}
				}
				this._collections.addChild( new BattleTurnWorldElementContainerData( i, collection ) );
			}

		}

		/**
		 * @private
		 */
		private function call_enterBattle():void {
			this.$call( 'enterBattle', this._battle.world.field );
			this.syncElements();
			this._time.currentTime = 0;
			this._time.speed = 1;
		}

		//--------------------------------------------------------------------------
		//
		//  Client handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function enterBattle():void {
			if ( this._inBattle ) throw new ArgumentError();
			this._inBattle = true;
			if ( this._battle ) {
				this.call_enterBattle();
			}
		}

		/**
		 * @private
		 */
		private function exitBattle():void {
			this._inBattle = false;
			this.$call( 'exitBattle' );
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
				this._timer.delay = BattleTurnData.TURN_DELAY / this._time.speed / 16;
				if ( !this._timer.running ) {
					this._timer.start();
				}
			} else {
				if ( this._timer.running ) {
					this._timer.stop();
				}
			}
			this.updateBattle( event );
		}

	}

}