////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import by.blooddy.core.utils.ClassUtils;

	import flash.utils.ByteArray;

	/**
	 * Класс для хранения комманды в виде обычного массива.
	 * Коммнада по сути это набор упорядоченных аргументов.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					command
	 */
	public dynamic class Command extends Array {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * @param	name		Имя комманды.
		 */
		public function Command(name:String) {
			super();
			this._name = name;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  name
		//----------------------------------

		/**
		 * @private
		 */
		private var _name:String;

		/**
		 * Имя комманды.
		 */
		public function get name():String {
			return this._name;
		}

		/**
		 * @private
		 */
		public function set name(value:String):void {
			this._name = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Клонирует команду.
		 * 
		 * @return			Возвращает копию данной команды.
		 */
		public function clone():Command {
			var command:Command = new Command(this.name);
			command.push.apply( command, this );
			return command;
		}

		/**
		 * @private
		 */
		public function toString():String {
			return '['+ClassUtils.getClassName(this)+' name="'+this.name+'" arguments=('+this.argumentsToString()+')]';
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Формирует из агрументов строку.
		 * 
		 * @return			String
		 */
		protected final function argumentsToString():String {
			return arrayToString( this );
		}

		/**
		 * @private
		 */
		private static function arrayToString(arr:Array):String {
			var result:Array = new Array();
			var length:uint = arr.length;
			for (var i:uint =0; i<length; i++) {
				if ( arr[i] is ByteArray ) result.push( '[' + ClassUtils.getClassName( arr[i] ) + ' length="' + ( arr[i] as ByteArray ).length + '"]' );
				else if ( arr[i] is Array && !( arr[i] is Command ) ) result.push( '(' + arrayToString( arr[i] as Array ) + ')' );
				else if ( arr[i] is String ) result.push( '"' + arr[i] + '"' );
				else result.push( arr[i] );
			}
			return result.join(',');
		}

	}

}