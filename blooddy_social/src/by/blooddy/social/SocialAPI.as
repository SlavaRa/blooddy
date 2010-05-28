////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.social {
	
	import by.blooddy.core.commands.Command;
	import by.blooddy.core.net.AbstractRemoter;
	
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
			super.$callInputCommand( new Command( 'showInstallBox' ) );
		}

		social function showSettingsBox(settings:uint=0):void {
			super.$callInputCommand( new Command( 'showSettingsBox', [ settings ] ) );
		}

		social function showInviteBox(excludeIDs:Array=null):void {
			super.$callInputCommand( new Command( 'showInviteBox', [ excludeIDs ] ) );
		}

		social function showPaymentBox(votes:uint=0):void {
			super.$callInputCommand( new Command( 'showPaymentBox', [ votes ] ) );
		}

	}

}