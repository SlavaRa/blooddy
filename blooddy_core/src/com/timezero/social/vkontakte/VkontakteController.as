////////////////////////////////////////////////////////////////////////////////
//
//  © 2004—2008 TimeZero LLC.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.social.vkontakte {

	import by.blooddy.core.controllers.IBaseController;
	import by.blooddy.core.events.CommandEvent;
	import by.blooddy.core.net.NetCommand;
	import by.blooddy.core.utils.XMLUtils;
	import by.blooddy.core.utils.crypto.MD5;
	import by.blooddy.core.utils.time.setTimeout;
	import com.timezero.social.controller.AbstractSocialController;
	import com.timezero.social.controller.ISocialController;
	import com.timezero.social.database.SocialUserData;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class VkontakteController extends AbstractSocialController implements ISocialController {
		
		public static var API_URL:String = 'http://api.vkontakte.ru/api.php';
		
		public static var SOCIAL_URL:String = 'http://vkontakte.ru/';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function VkontakteController(controller:IBaseController, appID:String, viewerID:String, secretKey:String=null) {
			super( controller );

			this._appID = appID;
			this._viewerID = viewerID;
			this._secretKey = secretKey;

			this._methods[ this.responseUsers ] = 'getProfiles';
			this._methods[ this.responseIsAppUser ] = 'isAppUser';
			this._methods[ this.responseGetAppFriends ] = 'getAppFriends';
			this._methods[ this.responseGetUserBalance ] = 'getUserBalance';

			super.baseController.addEventListener( 'command_vkontakteSigResponse', this.command_vkontakteSigResponse );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private const _requestHash:Object = new Object();

		/**
		 * @private
		 */
		private const _loadersHash:Dictionary = new Dictionary();

		/**
		 * @private
		 */
		private const _methods:Dictionary = new Dictionary();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _appID:String;

		public function get appID():String {
			return this._appID;
		}

		/**
		 * @private
		 */
		private var _viewerID:String;

		public function get viewerID():String {
			return this._viewerID;
		}
		
		public function get referer():String {
			return SOCIAL_URL + 'app' + this._appID + '_' + this._viewerID; 
		}

		/**
		 * @private
		 */
		private var _secretKey:String;

		public function get secretKey():String {
			return this._secretKey;
		}

		//--------------------------------------------------------------------------
		//
		//  Request handlers
		//
		//--------------------------------------------------------------------------

		social function requestUser(...usersID):void {
			var vars:URLVariables = new URLVariables();
			vars.uids = usersID.join( ',' );
			vars.fields = 'uid,first_name,last_name,nickname,sex,bdate,photo,photo_medium,photo_big'; 
			this.requestSig( vars, this.responseUsers );
		}

		social function requestIsAppUser(userID:String):void {
			var vars:URLVariables = new URLVariables();
			vars.uid = userID;
			this.requestSig( vars, this.responseIsAppUser );
		}
		
		social function requestGetAppFriends():void {
			var vars:URLVariables = new URLVariables();
			this.requestSig( vars, this.responseGetAppFriends );
		}
		
		social function requestGetUserBalance(userID:String):void {
			var vars:URLVariables = new URLVariables();
			vars.uid = userID;
			this.requestSig( vars, this.responseGetUserBalance );
		}

		//--------------------------------------------------------------------------
		//
		//  Response methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function responseUsers(xml:XML=null):void {

			var response:NetCommand;

			if ( xml.name().toString() == 'error' ) {

				response = new NetCommand( 'responseUsersError', NetCommand.INPUT );
				response.push( XMLUtils.parseUIntNode( xml.error_code ) );

			} else {

				response = new NetCommand( 'responseUsers', NetCommand.INPUT );
				var list:XMLList = xml.user;
			
				for each ( var user:XML in list ) {
					var data:SocialUserData = new SocialUserData( user.uid.toString() );
					data.firstName =		user.first_name.toString() || null;;
					data.lastName =			user.last_name.toString() || null;;
					data.nickName =			user.nickname.toString() || null;;
					data.sex =				parseInt( user.sex ) - 1;
					data.url = SOCIAL_URL +'id' + data.id;
					var birthday:String =	user.bdate.toString() || null;
					if ( birthday ) {
						var arr:Array =		birthday.split( '.' );
						data.birthday =		new Date( parseInt( arr[ 2 ] ), parseInt( arr[ 1 ] ) - 1, parseInt( arr[ 0 ] ) );
					}
					data.photo =			user.photo.toString() || null;
					if ( data.photo && data.photo.indexOf( 'vkontakte.ru' ) < 0 ) {
						data.photo = SOCIAL_URL + data.photo;
					}
					data.mediumPhoto =		user.photo_medium.toString() || null;
					if ( data.mediumPhoto && data.mediumPhoto.indexOf( 'vkontakte.ru' ) < 0 ) {
						data.mediumPhoto = SOCIAL_URL + data.mediumPhoto;
					}
					data.bigPhoto =			user.photo_big.toString() || null;
					if ( data.bigPhoto && data.bigPhoto.indexOf( 'vkontakte.ru' ) < 0 ) {
						data.bigPhoto = SOCIAL_URL + data.bigPhoto;
					}		
					response.push( data );
				}

			}

			super.$invokeCallInputCommand( response, false );
		}
		
		/**
		 * @private
		 */
		private function responseIsAppUser(xml:XML=null):void {
			
			var response:NetCommand;

			if ( xml.name().toString() == 'error' ) {

				response = new NetCommand( 'responseIsAppUserError', NetCommand.INPUT );
				response.push( XMLUtils.parseUIntNode( xml.error_code ) );

			} else {
				response = new NetCommand( 'responseIsAppUser', NetCommand.INPUT );
				response.push( parseBoolean( xml.toString() ) );
			}
			
			super.$invokeCallInputCommand( response, false );
		}
		
		/**
		 * @private
		 */
		private function responseGetAppFriends(xml:XML=null):void {
			
			var response:NetCommand;

			if ( xml.name().toString() == 'error' ) {

				response = new NetCommand( 'responseGetAppFriendsError', NetCommand.INPUT );
				response.push( XMLUtils.parseUIntNode( xml.error_code ) );

			} else {
				response = new NetCommand( 'responseGetAppFriends', NetCommand.INPUT );
				var list:XMLList = xml.uid;
			
				for each ( var uid:XML in list ) {
					response.push( uid.toString() );
				}
			}
			
			super.$invokeCallInputCommand( response, false );
		}
		
		/**
		 * @private
		 */
		private function responseGetUserBalance(xml:XML=null):void {
			var response:NetCommand;

			if ( xml.name().toString() == 'error' ) {

				response = new NetCommand( 'responseGetUserBalanceError', NetCommand.INPUT );
				response.push( XMLUtils.parseUIntNode( xml.error_code ) );

			} else {
				response = new NetCommand( 'responseGetUserBalance', NetCommand.INPUT );
				response.push(XMLUtils.parseUIntNode(xml.balance));
			}
			
			super.$invokeCallInputCommand( response, false );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function requestSig(vars:URLVariables, handler:Function):void {

			// формируем базовые переменные
			vars.api_id = this._appID;
			vars.v = '2.0';
			vars.method = this._methods[ handler ];
			//vars.test_mode="1";

			// получаем долбанную строку
			var arr:Array = new Array();
			for ( var key:String in vars ) {
				arr.push( key );
			}
			arr.sort();

			var data:String = '';
			const l:uint = arr.length;
			for ( var i:uint = 0; i<l; i++ ) {
				data += arr[ i ] + '=' + vars[ arr[i] ];
			}

			if ( this._requestHash[ data ] ) return; // такой запрос уже в процессе

			var request:Request = new Request();
			request.handler = handler;
			request.vars = vars;

			this._requestHash[ data ] = request;

			if ( this._secretKey ) {
				this.requestMethod( data, MD5.hash( this._viewerID + data + this._secretKey ) );
			} else {
				super.baseController.call( 'vkontakteSigRequest', data );
			}
		}

		/**
		 * @private
		 */
		private function requestMethod(data:String, sig:String):void {
			var request:Request = this._requestHash[ data ];
			request.vars.sig = sig;
			var loader:URLLoader = new URLLoader( new URLRequest( API_URL + '?' + request.vars.toString() ) );
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener( Event.COMPLETE, this.handler_complete );
			loader.addEventListener( IOErrorEvent.IO_ERROR, this.handler_complete );
			loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, this.handler_complete );
			this._loadersHash[ loader ] = data;
		}

		//--------------------------------------------------------------------------
		//
		//  Command handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function command_vkontakteSigResponse(event:CommandEvent):void {
			this.requestMethod( event.command[ 0 ], event.command[ 1 ] );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener( Event.COMPLETE, this.handler_complete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR, this.handler_complete );
			loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, this.handler_complete );
			var data:String = this._loadersHash[ loader ];
			var request:Request = this._requestHash[ data ];
			delete this._requestHash[ data ];
			delete this._loadersHash[ loader ];

			var xml:XML;
			if ( !( event is ErrorEvent ) ) {
				try {
					xml = new XML( loader.data );
				} catch ( e:Error ) {
				}
			}
			
			if ( !xml || ( xml.name().toString() == 'error' && XMLUtils.parseUIntNode( xml.error_code ) == 6 ) ) { // ошибка таймаута запросим попозже
				setTimeout( this.requestSig, 3E3, request.vars, request.handler );
			} else {
				request.handler( xml );
			}
		}

	}

}

import flash.net.URLRequest;
import flash.net.URLLoader;
import flash.net.URLVariables;

internal final class Request {

	public function Request() {
		super();
	}

	public var vars:URLVariables;

	public var loader:URLLoader;

	public var handler:Function;

}