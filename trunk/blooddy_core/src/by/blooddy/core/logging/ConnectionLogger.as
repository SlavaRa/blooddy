////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.logging {

	import by.blooddy.core.net.NetCommand;

	public class ConnectionLogger extends Logger {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function ConnectionLogger(maxLength:uint=100, maxTime:uint=5*60*1E3) {
			super( maxLength, maxTime );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function addCommand(command:NetCommand):void {
			super.addLog( new CommandLog( command ) );
		}

	}

}