////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.connection {
	
	import by.blooddy.core.commands.Command;
	import by.blooddy.core.net.AbstractRemoter;
	
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * @inheritDoc
	 */
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]		
	
	/**
	 * @inheritDoc
	 */
	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]	
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.05.2010 20:49:37
	 */
	public class LocalConnection extends AbstractRemoter implements IConnection {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function LocalConnection(targetName:String=null) {
			super();
			this._targetName = targetName;
			this._connection.client = new Client( this );
			this._connection.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	super.dispatchEvent, false, 0, true );
			this._connection.addEventListener( StatusEvent.STATUS,					this.handler_status, false, 0, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _connection:flash.net.LocalConnection = new flash.net.LocalConnection();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  connected
		//----------------------------------

		/**
		 * @private
		 */
		private var _connected:Boolean = false;

		/**
		 * @inheritDoc
		 */
		public function get connected():Boolean {
			return this._connected;
		}

		//----------------------------------
		//  name
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _name:String;
		
		public function get name():String {
			return this._name;
		}
		
		//----------------------------------
		//  targetName
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _targetName:String;

		public function get targetName():String {
			return this._targetName;
		}

		/**
		 * @private
		 */
		public function set targetName(value:String):void {
			if ( this._targetName == value ) return;
			this._targetName = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function open(name:String):void {
			if ( this._connected ) throw new ArgumentError();
			this._connection.connect( name );
			this._name = name;
			this._connected = true;
		}

		public function close():void {
			if ( this._connected ) throw new ArgumentError();
			this._connection.close();
			this._name = null;
			this._connected = false;
		}

		public override function call(commandName:String, ...parameters):* {
			if ( !this._targetName ) throw new IOError();
			parameters.unshift( this._targetName, commandName );
			this._connection.send.apply( this, parameters );
		}

		//--------------------------------------------------------------------------
		//
		//  flash_proxy methods
		//
		//--------------------------------------------------------------------------

		$private function $callInputCommand(command:Command):void {
			super.$callInputCommand( command );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_status(event:StatusEvent):void {
			if ( event.level == 'error' ) {
				super.dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, event.code ) );
			}
		}
		
	}
	
}

import by.blooddy.core.commands.Command;
import by.blooddy.core.net.connection.LocalConnection;

import flash.utils.Proxy;
import flash.utils.flash_proxy;

use namespace flash_proxy;

internal namespace $private;

internal final dynamic class Client extends Proxy {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function Client(target:LocalConnection) {
		super();
		this._target = target;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private var _target:LocalConnection;

	/**
	 * @private
	 */
	private var _hash:Object = new Object();
	
	//--------------------------------------------------------------------------
	//
	//  Overriden flash_proxy methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	flash_proxy override function hasProperty(name:*):Boolean {
		return true;
	}
	
	/**
	 * @private
	 */
	flash_proxy override function getProperty(name:*):* {
		var n:String = name.toString();
		var result:* = this._hash[ n ];
		if ( result == null ) {
			var app:Client = this;
			this._hash[ n ] = result = function(...rest):* {
				return app._target.$private::$callInputCommand( new Command( n, rest ) );
			};
		}
		return result;
	}

	/**
	 * @private
	 */
	flash_proxy override function callProperty(name:*, ...parameters):* {
		this._target.$private::$callInputCommand( new Command( name, parameters ) );
	}

}