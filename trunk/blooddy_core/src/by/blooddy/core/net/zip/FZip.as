////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//  © 2006 Claus Wahlers and Max Herkender
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.zip {

	import by.blooddy.core.errors.ParserError;
	import by.blooddy.core.events.FZipEvent;
	import by.blooddy.core.events.ParserErrorEvent;
	import by.blooddy.core.net.ILoader;
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.Endian;

	//--------------------------------------
	//  Implemented events: ILoader
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
	 * Файл распоковался.
	 * 
	 * @eventType			by.blooddy.core.events.FZipEvent.EXTRACT
	 */
	[Event(name="extract", type="by.blooddy.core.events.FZipEvent")]

	/**
	 * Ошибка парсинга.
	 * 
	 * @eventType			by.blooddy.core.events.ParserErrorEvent.PARSER_ERROR
	 */
	[Event(name="parserError", type="by.blooddy.core.events.ParserErrorEvent")]

	/**
	 * @author					BlooDHounD, Claus Wahlers, Max Herkender
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					fzip, zip
	 * 
	 * @see						http://codeazur.com.br/lab/fzip/
	 * @see						http://www.pkware.com/documents/casestudies/APPNOTE.TXT
	 */
	public class FZip extends EventDispatcher implements ILoader {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Нэймспэйс для остановки парсинга.
		 */
		private namespace idle;

		/**
		 * @private
		 * Нэймспэйс для парсинга заголовка.
		 */
		private namespace signature;

		/**
		 * @private
		 * Нэймспэйс для парсинга файла.
		 */
		private namespace file;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function FZip(request:URLRequest=null) {
			super();
			this._parseState = idle;
			this._hash = new Object();
			this._list = new Array();
			this._stream = new flash.net.URLStream();
			this._stream.endian = Endian.LITTLE_ENDIAN;
			this._stream.addEventListener(Event.OPEN,							this.dispatchEvent);
			this._stream.addEventListener(ProgressEvent.PROGRESS,				this.handler_progress);
			this._stream.addEventListener(HTTPStatusEvent.HTTP_STATUS,			this.dispatchEvent);
			this._stream.addEventListener(Event.COMPLETE,						this.handler_complete);
			this._stream.addEventListener(IOErrorEvent.IO_ERROR,				this.handler_error);
			this._stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR,	this.handler_error);
			if (request) this.load(request);
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Грузильщик.
		 */
		private var _stream:flash.net.URLStream;

		/**
		 * @private
		 * Хэш по именам.
		 */
		private var _hash:Object;

		/**
		 * @private
		 * Список.
		 */
		private var _list:Array;

		/**
		 * @private
		 * Состояние парсинга.
		 */
		private var _parseState:Namespace;

		/**
		 * @private
		 * Парсищимйся в данный момент файл.
		 */
		private var _currentFile:FZipFile;

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
		private var _url:String;

	    [Bindable("open")]
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

	    [Bindable("open")]
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

	    [Bindable("complete")]
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

	    [Bindable("complete")]
		/**
		 * @inheritDoc
		 */
		public function get loaded():Boolean {
			return this._loaded;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  fileCount
		//----------------------------------

	    [Bindable("complete")]
		/**
		 * Количество файлов.
		 * 
		 * @keyword					fzip.filecount, filecount
		 */
		public function get fileCount():uint {
			return this._list.length;
		}

		//----------------------------------
		//  fileList
		//----------------------------------

		/**
		 * @private
		 */
		private var _fileList:Array;

		[ArrayElementType("String")]
	    [Bindable("complete")]
		/**
		 * Список файлов.
		 * 
		 * @keyword					fzip.filelist, filelist
		 */
		public function get fileList():Array {
			var list:Array = this._fileList;
			if (!list) {
				list = new Array();
				var l:uint = this._list.length;
				for (var i:uint = 0; i<l; i++) {
					list[i] = ( this._list[i] as FZipFile ).filename;
				}
				if (this._loaded) this._fileList = list;
			}
			return list;
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
			this._parseState = signature;
			this._stream.load(request);
		}

		/**
		 * @inheritDoc
		 */
		public function close():void {
			this._stream.close();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Возвращает файл по имени.
		 * 
		 * @param	name			Имя файла.
		 * 
		 * @keyword					fzip.getfilebyname, getfilebyname
		 */
		public function getFileByName(name:String):FZipFile {
			return this._hash[name] as FZipFile;
		}

		/**
		 * Возвращает файл по имени.
		 * 
		 * @param	name			Индекс файла.
		 * 
		 * @keyword					fzip.getfileat, getfileat
		 */
		public function getFileAt(index:uint):FZipFile {
			return this._list[index] as FZipFile;
		}

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
			this._parseState = idle;
			this._url = null;
			this._bytesLoaded = 0;
			this._bytesTotal = 0;
			this._loaded = false;
			this._currentFile = null;
		}

		/**
		 * @private
		 * Парсинг.
		 */
		private function parse():Boolean {
			while ( this._parseState::parse() );
			return (this._parseState == idle);
		}

		/**
		 * @private
		 * Парсинг остановлен.
		 */
		idle function parse():Boolean {
			return false;
		}

		/**
		 * @private
		 * Парсинг заголовка файла.
		 */
		signature function parse():Boolean {
			if (this._stream.bytesAvailable >= 4) {
				switch ( this._stream.readUnsignedInt() ) {
					case 0x04034B50:
						this._parseState = file;
						this._currentFile = new FZipFile();
						break;
					case 0x02014B50:
					case 0x06054B50:
						this._parseState = idle;
						break;
					default:
						throw new ParserError("Unknown record signature.");
						break;
				}
				return true;
			}
			return false;
		}

		/**
		 * @private
		 * Парсинг файла.
		 */
		file function parse():Boolean {
			if (this._currentFile.readExternal(this._stream)) {
				if (this._currentFile.loaded) {
					this._list.push(this._currentFile);
					if (this._currentFile.filename) {
						this._hash[this._currentFile.filename] = this._currentFile;
					}
					this.dispatchEvent( new FZipEvent(FZipEvent.EXTRACT, false, false, this._currentFile));
					this._currentFile = null;
					this._parseState = signature;
				}
				return true;
			}
			return false;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_progress(event:ProgressEvent):void {
			this._bytesLoaded = event.bytesLoaded;
			this._bytesTotal = event.bytesTotal;
			this.dispatchEvent(event);
			try {
				this.parse();
			} catch (e:Error) {
				this.clearVariables();
				if ( this.hasEventListener( ParserErrorEvent.PARSER_ERROR ) ) super.dispatchEvent( new ParserErrorEvent( ParserErrorEvent.PARSER_ERROR, false, false, e.message ) );
			}
		}

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			this._loaded = true;
			super.dispatchEvent( event );
		}

		/**
		 * @private
		 */		private function handler_error(event:Event):void {
			if ( this.hasEventListener( event.type ) ) super.dispatchEvent( event );
			this.clearVariables();
		}

	}

}