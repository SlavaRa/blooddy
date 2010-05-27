////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.social {
	
	import by.blooddy.core.commands.Command;
	import by.blooddy.core.net.AbstractRemoter;
	import by.blooddy.social.events.SocialAPIEvent;
	
	import flash.errors.IllegalOperationError;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.05.2010 18:12:54
	 */
	public class SocialAPI extends AbstractRemoter {
		
		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		protected namespace social;

		use namespace social;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function SocialAPI() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected override function $callOutputCommand(command:Command):* {
			return command.call( this, social );
		}

		//--------------------------------------------------------------------------
		//
		//  Social methods
		//
		//--------------------------------------------------------------------------

		social function requestUsers(...usersID):void {
			throw new IllegalOperationError();
		}

		social function requestIsAppUser(userID:String):void {
			throw new IllegalOperationError();
		}

		social function requestGetAppFriends():void {
			throw new IllegalOperationError();
		}

		social function requestGetUserBalance(userID:String):void {
			throw new IllegalOperationError();
		}

		social function showInstallBox():void {
			super.dispatchEvent( new SocialAPIEvent( SocialAPIEvent.SHOW_INSTALL_BOX ) );
		}

		social function showSettingsBox(settings:uint = 0):void {
			super.dispatchEvent( new SocialAPIEvent( SocialAPIEvent.SHOW_SETTINGS_BOX ) );
		}

		social function showInviteBox(excludeIDs:Array=null):void {
			super.dispatchEvent( new SocialAPIEvent( SocialAPIEvent.SHOW_INVITE_BOX ) );
		}

		social function showPaymentBox(votes:uint=0):void {
			super.dispatchEvent( new SocialAPIEvent( SocialAPIEvent.SHOW_PAYMENT_BOX ) );
		}

	}

}