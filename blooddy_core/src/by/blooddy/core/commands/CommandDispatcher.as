////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.commands {

	import by.blooddy.core.events.commands.CommandEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.08.2009 16:48:52
	 */
	public class CommandDispatcher extends EventDispatcher implements ICommandDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const PREFIX:String = 'command_';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function CommandDispatcher() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _listeners:Dictionary = new Dictionary( true );

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function dispatchCommand(command:Command):void {
			super.dispatchEvent( new CommandEvent( PREFIX + command.name, false, false, command ) );
		}

		/**
		 * @inheritDoc
		 */
		public function addCommandListener(commandName:String, listener:Function, priority:int=0, useWeakReference:Boolean=false):void {
			var commandListener:CommandEventListener = this._listeners[ listener ];
			if ( !commandListener ) this._listeners[ listener ] = commandListener =  new CommandEventListener( listener );
			super.addEventListener( PREFIX + commandName, commandListener.handler, false, priority, useWeakReference );
		}

		/**
		 * @inheritDoc
		 */
		public function removeCommandListener(commandName:String, listener:Function):void {
			var commandListener:CommandEventListener = this._listeners[ listener ];
			if ( commandListener ) {
				super.removeEventListener( PREFIX + commandName, commandListener.handler );
			}
		}

		/**
		 * @inheritDoc
		 */
		public function hasCommandListener(commandName:String):Boolean {
			return super.hasEventListener( PREFIX + commandName );
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.events.commands.CommandEvent;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: CommandEventListener
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class CommandEventListener {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor.
	 */
	public function CommandEventListener(listener:Function) {
		super();
		this.listener = listener;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	public var listener:Function;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	public function handler(event:CommandEvent):void {
		this.listener.apply( null, event.command );
	}

}