////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.controllers {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.controllers.BaseController;
	import by.blooddy.core.database.DataBase;
	import by.blooddy.core.net.ProxySharedObject;
	import by.blooddy.core.utils.time.RelativeTime;
	
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	
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
			this._battleController =		new BattleController		( this, this._relativeTime, container );
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
		private const _relativeTime:RelativeTime = new RelativeTime( 0 );

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function call(commandName:String, ...parameters):* {
			parameters.unshift( commandName );
			return this._battleLogicalController.call.apply( null, parameters );
		}

		public override function dispatchCommand(command:Command):void {
			throw new IllegalOperationError();
		}

		public override function addCommandListener(commandName:String, listener:Function, priority:int=0, useWeakReference:Boolean=false):void {
			this._battleLogicalController.addCommandListener( commandName, listener, priority, useWeakReference );
		}

		public override function removeCommandListener(commandName:String, listener:Function):void {
			this._battleLogicalController.removeCommandListener( commandName, listener );
		}

		public override function hasCommandListener(commandName:String):Boolean {
			return this._battleLogicalController.hasCommandListener( commandName );
		}

		public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			if ( type.indexOf( 'command_' ) == 0 )	this._battleLogicalController.addEventListener( type, listener, useCapture, priority, useWeakReference );
			else									super.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}

		public override function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			if ( type.indexOf( 'command_' ) == 0 )	this._battleLogicalController.removeEventListener( type, listener, useCapture );
			else									super.removeEventListener( type, listener, useCapture );
		}

		public override function hasEventListener(type:String):Boolean {
			if ( type.indexOf( 'command_' ) == 0 )	return this._battleLogicalController.hasEventListener( type );
			else									return super.hasEventListener( type );
		}

		public override function willTrigger(type:String):Boolean {
			if ( type.indexOf( 'command_' ) == 0 )	return this._battleLogicalController.willTrigger( type );
			else									return super.willTrigger( type );
		}

	}

}