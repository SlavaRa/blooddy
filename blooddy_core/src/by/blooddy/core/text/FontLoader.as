////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.text {

	import by.blooddy.core.managers.resource.IResourceBundle;
	import by.blooddy.core.net.Loader;
	import by.blooddy.core.utils.ByteArrayUtils;
	import by.blooddy.core.utils.SWFByteArray;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.Font;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	 * @author					etc, BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					fontloader, font
	 */
	public class FontLoader extends by.blooddy.core.net.Loader implements IResourceBundle {

  		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const SWF_HEADER:ByteArray = new ByteArray();

		/**
		 * @private
		 */
		private static const CLASS_CODE:ByteArray = new ByteArray();

		/**
		 * @private
		 */
		private static const CLASS_NAME_PREFIX:String = 'Font$';

		/**
		 * @private
		 */
		private static const TAG_DO_ABC:uint = ((72 << 6) | 0x3F);

		/**
		 * @private
		 */
		private static const TAG_SYMBOL_CLASS:uint = ((76 << 6) | 0x3f);

		/**
		 * @private
		 */
		private static var _initialized:Boolean = false;

		/**
		 * @private
		 */
		private static function init():void {
			if ( _initialized ) return;
			var ba:SWFByteArray = new SWFByteArray();
			ba.writeBytes(ByteArrayUtils.stringToBytes(
				'7800055F00000FA000000C01004411080000004302FFFFFFBF150B0000000100466F6E744C69620000' +
				'BF1461020000010000000010002E00000000191272752E657463732E7574696C733A466F6E7400432F' + 
				'55736572732F6574632F4465736B746F702F50726F6A656374732F466F6E744C6F616465724C69622F' + 
				'7372633B72752F657463732F7574696C733B466F6E742E61731772752E657463732E7574696C733A46' + 
				'6F6E742F466F6E74175B4F626A65637420466F6E7420666F6E744E616D653D2208666F6E744E616D65' + 
				'0D2220666F6E745374796C653D2209666F6E745374796C650C2220666F6E74547970653D2208666F6E' + 
				'745479706502225D1B72752E657463732E7574696C733A466F6E742F746F537472696E670653747269' + 
				'6E6708746F537472696E67175F5F676F5F746F5F646566696E6974696F6E5F68656C700466696C6543' + 
				'2F55736572732F6574632F4465736B746F702F50726F6A656374732F466F6E744C6F616465724C6962' + 
				'2F7372632F72752F657463732F7574696C732F466F6E742E617303706F73033636380D72752E657463' + 
				'732E7574696C7304466F6E740A666C6173682E74657874064F626A6563740335373006050116021614' + 
				'161618010201030A07020607020807020A07020D07020E070315070415091501070217040000020000' + 
				'00040000040C0000000200020F02101211130F02101211180106070905000101054100020100000001' + 
				'030106440000010104000101040503D03047000001010105060EF103F018D030F019D04900F01A4700' + 
				'00020201050620F103F01CD0302C05F01DD00401A02C07A0D00402A02C09A0D00403A02C0BA0480000' + 
				'030201010421D030F103F0165D085D096609305D076607305D07660758001D1D6806F103F00B470000'
			)); // Magic bytes :-)
			ba.position = 0;
			ba.readBytes( SWF_HEADER );
			ba.length = 0;
			ba.writeBytes( ByteArrayUtils.stringToBytes(
				'392F55736572732F6574632F4465736B746F702F50726F6A656374732F466F6E744C6F616465724C69' + 
				'622F7372633B3B466F6E743030302E61730568656C6C6F2B48656C6C6F2C20776F726C642120497320' + 
				'616E79626F647920686572653F2057686F27732074686572653F0F466F6E743030302F466F6E743030' + 
				'300D72752E657463732E7574696C7304466F6E74064F626A6563740A666C6173682E74657874175F5F' + 
				'676F5F746F5F646566696E6974696F6E5F68656C700466696C65382F55736572732F6574632F446573' + 
				'6B746F702F50726F6A656374732F466F6E744C6F616465724C69622F7372632F466F6E743030302E61' + 
				'7303706F73023534060501160216071801160A00050702010703080702090705080300000200000006' + 
				'0000000200010B020C0E0D0F0101020904000100000001020101440100010003000101050603D03047' + 
				'0000010102060719F103F006D030EF01040008F007D049002C05F00885D5F009470000020201010527' + 
				'D030F103F00465005D036603305D046604305D026602305D02660258001D1D1D6801F103F002470000'
			) ); // Another magic bytes :-)
			ba.position = 0;
			ba.readBytes( CLASS_CODE );
			ba.length = 0;
			_initialized = true;
		}
		init();

		/**
		 * Creates a new FontLoader object. If you pass a valid URLRequest object to the FontLoader constructor,
		 * the constructor automatically calls the load() function.
		 * If you do not pass a valid URLRequest object to the FontLoader constructor,
		 * you must call the load() function or the stream will not load. 
		 * 
		 * @param request (default = null) — The URL that points to an external SWF file. 
		 * @param autoRegister — Register loaded fonts automatically.
		 */
		public function FontLoader(request:URLRequest = null, loaderContext:LoaderContext = null) {
			super( request, loaderContext );
			super.addEventListener(Event.COMPLETE, this.handler_complete, false, int.MAX_VALUE);
		}

		/**
		 * @private
		 */
		private var _libLoader:flash.display.Loader;

		/**
		 * @private
		 */
		private var _fontCount:uint;

		public function get name():String {
			return super.url;
		}

		public function get empty():Boolean {
			return this._fonts.length <= 0;
		}

		/**
		 * @private
		 */
		private const _fonts:Array = new Array();

		/**
		 * Returns an array of font classes, which you can use to register any extracted font.
		 */
		public function get fonts():Array {
			return this._fonts.slice();
		}

		/**
		 * Initiates loading of an external SWF file from the specified URL. You can load another swf file, when previous operation completed (or stream closed by user).
		 * 
		 * @param request:URLRequest — A URLRequest object specifying the URL to download. If the value of this parameter or the URLRequest.url property of the URLRequest object passed are null, Flash Player throws a null pointer error.  
		 * @param autoRegister — Register loaded fonts automatically.
		  * 
		 * @event complete:Event — Dispatched after data has loaded and parsed successfully.
		 * @event httpStatus:HTTPStatusEvent — If access is by HTTP, and the current Flash Player environment supports obtaining status codes, you may receive these events in addition to any complete or error event.
		 * @event ioError:IOErrorEvent — The load operation could not be completed.
		 * @event open:Event — Dispatched when a load operation starts.
		 * @event securityError:SecurityErrorEvent — A load operation attempted to retrieve data from a server outside the caller's security sandbox. This may be worked around using a policy file on the server. 
		 */
		public override function load(request:URLRequest):void {
			this._fonts.length = 0;
			this._fontCount = 0;
			super.load(request);
		}

		public function getResource(name:String):* {
			if (this._fonts) {
				for each (var font:Font in this._fonts) {
					if (font.fontName == name) return font;
				}
				
				return null;
			}
			
			return null;
		}

		public function getFont(fontName:String, fontStyle:String = 'regular'):Font {
			if (this._fonts) {
				for each (var font:Font in this._fonts) {
					if (font.fontName == fontName && font.fontStyle == fontStyle) return font;
				}
				
				return null;
			}
			
			return null;
		}

		/**
		 * @inheritDoc
		 */
		public function hasResource(name:String):Boolean {
			if ( this._fonts ) {
				for each (var font:Font in this._fonts) {
					if (font.fontName == name) return true;
				}
				return false;
			}
			
			return false;
		}

		/**
		 * @inheritDoc
		 */
		public function getResources():Array {
			const result:Array = new Array();
			for each ( var font:Font in this._fonts ) {
				result.push( font.fontName );
			}
			return result;
		}

		/**
		 * Closes the stream, causing any download of data to cease.
		 */
		public override function close():void {
			super.close();

			if (this._libLoader) {
				this._libLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.handler_libComplete);
				
				try {
					this._libLoader.close();
				} catch (error:Error) {}

				try {
					this._libLoader.unload();
				} catch (error:Error) {}

				this._libLoader = null;
			}
		}

		/**
		 * Registers all loaded fonts.
		 */
		public function registerFonts():void {
			for each (var font:Font in this._fonts) {
				Font.registerFont((font as Object).constructor);
			}
		}

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			var o:Object;
			var stringID:String;
			var id:uint;
			var fontID:uint;
			var tag:uint
			var length:uint;
			var pos:Number;
			var tempData:ByteArray;
			var fontSWF:ByteArray;
			var data:ByteArray = new SWFByteArray(this.loaderInfo.bytes);
			var fontData:Object = new Object();
			var classCodeLength:uint = FontLoader.CLASS_CODE.length;
			var context:LoaderContext;

			while (data.bytesAvailable) {
				tag = data.readUnsignedShort();
				id = tag >> 6;
				length = ((tag & 0x3F) == 0x3F) ? data.readUnsignedInt() : (tag & 0x3F);
				pos = data.position;
				
				switch (id) {
					case 13:
					case 48:
					case 62:
					case 73:
					case 75:
					case 88:
						fontID = data.readUnsignedShort();
						tempData = fontData[fontID] as ByteArray;
						
						if (!tempData) {
							tempData = new ByteArray();
							tempData.endian = Endian.LITTLE_ENDIAN;
							fontData[fontID] = tempData;
						}
						
						if ((tag & 0x3F) == 0x3F) {
							tempData.writeShort((id << 6) | 0x3F);
							tempData.writeUnsignedInt(length);
						} else {
							tempData.writeShort((id << 6) | (length & 0x3F));
						}
						
						tempData.writeShort(fontID);
						tempData.writeBytes(data, data.position, length - 2);
					break;
				}

				data.position = pos + length;
			}

			tempData = new ByteArray();
			tempData.endian = Endian.LITTLE_ENDIAN;
			tempData.writeBytes(FontLoader.SWF_HEADER);
			id = 0;

			for (o in fontData) {
				data = fontData[o] as ByteArray;
				
				if (data) {
					stringID = id.toString();
					while (stringID.length < 3) stringID = '0' + stringID;
					stringID = FontLoader.CLASS_NAME_PREFIX + stringID;
					tempData.writeShort(FontLoader.TAG_DO_ABC);
					tempData.writeUnsignedInt(10 + stringID.length + classCodeLength);
					tempData.writeUnsignedInt(0x002E0010);
					tempData.writeUnsignedInt(0x10000000);
					tempData.writeByte(stringID.length);
					tempData.writeUTFBytes(stringID);
					tempData.writeByte(0);
					tempData.writeBytes(FontLoader.CLASS_CODE);
					tempData.writeBytes(data);
					tempData.writeShort(FontLoader.TAG_SYMBOL_CLASS);
					tempData.writeUnsignedInt(5 + stringID.length);
					tempData.writeShort(1);
					tempData.writeShort(o as uint);
					tempData.writeUTFBytes(stringID);
					tempData.writeByte(0);
					id++;
				}
			}

			this._fontCount = id;

			if (this._fontCount) {
				super._status = 1;
				tempData.writeUnsignedInt(0x00000040);
				fontSWF = new ByteArray();
				fontSWF.endian = Endian.LITTLE_ENDIAN;
				fontSWF.writeUTFBytes('FWS');
				fontSWF.writeByte(9);
				fontSWF.writeUnsignedInt(tempData.length + 8);
				fontSWF.writeBytes(tempData);
				context = new LoaderContext();
				if ('allowLoadBytesCodeExecution' in context) context['allowLoadBytesCodeExecution'] = true;
				this._libLoader = new flash.display.Loader();
				this._libLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.handler_libComplete);
				this._libLoader.loadBytes(fontSWF, context);
				event.stopImmediatePropagation();
			} else {
				if (this._libLoader) {
					this._libLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.handler_libComplete);
					
					try {
						this._libLoader.close();
					} catch (error:Error) {}
	
					try {
						this._libLoader.unload();
					} catch (error:Error) {}
	
					this._libLoader = null;
				}
			}
		}

		/**
		 * @private
		 */
		private function handler_libComplete(event:Event):void {
			var id:String;
			var i:uint;
			var fontClass:Class;
			var font:Font;
			
			for (i = 0;i < this._fontCount;i++) {
				id = i.toString();
				while (id.length < 3) id = '0' + id;
				id = FontLoader.CLASS_NAME_PREFIX + id;
				
				if (this._libLoader.contentLoaderInfo.applicationDomain.hasDefinition(id)) {
					fontClass = this._libLoader.contentLoaderInfo.applicationDomain.getDefinition(id) as Class;
					font = new fontClass() as Font;
					
					if (font && font.fontName) { // Skip static fonts
						this._fonts.push(font);
					}
				}
			}

			if (this._libLoader) {
				this._libLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.handler_libComplete);
				
				try {
					this._libLoader.close();
				} catch (error:Error) {}

				try {
					this._libLoader.unload();
				} catch (error:Error) {}

				this._libLoader = null;
			}

			super._status = 2;
			super.removeEventListener( Event.COMPLETE, this.handler_complete );
			super.$dispatchEvent( event );
			super.addEventListener( Event.COMPLETE, this.handler_complete, false, int.MAX_VALUE );
		}

	}

}