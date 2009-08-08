////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events.net {

	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.Command;
	
	import flash.events.Event;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					command
	 */
	public class CommandEvent extends Event {

		public static const COMMAND:String = 'command';

		public function CommandEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, command:Command=null) {
			super( type, bubbles, cancelable );
			this.command = command;
		}

		public var command:Command;

		public function call(client:Object, ns:Namespace=null):* {
			return this.command.call( client, ns );
		}

		public override function clone():Event {
			return new CommandEvent( super.type, super.bubbles, super.cancelable, this.command );
		}

		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable', 'command' );
		}

	}

}