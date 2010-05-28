////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.connection {
	
	import by.blooddy.core.commands.Command;
	import by.blooddy.core.net.AbstractRemoter;
	
	import flash.errors.IOError;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]	
	
	[Event( name="status", type="flash.events.StatusEvent" )]	
	
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
			this._connection.addEventListener( StatusEvent.STATUS,					super.dispatchEvent, false, 0, true );
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

		public function allowDomain(...parameters):void {
			this._connection.allowDomain.apply( null, parameters );
		}

		public function allowInsecureDomain(...parameters):void {
			this._connection.allowInsecureDomain.apply( null, parameters );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function $callOutputCommand(command:Command):* {
			if ( !this._targetName ) throw new IOError();
			command.unshift( this._targetName, command.name );
			this._connection.send.apply( this, command );
		}

		//--------------------------------------------------------------------------
		//
		//  flash_proxy methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$private function $invokeCallInputCommand(command:Command):* {
			return super.$invokeCallInputCommand( command );
		}

	}
	
}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.commands.Command;
import by.blooddy.core.net.connection.LocalConnection;

import flash.utils.Proxy;
import flash.utils.flash_proxy;

use namespace flash_proxy;

internal namespace $private;

/**
 * @private
 */
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
				return app._target.$private::$invokeCallInputCommand( new Command( n, rest ) );
			};
		}
		return result;
	}

	/**
	 * @private
	 */
	flash_proxy override function callProperty(name:*, ...parameters):* {
		this._target.$private::$invokeCallInputCommand( new Command( name, parameters ) );
	}

}