package by.blooddy.core.logging {

	import by.blooddy.core.net.NetCommand;
	import by.blooddy.core.utils.Command;
	import by.blooddy.core.utils.DateUtils;

	public class CommandLog extends Log {

		public function CommandLog(command:Command) {
			super();
			this._command = command;
		}

		private var _command:Command;

		public function get command():Command {
			return this._command;
		}

		public override function toString():String {
			var d:Date = new Date( super.time );
			var resut:String = DateUtils.timeToString( super.time, true, ":", true, true ) + "@ " + this._command;
			if ( this._command is NetCommand ) {
				resut = '<span class="' + ( this._command as NetCommand ).io + '">' + resut + '</span>';
			}
			return resut;
			//return this.formatToString("time", "command");
		}

	}

}