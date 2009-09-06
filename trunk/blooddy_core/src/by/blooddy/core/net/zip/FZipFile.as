////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//  © 2006 Claus Wahlers and Max Herkender
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.zip {

	import by.blooddy.core.errors.ParserError;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;

	import flash.utils.IDataInput;
	import flash.utils.Endian;
	import flash.utils.ByteArray;

	import by.blooddy.core.net.ILoadable;
	import flash.events.EventDispatcher;

	//--------------------------------------
	//  Implemented events: ILoadable
	//--------------------------------------

	/**
	 * @inheritDoc
	 */
	[Event( name="complete", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="open", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="progress", type="flash.events.ProgressEvent" )]

	/**
	 * @author					BlooDHounD, Claus Wahlers, Max Herkender
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					fzipfile, fzip, zip, zipfile
	 * 
	 * @see						http://codeazur.com.br/lab/fzip/
	 * @see						http://www.pkware.com/documents/casestudies/APPNOTE.TXT
	 */
	public class FZipFile extends ByteArray implements ILoadable {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Нэймспэйс для остановки парсинга.
		 */
		private namespace idle = "http://www.tzmedia.ru/platform/net/fzipfile/idle";

		/**
		 * @private
		 * Нэймспэйс для парсинга заголовка.
		 */
		private namespace head = "http://www.tzmedia.ru/platform/net/fzipfile/head";

		/**
		 * @private
		 * Нэймспэйс для парсинга расширенного заголовка.
		 */
		private namespace headExt = "http://www.tzmedia.ru/platform/net/fzipfile/headext";

		/**
		 * @private
		 * Нэймспэйс для парсинга содеражания.
		 */
		private namespace content = "http://www.tzmedia.ru/platform/net/fzipfile/content";

		//--------------------------------------------------------------------------
		//
		//  Constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @keyword					fzipfile.compression_none, compression_none
		 */
		public static const COMPRESSION_NONE:uint = 0;

		/**
		 * @keyword					fzipfile.compression_shrunk, compression_shrunk
		 */
		public static const COMPRESSION_SHRUNK:uint = 1;

		/**
		 * @keyword					fzipfile.compression_reduced_1, compression_reduced_1
		 */
		public static const COMPRESSION_REDUCED_1:uint = 2;

		/**
		 * @keyword					fzipfile.compression_reduced_2, compression_reduced_2
		 */
		public static const COMPRESSION_REDUCED_2:uint = 3;

		/**
		 * @keyword					fzipfile.compression_reduced_3, compression_reduced_3
		 */
		public static const COMPRESSION_REDUCED_3:uint = 4;

		/**
		 * @keyword					fzipfile.compression_reduced_4, compression_reduced_4
		 */
		public static const COMPRESSION_REDUCED_4:uint = 5;

		/**
		 * @keyword					fzipfile.compression_imploded, compression_imploded
		 */
		public static const COMPRESSION_IMPLODED:uint = 6;

		/**
		 * @keyword					fzipfile.compression_tokenized, compression_tokenized
		 */
		public static const COMPRESSION_TOKENIZED:uint = 7;

		/**
		 * @keyword					fzipfile.compression_deflated, compression_deflated
		 */
		public static const COMPRESSION_DEFLATED:uint = 8;

		/**
		 * @keyword					fzipfile.compression_deflated_ext, compression_deflated_ext
		 */
		public static const COMPRESSION_DEFLATED_EXT:uint = 9;

		/**
		 * @keyword					fzipfile.compression_imploded_pkware, compression_imploded_pkware
		 */
		public static const COMPRESSION_IMPLODED_PKWARE:uint = 10;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function FZipFile() {
			super();
			this._parseState = head;
			this._dispatcher = new EventDispatcher(this);
			this._extraFields = new Object();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Наш диспатчер.
		 */
		private var _dispatcher:EventDispatcher;

		/**
		 * @private
		 * Состояние парсинга.
		 */
		private var _parseState:Namespace;

		/**
		 * @private
		 */
		private var _versionHost:uint;

		/**
		 * @private
		 */
		private var _compressionMethod:uint;

		/**
		 * @private
		 */
		private var _encrypted:Boolean = false;

		/**
		 * @private
		 */
		private var _hasDataDescriptor:Boolean = false;

		/**
		 * @private
		 */
		private var _hasCompressedPatchedData:Boolean = false;

		/**
		 * @private
		 */
		private var _implodeDictSize:uint;

		/**
		 * @private
		 */
		private var _implodeShannonFanoTrees:uint;

		/**
		 * @private
		 */
		private var _deflateSpeedOption:uint;

		/**
		 * @private
		 */
		private var _crc32:uint;

		/**
		 * @private
		 */
		private var _sizeFilename:uint = 0;

		/**
		 * @private
		 */
		private var _sizeExtra:uint = 0;

		/**
		 * @private
		 */
		private var _adler32:uint;

		/**
		 * @private
		 */
		private var _hasAdler32:Boolean = false;

		/**
		 * @private
		 */
		private var _extraFields:Object;

		/**
		 * @private
		 * Filenames in ZIPs usually are IBM850 encoded,
		 * at least it seems to be like that on Windows
		 */
		private var _filenameEncoding:String = "ibm850";

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoader
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  bytesLoaded
		//----------------------------------

		/**
		 * @private
		 */
		private var _bytesLoaded:uint = 0;

	    [Bindable( "progress" )]
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

	    [Bindable( "complete" )]
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

	    [Bindable( "complete" )]
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
		//  filename
		//----------------------------------

		/**
		 * @private
		 */
		private var _filename:String;

	    [Bindable( "open" )]
		/**
		 * Имя файла.
		 * 
		 * @keyword					fzipfile.filename, filename
		 */
		public function get filename():String {
			return this._filename;
		}

		//----------------------------------
		//  versionNumber
		//----------------------------------

		/**
		 * @private
		 */
		private var _version:Number;

	    [Bindable( "open" )]
		/**
		 * The ZIP specification version supported by the software 
		 * used to encode the file.
		 * 
		 * @keyword					fzipfile.version, version
		 */
		public function get version():Number {
			return this._version;
		}

		//----------------------------------
		//  date
		//----------------------------------

		/**
		 * @private
		 */
		private var _date:Date;

	    [Bindable( "open" )]
		/**
		 * The Date and time the file was created.
		 * 
		 * @keyword					fzipfile.date, date
		 */
		public function get date():Date {
			return this._date;
		}

		//----------------------------------
		//  sizeCompressed
		//----------------------------------

		/**
		 * @private
		 */
		private var _sizeCompressed:uint = 0;

	    [Bindable( "open" )]
		/**
		 * The size of the compressed file (in bytes).
		 * 
		 * @keyword					fzipfile.sizecompressed, sizecompressed
		 */
		public function get sizeCompressed():uint {
			return this._sizeCompressed;
		}

		//----------------------------------
		//  sizeUncompressed
		//----------------------------------

		/**
		 * @private
		 */
		private var _sizeUncompressed:uint = 0;

	    [Bindable( "open" )]
		/**
		 * The size of the uncompressed file (in bytes).
		 * 
		 * @keyword					fzipfile.sizeuncompressed, sizeuncompressed
		 */
		public function get sizeUncompressed():uint {
			return this._sizeUncompressed;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: ILoadable
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			this._dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		/**
		 * @inheritDoc
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			this._dispatcher.removeEventListener(type, listener, useCapture);
		}

		/**
		 * @inheritDoc
		 */
		public function hasEventListener(type:String):Boolean {
			return this._dispatcher.hasEventListener(type);
		}

		/**
		 * @inheritDoc
		 */
		public function willTrigger(type:String):Boolean {
			return this._dispatcher.willTrigger(type);
		}

		/**
		 * @inheritDoc
		 */
		public function dispatchEvent(event:Event):Boolean {
			return this._dispatcher.dispatchEvent(event);
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Записываем любые бинарные данные.
		 * 
		 * @param	bytes			байты.
		 * 
		 * @event	
		 * 
		 * @keyword					fzipfile.readexternal, readexternal
		 */
		public function readExternal(bytes:IDataInput):Boolean {
			try {
				while ( this._parseState::parse(bytes) );
			} catch (e:Error) {
				// TODO: ошибку зафигачить
				if (this.hasEventListener(IOErrorEvent.IO_ERROR)) this.dispatchEvent( new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, e.message) );
				else throw e;
			}
			return ( this._parseState == idle );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		idle function parse(bytes:IDataInput):Boolean {
			return false;
		}

		/**
		 * @private
		 */
		head function parse(bytes:IDataInput):Boolean {
			if (bytes.bytesAvailable >= 30) {
				var vSrc:uint = bytes.readUnsignedShort();
				this._versionHost = vSrc >> 8;
				this._version = Number( Math.floor( (vSrc&0xFF)/10 ) + "." + ( (vSrc & 0xFF)%10 ) );
				var flag:uint = bytes.readUnsignedShort();
				this._compressionMethod = bytes.readUnsignedShort();
				this._encrypted = (flag & 0x01) != 0;
				this._hasDataDescriptor = (flag & 0x08) != 0;
				this._hasCompressedPatchedData = (flag & 0x20) != 0;
				if ((flag & 800) !== 0) this._filenameEncoding = "utf-8";
				switch (this._compressionMethod) {
					case COMPRESSION_IMPLODED:
						this._implodeDictSize = ( flag & 0x02 != 0 ? 8192 : 4096 );
						this._implodeShannonFanoTrees = (flag & 0x04 != 0 ? 3 : 2 );
						break;
					case COMPRESSION_DEFLATED:
						this._deflateSpeedOption = (flag & 0x06) >> 1;
						break;
				}
				var msdosTime:uint = bytes.readUnsignedShort();
				var msdosDate:uint = bytes.readUnsignedShort();
				var sec:uint = (msdosTime & 0x001F);
				var min:uint = (msdosTime & 0x07E0) >> 5;
				var hour:uint = (msdosTime & 0xF800) >> 11;
				var day:uint = (msdosDate & 0x001F);
				var month:uint = (msdosDate & 0x01E0) >> 5 - 1;
				var year:uint = ((msdosDate & 0xFE00) >> 9) + 1980;
				this._date = new Date(year, month, day, hour, min, sec, 0);
				this._crc32 = bytes.readUnsignedInt();
				this._sizeCompressed = bytes.readUnsignedInt();
				this._sizeUncompressed = bytes.readUnsignedInt();
				this._sizeFilename = bytes.readUnsignedShort();
				this._sizeExtra = bytes.readUnsignedShort();
				// либо читаем расширенный заголовок, либо переходим к содержанию
				if (this._sizeFilename + this._sizeExtra > 0) {
					this._parseState = headExt;
				} else {
					this._parseState = content;
				}
				// прочитали заголовок
				this.dispatchEvent( new Event(Event.OPEN) );
				return true;
			}
			return false;
		}

		/**
		 * @private
		 */
		headExt function parse(bytes:IDataInput):Boolean {
			if (bytes.bytesAvailable >= this._sizeFilename + this._sizeExtra) {
				this._filename = bytes.readMultiByte(this._sizeFilename, this._filenameEncoding);
				var bytesLeft:uint = this._sizeExtra;
				var headerId:uint, dataSize:uint;
				while (bytesLeft > 4) {
					headerId = bytes.readUnsignedShort();
					dataSize = bytes.readUnsignedShort();
					if (dataSize > bytesLeft) {
						throw new ParserError("Parse error in file " + _filename + ": Extra field data size too big.");
					}
					if (headerId == 0xDADA && dataSize == 4) {
						this._adler32 = bytes.readUnsignedInt();
						this._hasAdler32 = true;
					} else if (dataSize > 0) {
						var extraBytes:ByteArray = new ByteArray();
						bytes.readBytes(extraBytes, 0, dataSize);
						this._extraFields[headerId] = extraBytes;
					}
					bytesLeft -= dataSize + 4;
				}
				if (bytesLeft > 0) {
					bytes.readBytes(new ByteArray(), 0, bytesLeft);
				}
				this._parseState = content;
				return true;
			}
			return false;
		}

		/**
		 * @private
		 */
		content function parse(bytes:IDataInput):Boolean {
			// диспатчим прогресс
			this.dispatchEvent( new ProgressEvent(ProgressEvent.PROGRESS, false, false, Math.max(bytes.bytesAvailable, this._sizeCompressed), this._sizeCompressed) );
			if (this._hasDataDescriptor) {				// Data descriptors are not supported
				this._parseState = idle;
				throw new ParserError("Data descriptors are not supported.");
			} else if (this._sizeCompressed == 0) {		// This entry has no file attached
				this._parseState = idle;
			} else if (bytes.bytesAvailable >= this._sizeCompressed) {
				try {
					this["write_uncompress_"+( !this._encrypted ? this._compressionMethod : COMPRESSION_NONE ) ](bytes);
					this._loaded = true;
					this.dispatchEvent( new Event(Event.COMPLETE) );
				} catch (e:Error) {
					if (e.errorID == 1069) throw new ParserError("Compression method " + _compressionMethod + " is not supported.");
					else throw e;
				}
				this._parseState = idle;
			} else {
				return false;
			}
			return true;
		}

		/**
		 * @private
		 */
		private function write_uncompress_0(bytes:IDataInput):void {
			this.endian = Endian.BIG_ENDIAN;
			bytes.readBytes(this, 0, this._sizeCompressed);
			this.position = 0;
		}

		/**
		 * @private
		 */
		private function write_uncompress_8(bytes:IDataInput):void {
			// TODO: попробывать самим сгенерить Adler32
			if (this._hasAdler32) {
				this.endian = Endian.BIG_ENDIAN;
				// Add header
				// CMF (compression method and info)
				this.writeByte(0x78);
				// FLG (compression level, preset dict, checkbits)
				var flg:uint = (~this._deflateSpeedOption << 6) & 0xC0;
				flg += 31 - (((0x78 << 8) | flg) % 31);
				this.writeByte(flg);
				// Add raw deflate-compressed file
				bytes.readBytes(this, 2, this._sizeCompressed);
				// Add adler32 checksum
				this.position = this.length;
				this.writeUnsignedInt(this._adler32);
				// Reset fileposition to start-of-file
				this.uncompress();
			} else if (this.hasOwnProperty("inflate")) {
				this["inflate"]();
			} else {
				throw new ParserError("Adler32 checksum not found.");
			}
			this.position = 0;
		}

	}

}