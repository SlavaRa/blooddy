package by.blooddy.core.net {

	import flash.net.Responder;

	public class Responder extends flash.net.Responder {

		public function Responder(result:Function, status:Function=null) {

			super(result, status);

			this._result = result;
			this._status = status;
		}

		private var _result:Function;

		internal function get result():Function {
			return this._result;
		}

		private var _status:Function;

		internal function get status():Function {
			return this._status;
		}

	}

}