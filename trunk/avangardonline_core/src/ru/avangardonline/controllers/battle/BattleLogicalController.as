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
	import ru.avangardonline.database.battle.world.BattleWorldElementData;
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
			this._time.speed = 0;
			this._time.addEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.handler_timeRelativityChange );

			this._data = new BattleData( time );

			this._data.world.field.width = 11;
			this._data.world.field.height = 5;

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
					this._data.world.elements.addChild( character );
				}
			}

			controller.dataBase.addChild( this._data );

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
			trace( this._time.currentTime );
			var newTick:uint = this._time.currentTime / TICK_TIME;
			if ( newTick == this._currentTick ) return;
			if ( Math.abs( newTick - this._currentTick ) != 1 ) {
				// syncModel
			}
			// TODO: update model
			this._currentTick = newTick;
			super.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this._currentTick, this._totalTicks ) );
		}

		/**
		 * @private
		 */
		private function syncCharacters():void {
			var elements:Vector.<BattleWorldElementData> = this._data.world.elements.getElements();
			var characters:Vector.<CharacterData> = new Vector.<CharacterData>();
			for each ( var element:BattleWorldElementData in elements ) {
				if ( element is CharacterData ) {
					characters.push( element as CharacterData );
				}
				//this.$call( 'forCharacter', character.id, new Command( 'moveTo', [ -5 + Math.random() * 11, Math.random() * 5, 5E3 + Math.random() * 5E3 ] ) );
			}
			this.$call( 'syncCharacters', characters );
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
			this.$call( 'enterBattle', this._data.world.field );

			this.syncCharacters();

			this._time.currentTime = 0;
			this._time.speed = 1;

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