////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.connection.filters {
	
	import by.blooddy.core.net.NetCommand;
	import by.blooddy.crypto.MD5;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 18, 2010 11:38:18 AM
	 */
	public class TextSocketFilter implements ISocketFilter {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _HASH:String = MD5.hash( getQualifiedClassName( prototype.contructor ) );
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function TextSocketFilter() {
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * хэш контекстов.
		 * на случай, если одним сериализатором пользуются несколько сокетов.
		 */
		private const _contexts:Dictionary = new Dictionary( true );

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public function getHash():String {
			return _HASH;
		}

		public function isSystem(netCommand:NetCommand):Boolean {
			return false;
		}
		
		public function readCommand(input:IDataInput, io:String='input'):NetCommand {

			var context:Context = this._contexts[ input ] as Context;
			if ( !context ) this._contexts[ input ] = context = new Context();

			var c:uint;
			var data:String;
			var bytes:ByteArray = context.buffer;

			try {

				while ( input.bytesAvailable > 0 ) {
					c = input.readUnsignedByte();
					if ( c == 0 ) {
						bytes.position = 0;
						data = bytes.readUTFBytes( bytes.length );
						bytes.length = 0;
						return this.getCommandFromString( data, io );
					}
					bytes.writeByte( c );
				}

			} catch ( e:* ) {

				bytes.length = 0;
				throw e;

			}

			return null;

		}

		public function writeCommand(output:IDataOutput, command:NetCommand):void {

			output.writeUTFBytes( this.getStringFromCommand( command ) );
			output.writeByte( 0 );
			
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function getCommandFromString(data:String, io:String):NetCommand {
			throw new IllegalOperationError();
		}

		protected function getStringFromCommand(command:NetCommand):String {
			throw new IllegalOperationError();
		}
		
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.utils.ByteArray;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: Context
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class Context {
	
	public function Context() {
		super();
	}

	public const buffer:ByteArray = new ByteArray();

}