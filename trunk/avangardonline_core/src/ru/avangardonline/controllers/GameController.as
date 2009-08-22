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
	import by.blooddy.core.net.ILoadable;
	import by.blooddy.core.managers.resource.ResourceManager;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import ru.avangardonline.serializers.txt.database.battle.BattleDataSerializer;
	import ru.avangardonline.database.battle.BattleData;
	import by.blooddy.core.utils.DataBaseUtils;
	
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

			this._relativeTime.speed = 0;

			this._battleLogicalController =	new BattleLogicalController	( this );
			this._battleController =		new BattleController		( this, this._relativeTime, container );

			this.updateBattle();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _loader:ILoadable;

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

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updateBattle(event:Event=null):void {
			if ( this._loader ) {
				this._loader.removeEventListener( Event.COMPLETE,						this.updateBattle );
				this._loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.updateBattle );
				this._loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.updateBattle );
			}
			this._battleLogicalController.battle = null;
			this._loader = ResourceManager.manager.loadResourceBundle( 'battle.txt' );
			if ( this._loader.loaded ) {
				var txt:String = ResourceManager.manager.getResource( 'battle.txt', '' );
				if ( !txt ) {
					this.error( 'Произошла ошибка загрзуки боя.' );
				} else {
					var battle:BattleData = new BattleData( this._relativeTime )
//					try {
						BattleDataSerializer.deserialize( txt, battle );
						trace( DataBaseUtils.toTreeString( battle ) );
						this._battleLogicalController.battle = battle;
//					} catch ( e:Error ) {
//						this.error( 'Произошла ошибка обработки боя:\n' + ( e.getStackTrace() || e.toString() ) );
//					}
				}
			} else {
				this._loader.addEventListener( Event.COMPLETE,						this.updateBattle );
				this._loader.addEventListener( IOErrorEvent.IO_ERROR,				this.updateBattle );
				this._loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.updateBattle );
			}
		}

		/**
		 * @private
		 */
		private function error(txt:String):void {
			trace( txt );
		}

	}

}