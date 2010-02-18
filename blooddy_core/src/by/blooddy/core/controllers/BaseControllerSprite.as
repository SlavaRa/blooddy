////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.controllers {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.commands.CommandDispatcher;
	import by.blooddy.core.data.DataBase;
	import by.blooddy.core.display.resource.MainResourceSprite;
	import by.blooddy.core.errors.getErrorMessage;
	import by.blooddy.core.net.ProxySharedObject;
	
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					13.09.2009 22:50:15
	 */
	public class BaseControllerSprite extends MainResourceSprite implements IBaseController {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BaseControllerSprite(dataBase:DataBase!, sharedObject:ProxySharedObject!) {
			super();
			if ( !dataBase )		throw new ArgumentError( getErrorMessage( 2007, this, 'BaseController', 'dataBase' ),		2007 );
			if ( !sharedObject )	throw new ArgumentError( getErrorMessage( 2007, this, 'BaseController', 'sharedObject' ),	2007 );
			this._dispatcher = new CommandDispatcher( this );
			this._dataBase = dataBase;
			this._sharedObject = sharedObject;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _dispatcher:CommandDispatcher;

		//--------------------------------------------------------------------------
		//
		//  Implements properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  container
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get container():DisplayObjectContainer {
			return this;
		}

		//----------------------------------
		//  baseController
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get baseController():IBaseController {
			return this;
		}

		//----------------------------------
		//  database
		//----------------------------------

		/**
		 * @private
		 */
		private var _dataBase:DataBase;

		/**
		 * @inheritDoc
		 */
		public function get dataBase():DataBase {
			return this._dataBase;
		}
		
		//----------------------------------
		//  sharedObject
		//----------------------------------

		/**
		 * @private
		 */
		private var _sharedObject:ProxySharedObject;

		/**
		 * @inheritDoc
		 */
		public function get sharedObject():Object {
			return this._sharedObject;
		}		

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function dispatchCommand(command:Command):void {
			this._dispatcher.dispatchCommand( command );
		}

		/**
		 * @inheritDoc
		 */
		public function addCommandListener(commandName:String, listener:Function, priority:int=0, useWeakReference:Boolean=false):void {
			this._dispatcher.addCommandListener( commandName, listener, priority, useWeakReference );
		}

		/**
		 * @inheritDoc
		 */
		public function removeCommandListener(commandName:String, listener:Function):void {
			this._dispatcher.removeCommandListener( commandName, listener );
		}

		/**
		 * @inheritDoc
		 */
		public function hasCommandListener(commandName:String):Boolean {
			return this._dispatcher.hasCommandListener( commandName );
		}

		/**
		 * @inheritDoc
		 */
		public function call(commandName:String, ...arguments):* {
			throw new IllegalOperationError( getErrorMessage( 2071, this, 'call' ), 2071 );
		}

	}

}