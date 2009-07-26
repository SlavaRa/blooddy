////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.utils.ClassUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	//--------------------------------------
	//  Implements events: ILoader
	//--------------------------------------

	/**
	 * @inheritDoc
	 */
	[Event(name="complete", type="flash.events.Event")]

	/**
	 * @inheritDoc
	 */
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]

	/**
	 * @inheritDoc
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")]

	/**
	 * @inheritDoc
	 */
	[Event(name="open", type="flash.events.Event")]

	/**
	 * @inheritDoc
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")]

	/**
	 * @inheritDoc
	 */
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Транслируется, когда Flash Player может определить
	 * HTTP статус.
	 * 
	 * @eventType			flash.events.HTTPStatusEvent.HTTP_RESPONSE_STATUS
	 */
	[Event(name="httpResponseStatus", type="flash.events.HTTPStatusEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					urlstream
	 */
	public class URLStream extends EventDispatcher implements ILoader, IDataInput {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		private static const HTTP_RESPONSE_STATUS:String = ( 'HTTP_RESPONSE_STATUS' in HTTPStatusEvent ? HTTPStatusEvent['HTTP_RESPONSE_STATUS'] : null );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	request			Если надо, то сразу передадим и начнётся загрузка.
		 */
		public function URLStream(request:URLRequest=null) {
			super();
			this._loader = new flash.net.URLStream();
			this._loader.addEventListener( Event.OPEN,							super.dispatchEvent );
			this._loader.addEventListener( ProgressEvent.PROGRESS,				this.handler_progress );
			this._loader.addEventListener( HTTPStatusEvent.HTTP_STATUS,			super.dispatchEvent );
			if ( HTTP_RESPONSE_STATUS ) {
				this._loader.addEventListener( HTTP_RESPONSE_STATUS,			super.dispatchEvent );
			}
			this._loader.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
			this._loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
			this._loader.addEventListener( Event.COMPLETE,						this.handler_complete );
			if ( request ) this.load( request );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _loader:flash.net.URLStream;

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoader
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  url
		//----------------------------------

		/**
		 * @private
		 */
		private var _url:String = null;

		/**
		 * @inheritDoc
		 */
		public function get url():String {
			return this._url;
		}

		//----------------------------------
		//  bytesLoaded
		//----------------------------------

		/**
		 * @private
		 */
		private var _bytesLoaded:uint = 0;

		/**
		 * @inheritDoc
		 */
		public function get bytesLoaded():uint {
			return this._bytesLoaded;
		}

		//----------------------------------
		//  bytesTotal
		//----------------------------------

		/**
		 * @private
		 */
		private var _bytesTotal:uint = 0;

		/**
		 * @inheritDoc
		 */
		public function get bytesTotal():uint {
			return this._bytesTotal;
		}

		//----------------------------------
		//  loaded
		//----------------------------------

		/**
		 * @private
		 */
		private var _loaded:Boolean = false;

		/**
		 * @inheritDoc
		 */
		public function get loaded():Boolean {
			return this._loaded;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties: IDataInput
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  bytesAvailable
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get bytesAvailable():uint {
			return this._loader.bytesAvailable;
		}

		//----------------------------------
		//  endian
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get endian():String {
			return this._loader.endian;
		}

		/**
		 * @private
		 */
		public function set endian(value:String):void {
			this._loader.endian = value;
		}

		//----------------------------------
		//  objectEncoding
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get objectEncoding():uint {
			return this._loader.objectEncoding;
		}

		/**
		 * @private
		 */
		public function set objectEncoding(value:uint):void {
			this._loader.objectEncoding = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  connected
		//----------------------------------

		/**
		 * @copy				flash.net.URLStream#connected
		 */
		public function get connected():Boolean {
			return this._loader.connected;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: ILoader
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function load(request:URLRequest):void {
			this.clearVariables();
			this._url = request.url;
			this._loader.load(request);
		}

		/**
		 * @inheritDoc
		 */
		public function close():void {
			this._loader.close();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IDataInput
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function readBoolean():Boolean {
			return this._loader.readBoolean();
		}

		/**
		 * @inheritDoc
		 */
		public function readByte():int {
			return this._loader.readByte();
		}

		/**
		 * @inheritDoc
		 */
		public function readBytes(bytes:ByteArray, offset:uint = 0, length:uint = 0):void {
			this._loader.readBytes(bytes, offset, length);
		}

		/**
		 * @inheritDoc
		 */
		public function readDouble():Number {
			return this._loader.readDouble();
		}

		/**
		 * @inheritDoc
		 */
		public function readFloat():Number {
			return this._loader.readFloat();
		}

		/**
		 * @inheritDoc
		 */
		public function readInt():int {
			return this._loader.readInt();
		}

		/**
		 * @inheritDoc
		 */
		public function readMultiByte(length:uint, charSet:String):String {
			return this._loader.readMultiByte(length, charSet);
		}

		/**
		 * @inheritDoc
		 */
		public function readObject():* {
			return this._loader.readObject();
		}

		/**
		 * @inheritDoc
		 */
		public function readShort():int {
			return this._loader.readShort();
		}

		/**
		 * @inheritDoc
		 */
		public function readUnsignedByte():uint {
			return this._loader.readUnsignedByte();
		}

		/**
		 * @inheritDoc
		 */
		public function readUnsignedInt():uint {
			return this._loader.readUnsignedInt();
		}

		/**
		 * @inheritDoc
		 */
		public function readUnsignedShort():uint {
			return this._loader.readUnsignedShort();
		}

		/**
		 * @inheritDoc
		 */
		public function readUTF():String {
			return this._loader.readUTF();
		}

		/**
		 * @inheritDoc
		 */
		public function readUTFBytes(length:uint):String {
			return this._loader.readUTFBytes(length);
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function toString():String {
			return "[" + ClassUtils.getClassName(this) + " url="+this.url + "]";
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Чистим переменные.
		 */
		private function clearVariables():void {
			try {
				this.close();
			} catch (e:Error) {
			}
			this._url = null;
			this._loaded = false;
			this._bytesLoaded = 0;
			this._bytesTotal = 0;
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
			this._loaded = true;
			super.dispatchEvent( event );
		}

		/**
		 * @private
		 */
		private function handler_error(event:Event):void {
			// Перенапрвляем, только если есть листенер
			// иначе возникает ошибка.
			if ( super.hasEventListener( event.type ) ) super.dispatchEvent( event );
			this.clearVariables(); // очищаем переменные
		}

		/**
		 * @private
		 */
		private function handler_progress(event:ProgressEvent):void {
			this._bytesTotal = event.bytesTotal;
			this._bytesLoaded = event.bytesLoaded;
			super.dispatchEvent( event );
		}

	}

}