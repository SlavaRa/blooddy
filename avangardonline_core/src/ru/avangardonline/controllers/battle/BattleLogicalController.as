////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.controllers.battle {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.controllers.IBaseController;
	import by.blooddy.core.controllers.IController;
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
	import ru.avangardonline.database.battle.actions.BattleActionData;
	import ru.avangardonline.database.battle.actions.BattleWorldElementActionData;
	import ru.avangardonline.database.battle.turns.BattleTurnData;
	import ru.avangardonline.database.battle.turns.BattleTurnWorldElementCollectionData;
	import ru.avangardonline.database.battle.turns.BattleTurnWorldElementContainerData;
	import ru.avangardonline.database.battle.world.BattleWorldElementCollectionData;

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
		public function BattleLogicalController(controller:IBaseController!) {
			super();
			this._baseController = controller;
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
			return this._time.currentTime / ( this.totalTicks * TICK_TIME );
		}

		/**
		 * @private
		 */
		public function set progress(value:Number):void {
			this._time.currentTime = this.totalTicks * ( value || 0 ) * TICK_TIME;
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
			if ( value >= this.totalTicks ) throw new RangeError(); 
			if ( this._currentTick == value ) return;
			this._time.currentTime = value * TICK_TIME;
		}

		//----------------------------------
		//  totalTicks
		//----------------------------------

		public function get totalTicks():uint {
			return this.totalTurns * 4;
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
			if ( this._currentTick >= this._battle.numTurns ) throw new RangeError();
			this.currentTick = value * BattleTurnData.TURN_TIME;
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
/*
			this._battle.world.field.width = 11;
			this._battle.world.field.height = 5;

			var id:uint = 0;
			var x:int;
			var y:int;
			var character:CharacterData;
			for ( y=0; y<5; y++ ) {
				for ( x = -5; x < -1; x++ ) {
					if ( Math.random() > 0.5 ) continue;
					character = new CharacterData( ++id );
					character.coord.x = x;
					character.coord.y = y;
					this._battle.world.elements.addChild( character );
				}
			}
*/
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
		private function updateTick(event:Event=null):void {
			var newTick:uint = this._time.currentTime / TICK_TIME;
			if ( newTick == this._currentTick ) return;
			var newTurn:uint = newTick / 4;
			if ( newTurn == this._battle.numTurns ) {
				this._time.speed = 0;
			}
			if ( newTurn - this._currentTurn != 0 ) {
				this.syncElements();
			}
			this._currentTick = newTick;
			// TODO: update model
			super.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this._currentTick, this.totalTicks ) );
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
			this._time.currentTime = 0;
			this._time.speed = 1;
			this.$call( 'enterBattle', this._battle.world.field );
			this.syncElements();
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
				this._timer.delay = TICK_TIME / this._time.speed / 8;
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