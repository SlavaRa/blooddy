////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.connection.filters {
	
	import by.blooddy.core.net.NetCommand;
	import by.blooddy.core.utils.crypto.UIDUtils;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.Dictionary;
	import flash.utils.ByteArray;
	
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
		 */
		private const _hash:String = UIDUtils.createUID();
		
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
			return this._hash;
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

			} catch ( e:Error ) {

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
//  Helper class: EventContainer
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