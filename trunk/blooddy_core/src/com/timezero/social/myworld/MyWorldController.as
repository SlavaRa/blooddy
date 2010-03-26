////////////////////////////////////////////////////////////////////////////////
//
//  © 2004—2009 TimeZero LLC.
//
////////////////////////////////////////////////////////////////////////////////

package com.timezero.social.myworld {

	import com.adobe.serialization.json.JSONDecoder;
	import com.timezero.platform.controllers.IBaseController;
	import com.timezero.platform.net.NetCommand;
	import com.timezero.platform.utils.crypto.MD5;
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
	import flash.utils.setTimeout;

	/**
	 * @author					etc
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class MyWorldController extends AbstractSocialController implements ISocialController {
		
		public static var API_URL:String = 'http://appsmail.ru/myapi';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function MyWorldController(controller:IBaseController, appID:String, viewerID:String, token:String, secretKey:String=null) {
			super(controller);
			this._appID = appID;
			this._viewerID = viewerID;
			this._token = token;
			this._secretKey = secretKey;

			this._methods[ this.responseUsers ] = 'getProfiles';
			this._methods[ this.responseIsAppUser ] = 'my.IsInstalled';
			this._methods[ this.responseGetAppFriends ] = 'getAppFriends';
//			this._methods[ this.responseGetUserBalance ] = 'getUserBalance';

//			super.baseController.addEventListener( 'command_vkontakteSigResponse', this.command_vkontakteSigResponse );
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
		
		/**
		 * @private
		 */
		private var _referer:String;
		
		public function get referer():String {
			return this._referer;
		}
		
		/**
		 * @private
		 */
		private var _token:String;
		
		public function get token():String {
			return this._token;
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
		
//		social function requestGetUserBalance(userID:String):void {
//			var vars:URLVariables = new URLVariables();
//			vars.uid = userID;
//			this.requestSig( vars, this.responseGetUserBalance );
//		}

		//--------------------------------------------------------------------------
		//
		//  Response methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function responseUsers(data:Object):void {
			var response:NetCommand;
			
			if ('error' in data) {
				response = new NetCommand('responseUsersError', NetCommand.INPUT);
				response.push(data.error.error_code);
			} else {
				response = new NetCommand('responseUsers', NetCommand.INPUT);
				var list:Array = data.response;
				
				for each (var user:Object in list) {
					var s:SocialUserData = new SocialUserData(user.uid);
					s.firstName = user.first_name;
					s.lastName = user.last_name;
					s.nickName = user.nickname;
					s.sex = parseInt(user.sex) - 1;
					s.url = user.url;
					
					if (s.id == this._viewerID) {
						this._referer = s.url + 'app-canvas?appid=' + this._appID;
					}

					if (s.url && s.url.indexOf('\\') >= 0) {
						s.url = s.url.split('\\').join('');
					}

					var birthday:String = user.bdate;
					
					if (birthday) {
						var arr:Array =	birthday.split( '.' );
						data.birthday =	new Date( parseInt( arr[ 2 ] ), parseInt( arr[ 1 ] ) - 1, parseInt( arr[ 0 ] ) );
					}
					
					s.photo = user.photo;
					
					if (s.photo && s.photo.indexOf('\\') >= 0) {
						s.photo = s.photo.split('\\').join('');
					}
					
					
//					if ( data.photo && data.photo.indexOf( 'vkontakte.ru' ) < 0 ) {
//						data.photo = 'http://vkontakte.ru/' + data.photo;
//					}
//					data.mediumPhoto =		user.photo_medium.toString() || null;
//					if ( data.mediumPhoto && data.mediumPhoto.indexOf( 'vkontakte.ru' ) < 0 ) {
//						data.mediumPhoto = 'http://vkontakte.ru/' + data.mediumPhoto;
//					}
//					data.bigPhoto =			user.photo_big.toString() || null;
//					if ( data.bigPhoto && data.bigPhoto.indexOf( 'vkontakte.ru' ) < 0 ) {
//						data.bigPhoto = 'http://vkontakte.ru/' + data.bigPhoto;
//					}		
					response.push( s );
				}
			}
			
			super.$invokeCallInputCommand(response, false);
		}
		
		/**
		 * @private
		 */
		private function responseIsAppUser(data:Object):void {
			var response:NetCommand;
			
			if ('error' in data) {
				response = new NetCommand('responseIsAppUserError', NetCommand.INPUT);
				response.push(data.error.error_code);
			} else {
				response = new NetCommand('responseIsAppUser', NetCommand.INPUT);
				var isAppUser:Boolean = Boolean(data.response.result);
				response.push( isAppUser );
			}			
			
//			if ( xml.name().toString() == 'error' ) {
//
//				response = new NetCommand( 'responseIsAppUserError', NetCommand.INPUT );
//				response.push( XMLUtils.parseUIntNode( xml.error_code ) );
//
//			} else {
//				response = new NetCommand( 'responseIsAppUser', NetCommand.INPUT );
//				response.push( parseBoolean( xml.toString() ) );
//			}
			
			super.$invokeCallInputCommand( response, false );
		}
		
		/**
		 * @private
		 */
		private function responseGetAppFriends(data:Object):void {
			var response:NetCommand;
			
			if ('error' in data) {
				response = new NetCommand('responseGetAppFriendsError', NetCommand.INPUT);
				response.push(data.error.error_code);
			} else {
				response = new NetCommand('responseGetAppFriends', NetCommand.INPUT);
				var list:Array = data.response;
				
				for each (var uid:String in list) {
					response.push(uid);
				}
			}
			
			super.$invokeCallInputCommand(response, false);
		}
		
//		/**
//		 * @private
//		 */
//		private function responseGetUserBalance(xml:XML=null):void {
//			var response:NetCommand;
//
//			if ( xml.name().toString() == 'error' ) {
//
//				response = new NetCommand( 'responseGetUserBalanceError', NetCommand.INPUT );
//				response.push( XMLUtils.parseUIntNode( xml.error_code ) );
//
//			} else {
//				response = new NetCommand( 'responseGetUserBalance', NetCommand.INPUT );
//				response.push(XMLUtils.parseUIntNode(xml.balance));
//			}
//			
//			super.$invokeCallInputCommand( response, false );
//		}

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
			vars.method = this._methods[ handler ];
			vars.owner = this._viewerID;
			vars.token = this._token;
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
//				super.baseController.call( 'vkontakteSigRequest', data );
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
//		private function command_vkontakteSigResponse(event:CommandEvent):void {
//			this.requestMethod( event.command[ 0 ], event.command[ 1 ] );
//		}

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
			var response:Object;

			if ( !( event is ErrorEvent ) ) {
				try {
					response = (new JSONDecoder(loader.data)).getValue();
				} catch ( e:Error ) {
				}
			}
			
			if (!response /*|| ('error' in response)*/) {
				setTimeout(this.requestSig, 3E3, request.vars, request.handler);
			} else {
				request.handler(response);
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