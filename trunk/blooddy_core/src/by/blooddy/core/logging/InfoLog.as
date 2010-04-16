////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.logging {

	import by.blooddy.core.utils.DateUtils;

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
		
		public function InfoLog(text:String, type:uint=0) {
			super( text );
			this._type = type;
		}

		private var _type:uint;

		public function get type():uint {
			return this._type;
		}
		
		public override function toHTMLString():String {
			var result:String = this.toString();
			switch ( this._type ) {
				case INFO:	result = '<font color="#AAAAFF">' + result + '</font>';	break;
				case WARN:	result = '<font color="#FFFF00">' + result + '</font>';	break;
				case ERROR:	result = '<font color="#FF9900">' + result + '</font>';	break;
				case FATAL:	result = '<font color="#FF0000">' + result + '</font>';	break;
				case DEBUG:	result = '<font color="#CCCCCC">' + result + '</font>';	break;
			}
			return result;
		}

		/**
		 * @private
		 */
		public override function toString():String {
			var d:Date = new Date( super.time );
			return DateUtils.timeToString( super.time, true, ':', true, true ) + '@ ' + super.text;
		}

	}

}