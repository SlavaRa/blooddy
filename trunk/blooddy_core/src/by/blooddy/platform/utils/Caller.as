package by.blooddy.platform.utils {

	public class Caller {

		public function Caller(listener:Function, args:Array=null) {
			super();
			this.listener = listener;
			this.args = args;
		}

		public var listener:Function;

		public var args:Array;

		public function call():* {
			return this.listener.apply(null, this.args);
		}

	}

}