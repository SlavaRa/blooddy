////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.logging.commands {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.logging.Log;
	import by.blooddy.core.net.NetCommand;
	import by.blooddy.core.utils.DateUtils;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					iconnection, connection
	 */
	public class CommandLog extends Log {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructior
		 */
		public function CommandLog(command:Command) {
			super();
			this._command = command;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _command:Command;

		public function get command():Command {
			return this._command;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toHTMLString():String {
			var result:String = this.toString();
			if ( this._command is NetCommand ) {
				switch ( ( this._command as NetCommand ).io ) {
					case NetCommand.INPUT:	result = '<font color="#6666FF">' + result + '</font>';	break;
					case NetCommand.OUTPUT:	result = '<font color="#66FF66">' + result + '</font>';	break;
				}
			}
			return result;
		}

		public override function toString():String {
			var d:Date = new Date( super.time );
			return DateUtils.timeToString( super.time, true, ":", true, true ) + "@ " + this._command;
		}
		
	}

}