////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.utils.ClassUtils;

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
		public static const INPUT:String =		'input';

		/**
		 * Направление комманды. "Изходящая".
		 * 
		 * @see						#io
		 */
		public static const OUTPUT:String =		'output';

		/**
		 * Направление комманды. "Изходящая".
		 * 
		 * @see						#io
		 */
		public static const UNKNOWN:String =	'';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 * @param	name		Имя комманды.
		 */
		public function NetCommand(name:String, io:String=UNKNOWN, arguments:Array=null) {
			super( name, arguments );
			this.io = io;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  system
		//----------------------------------

		public var system:Boolean = false;

		//----------------------------------
		//  io
		//----------------------------------

		public var io:String;

		//----------------------------------
		//  num
		//----------------------------------

		public var num:uint;

		//----------------------------------
		//  status
		//----------------------------------
		
		public var status:Boolean;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function clone():Command {
			var result:NetCommand = new NetCommand( super.name, this._io, this );
			result.system = this.system;
			result.num = this.num;
			return result;
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return '[' + ClassUtils.getClassName( this ) + ' io="' + this._io + '" name="' + super.name + '" arguments=(' + super.argumentsToString() + ')]';
		}

	}

}