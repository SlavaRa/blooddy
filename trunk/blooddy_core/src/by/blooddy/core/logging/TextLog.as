package by.blooddy.core.logging {

	public class TextLog extends Log {

		public function TextLog(text:String) {
			super();
			this._text = text;
		}

		private var _text:String;

		public function get text():String {
			return this._text;
		}

		public override function toString():String {
			return this._text;
		}

	}

}