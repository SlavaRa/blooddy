////////////////////////////////////////////////////////////////////////////////
//
//  © 2004—2008 TimeZero LLC.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.utils.ClassUtils;

	import by.blooddy.core.utils.Command;
	import flash.utils.ByteArray;
	import by.blooddy.core.utils.ByteArrayUtils;

	/**
	 * Сетевая комманда.
	 * Имеет направление.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					netcommand, net, command
	 */
	public dynamic class NetCommand extends Command {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * Направление комманды. "Входящая".
		 * 
		 * @see						#io
		 */
		public static const INPUT:String = "input";

		/**
		 * Направление комманды. "Изходящая".
		 * 
		 * @see						#io
		 */
		public static const OUTPUT:String = "output";

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * @param	name		Имя комманды.
		 */
		public function NetCommand(name:String, io:String=OUTPUT) {
			super(name);
			this.setIO( io );
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  system
		//----------------------------------

		/**
		 * @private
		 */
		private var _system:Boolean = false;

		public function get system():Boolean {
			return this._system;
		}

		/**
		 * @private
		 */
		public function set system(value:Boolean):void {
			this._system = value;
		}

		//----------------------------------
		//  io
		//----------------------------------

		/**
		 * @private
		 */
		private var _io:String = OUTPUT;

		public function get io():String {
			return this._io;
		}

		/**
		 * @private
		 */
		public function set io(value:String):void {
			this.setIO( value );
		}

		/**
		 * @private
		 */
		private function setIO(value:String):void {
			value = value.toLowerCase()
			switch (value) {
				case INPUT:
				case OUTPUT:
					break;
				default:
					value = INPUT;
					break;
			}
			this._io = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function clone():Command {
			var command:NetCommand = new NetCommand( super.name, this._io );
			command.push.apply( command, this );
			return command;
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return '['+ClassUtils.getClassName(this)+' io="'+this._io+'" name="'+super.name+'" arguments=('+super.argumentsToString()+')]';
		}

	}

}