////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.social.vkontakte_ru {
	
	import by.blooddy.core.commands.Command;
	import by.blooddy.core.net.MIME;
	import by.blooddy.core.net.connection.LocalConnection;
	import by.blooddy.core.net.loading.URLLoader;
	import by.blooddy.core.utils.crypto.MD5;
	import by.blooddy.core.utils.time.setTimeout;
	import by.blooddy.core.utils.xml.XMLUtils;
	import by.blooddy.social.SocialAPI;
	import by.blooddy.social.data.SocialUserData;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.05.2010 18:52:52
	 */
	public class VkontakteAPI extends SocialAPI {
		
		//--------------------------------------------------------------------------
		//
		//  Namespace
		//
		//--------------------------------------------------------------------------

		use namespace social;

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const SOCIAL_DOMAIN:String =	'vkontakte.ru';
		
		public static const SOCIAL_URL:String =		'http://' + SOCIAL_DOMAIN + '/';
		
		public static const API_URL:String =		'http://api.' + SOCIAL_DOMAIN + '/api.php';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function VkontakteAPI(appID:String, viewerID:String, secretKey:String=null, connectionName:String=null, wrapper:Object=null) {
			super();

			this._responders[ 'getProfiles' ] =		this.responseUsers;
			this._responders[ 'isAppUser' ] =		this.responseIsAppUser;
			this._responders[ 'getAppFriends' ] =	this.responseGetAppFriends;
			this._responders[ 'getUserBalance' ] =	this.responseGetUserBalance;

			this._appID = appID;
			this._viewerID = viewerID;
			this._secretKey = secretKey;

			if ( // если есть враппер, то используем его
				wrapper &&
				'external' in wrapper &&
				wrapper is IEventDispatcher &&
				'showInstallBox' in wrapper &&
				'showSettingsBox' in wrapper &&
				'showInviteBox' in wrapper &&
				'showPaymentBox' in wrapper
			) {

				this._wrapper = wrapper.external;

			} else if ( connectionName ) { // если нету, то используем LocalConnection

				this._connection = new LocalConnection();
				this._connection.client = {};
				this._connection.addEventListener( AsyncErrorEvent.ASYNC_ERROR,			this.handler_asyncError, false, 0, true );
				this._connection.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_securityError, false, 0, true );
				this._connection.addEventListener( StatusEvent.STATUS,					this.handler_status, false, 0, true );
				this._connection.allowDomain( '*' );
				this._connection.targetName = '_in_' + connectionName;
				this._connection.open( '_out_' + connectionName );
				this._connection.call( 'initConnection' );

			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		
		/**
		 * @private
		 */
		private var _wrapper:Object;
		
		/**
		 * @private
		 */
		private var _connection:LocalConnection;

		/**
		 * @private
		 */
		private var _inited:Boolean = false;

		/**
		 * @private
		 */
		private var _cache:Vector.<Array>;
		
		/**
		 * @private
		 */
		private const _responders:Object = new Object();
		
		/**
		 * @private
		 */
		private const _requestHash:Object = new Object();
		
		/**
		 * @private
		 */
		private const _loadersHash:Dictionary = new Dictionary();
		
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
		private var _secretKey:String;

		public function get secretKey():String {
			return this._secretKey;
		}

		//--------------------------------------------------------------------------
		//
		//  Social methods
		//
		//--------------------------------------------------------------------------

		social override function requestUsers(...usersID):void {
			var vars:URLVariables = new URLVariables();
			vars.uids = usersID.join( ',' );
			vars.fields = 'uid,first_name,last_name,nickname,sex,bdate,photo,photo_medium,photo_big'; 
			this.request( 'getProfiles', vars );
		}

		social override function requestIsAppUser(userID:String):void {
			var vars:URLVariables = new URLVariables();
			vars.uid = userID;
			this.request( 'getProfiles', vars );
		}

		social override function requestGetAppFriends():void {
			this.request( 'getAppFriends' );
		}

		social override function requestGetUserBalance(userID:String):void {
			this.request( 'getUserBalance' );
		}

		social override function showInstallBox():void {
			this.$call( 'showInstallBox' );
		}

		social override function showSettingsBox(settings:uint=0):void {
			this.$call( 'showSettingsBox', settings );
		}
		
		social override function showInviteBox(excludeIDs:Array=null):void {
			this.$call( 'showInviteBox', excludeIDs );
		}
		
		social override function showPaymentBox(votes:uint=0):void {
			this.$call( 'showPaymentBox', votes );
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
			var response:Command;
			
			if ( xml.name().toString() == 'error' ) {
				
				response = new Command( 'responseUsersError' );
				response.push( XMLUtils.parseListToInt( xml.error_code ) );
				
			} else {
				
				response = new Command( 'responseUsers' );
				var list:XMLList = xml.user;
				for each ( var user:XML in list ) {
					var data:SocialUserData = new SocialUserData( XMLUtils.parseListToString( user.uid ) );
					data.firstName =		XMLUtils.parseListToString( user.first_name );
					data.lastName =			XMLUtils.parseListToString( user.last_name );
					data.nickName =			XMLUtils.parseListToString( user.nickname );
					data.sex =				XMLUtils.parseListToInt( user.sex ) - 1;
					var birthday:String =	XMLUtils.parseListToString( user.bdate );
					if ( birthday ) {
						var arr:Array =		birthday.split( '.' );
						data.birthday =		new Date( parseInt( arr[ 2 ] ), parseInt( arr[ 1 ] ) - 1, parseInt( arr[ 0 ] ) );
					}
					data.photo =			XMLUtils.parseListToString( user.photo );
					if ( data.photo && data.photo.indexOf( SOCIAL_DOMAIN ) < 0 ) {
						data.photo = SOCIAL_URL + data.photo;
					}
					data.mediumPhoto =		XMLUtils.parseListToString( user.photo_medium );
					if ( data.mediumPhoto && data.mediumPhoto.indexOf( SOCIAL_DOMAIN ) < 0 ) {
						data.mediumPhoto = SOCIAL_URL + data.mediumPhoto;
					}
					data.bigPhoto =			XMLUtils.parseListToString( user.photo_big );
					if ( data.bigPhoto && data.bigPhoto.indexOf( SOCIAL_DOMAIN ) < 0 ) {
						data.bigPhoto = SOCIAL_URL + data.bigPhoto;
					}		
					data.url =				SOCIAL_URL +'id' + data.id;
					response.push( data );
				}
				
			}
			
			super.$invokeCallInputCommand( response );
		}
		
		/**
		 * @private
		 */
		private function responseIsAppUser(xml:XML=null):void {
			var response:Command;

			if ( xml.name().toString() == 'error' ) {

				response = new Command( 'responseIsAppUserError' );
				response.push( XMLUtils.parseListToInt( xml.error_code ) );

			} else {

				response = new Command( 'responseIsAppUser' );
				response.push( XMLUtils.parseToBoolean( xml ) );

			}

			super.$invokeCallInputCommand( response, false );
		}
		
		/**
		 * @private
		 */
		private function responseGetAppFriends(xml:XML=null):void {
			var response:Command;
			
			if ( xml.name().toString() == 'error' ) {
				
				response = new Command( 'responseGetAppFriendsError' );
				response.push( XMLUtils.parseListToInt( xml.error_code ) );
				
			} else {

				response = new Command( 'responseGetAppFriends' );
				var list:XMLList = xml.uid;
				for each ( var uid:XML in list ) {
					response.push( XMLUtils.parseToString( uid ) );
				}

			}
			
			super.$invokeCallInputCommand( response, false );
		}
		
		/**
		 * @private
		 */
		private function responseGetUserBalance(xml:XML=null):void {
			var response:Command;

			if ( xml.name().toString() == 'error' ) {

				response = new Command( 'responseGetUserBalanceError' );
				response.push( XMLUtils.parseListToInt( xml.error_code ) );

			} else {

				response = new Command( 'responseGetUserBalance' );
				response.push( XMLUtils.parseListToInt( xml.balance ) );

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
		private function request(method:String, vars:URLVariables=null):void {

			if ( !vars ) vars = new URLVariables();
			// формируем базовые переменные
			vars.api_id = this._appID;
			vars.v = '2.0';
			vars.method = method;
//			vars.test_mode="1";
			
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
			
			if ( data in this._requestHash ) return; // такой запрос уже в процессе

			vars.sig = MD5.hash( this._viewerID + data + this._secretKey );

			var asset:RequestAsset = new RequestAsset();
			asset.response = this._responders[ method ];
			asset.vars = vars;

			this._requestHash[ data ] = request;

			this.requestMethod( data );
			
		}

		/**
		 * @private
		 */
		private function requestMethod(data:String):void {
			var asset:RequestAsset = this._requestHash[ data ];
			var request:URLRequest = new URLRequest( API_URL );
			request.data = asset.vars;
			request.contentType = MIME.VARS;
			var loader:URLLoader = new URLLoader( request );
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener( Event.COMPLETE,	this.handler_complete );
			loader.addEventListener( ErrorEvent.ERROR,	this.handler_complete );
			this._loadersHash[ loader ] = data;
		}

		/**
		 * @private
		 */
		private function $call(commandName:String, ...parameters):void {
			parameters.unshift( commandName );
			if ( this._wrapper ) {
				this._wrapper[ commandName ].apply( this._wrapper, parameters );
			} else if ( this._connection ) {
				if ( this._inited ) {
					this._connection.call.apply( null, parameters );
				} else {
					if ( !this._cache ) this._cache = new Vector.<Array>();
					this._cache.push( parameters );
				}
			} else {
				super.$callInputCommand( new Command( commandName, parameters ) );
			}
		}

		/**
		 * @private
		 */
		private function initConnection():void {
			this._connection.removeEventListener( StatusEvent.STATUS, this.handler_status );
			this._inited = true;
			if ( this._cache ) {
				while ( this._cache.length > 0 ) {
					this._connection.call.apply( null, this._cache.shift() );
				}
				this._cache = null;
			}
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
			loader.removeEventListener( Event.COMPLETE,		this.handler_complete );
			loader.removeEventListener( ErrorEvent.ERROR,	this.handler_complete );

			var data:String = this._loadersHash[ loader ];
			delete this._loadersHash[ loader ];

			var xml:XML;
			if ( !( event is ErrorEvent ) ) {
				try {
					xml = new XML( loader.content );
				} catch ( e:Error ) {
				}
			}
			
			if ( !xml || ( xml.name().toString() == 'error' && XMLUtils.parseListToInt( xml.error_code ) == 6 ) ) { // ошибка таймаута запросим попозже
				setTimeout( this.requestMethod, 3E3, data );
			} else {
				var asset:RequestAsset = this._requestHash[ data ];
				delete this._requestHash[ data ];
				asset.response( xml );
			}
		}

		/**
		 * @private
		 */
		private function handler_asyncError(event:AsyncErrorEvent):void {
			// ignore
		}

		/**
		 * @private
		 */
		private function handler_securityError(event:SecurityErrorEvent):void {
			if ( this._connection.connected ) {
				this._connection.close();
			}
			this._connection.targetName = null;
			this._connection.removeEventListener( StatusEvent.STATUS,					this.handler_status );
			this._connection.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_securityError );
			this._connection.removeEventListener( AsyncErrorEvent.ASYNC_ERROR,			this.handler_asyncError );
			this._connection = null;
			this._cache = null;
		}

		/**
		 * @private
		 */
		private function handler_status(event:StatusEvent):void {
			if ( event.level == 'status' ) {
				this.initConnection();
			}
		}
		
	}
	
}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.net.URLVariables;

/**
 * @private
 */
internal final class RequestAsset {
	
	public function RequestAsset() {
		super();
	}
	
	public var vars:URLVariables;
	
	public var response:Function;
	
}