////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 q1
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.social.events {
	
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.events.Event;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.05.2010 16:35:32
	 */
	public class SocialAPIEvent extends Event {
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const SHOW_INSTALL_BOX:String =			'showInstallBox';

		public static const SHOW_SETTINGS_BOX:String =			'showSettingsBox';

		public static const SHOW_INVITE_BOX:String =			'showInviteBox';

		public static const SHOW_PAYMENT_BOX:String =			'showPaymentBox';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function SocialAPIEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super( type, bubbles, cancelable );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public override function clone():Event {
			return new SocialAPIEvent( super.type, super.bubbles, super.cancelable );
		}
		
		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable' );
		}
		
	}
	
}