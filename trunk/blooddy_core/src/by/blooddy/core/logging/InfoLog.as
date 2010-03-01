////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.logging {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class InfoLog extends TextLog {

		public static const INFO:uint = 0;

		public static const WARN:uint = 1;

		public static const ERROR:uint = 2;

		public static const FATAL:uint = 3;

		public static const DEBUG:uint = uint.MAX_VALUE;
		
		private static function getClassByType(type:uint):String {
			switch (type) {
				case INFO: 			return 'info';
				case WARN: 			return 'warn';
				case ERROR: 		return 'error';
				case FATAL: 		return 'fatal';
				case DEBUG: 		return 'debug';
			}
			
			return null;
		}

		public function InfoLog(text:String, type:uint=0) {
			super( text );
			this._type = type;
		}

		private var _type:uint;

		public function get type():uint {
			return this._type;
		}
		
		public override function toString():String {
			return '<span class="log_' + getClassByType(this._type) +'">' + super.text + '</span>';
		}
	}
}