////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package platform.text {

	import flash.text.Font;

	import flash.net.URLRequest;
	import platform.utils.SWFByteArray;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.system.LoaderContext;

	import flash.events.Event;

	import platform.net.Loader;
	import flash.display.SWFVersion;
	import flash.events.ProgressEvent;

	/**
	 * @author					BlooDHounD, etc
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					fontloader, font
	 */
	public class FontLoader extends platform.net.Loader {

		//--------------------------------------------------------------------------
		//
		//  Private class constants
		//
		//--------------------------------------------------------------------------
	
		private static const FONT_2:uint = 48;
		private static const FONT_3:uint = 75;
		private static const FONT_ALIGN_ZONES:uint = 73;

		//--------------------------------------------------------------------------
		//
		//  Сlass variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Начало свфки.
		 */
		private static var swf_beginning:ByteArray = strintToBytes("7800055F00000FA000001F01004411080000004302FFFFFFBF150B00000001005363656E6520310000BF1495000000010000000010002E00000000060009466F6E74436C6173730A666C6173682E7465787404466F6E74064F626A6563740416011603180200040701020702040701050300000000000000000000000000010102080300010000000102010104010003000101040503D030470000010101050606D030D04900470000020201010413D0306500600330600230600258001D1D6801470000");

		/**
		 * @private
		 * Конец свфки.
		 */
		private static var swf_ending:ByteArray = strintToBytes("3F130E00000001000100466F6E74436C6173730040000000");

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Преобразовывает строку в массив байт.
		 */
		private static function strintToBytes(hexString:String):ByteArray {
			var bytes:ByteArray = new ByteArray();
			var l:uint = hexString.length;
			for (var i:uint = 0; i<l; i+=2) {
				bytes.writeByte( parseInt( hexString.substr(i, 2), 16 ) );
			}
			return bytes;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 *
		 * @param	request			Если надо, то сразу передадим и начнётся загрузка.
		 * @param	loaderContext	Если надо грузить, то возможно пригодится.
		 * @param	useStaticFonts	Цеплять ли статические шрифты.
		 */
		public function FontLoader(request:URLRequest=null, loaderContext:LoaderContext=null, useStaticFonts:Boolean=false) {
			this._useStaticFonts = useStaticFonts;
			super(request, loaderContext);
		}

		//--------------------------------------------------------------------------
		//
		//  Variblies
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Количесвто обработанных шрифтов.
		 */
		private var _loadedFonts:uint;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  fonts
		//----------------------------------

		/**
		 * @private
		 */
		private var _fonts:Array = null;

		[ArrayElementType("flash.text.Font")]
	    [Bindable("complete")]
		/**
		 * @keyword					fontloader.fonts, fonts
		 */
		public function get fonts():Array {
			return this._fonts.slice();
		}

		//----------------------------------
		//  useStaticFonts
		//----------------------------------

		/**
		 * @private
		 */
		private var _useStaticFonts:Boolean = false;

		/**
		 * Цеплять ли статические шрифты.
		 * 
		 * @keyword					fontloader.usestaticfonts, usestaticfonts
		 */
		public function get useStaticFonts():Boolean {
			return this._useStaticFonts;
		}

		/**
		 * @private
		 */
		public function set useStaticFonts(value:Boolean):void {
			if (this._useStaticFonts == value) return;
			this._useStaticFonts = value;
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
			this._fonts = null;
		}

		/**
		 * @private
		 * Получаем шрифты.
		 */
		private function getFonts():Array {

			var fonts:Array = new Array();

			var bytes:SWFByteArray = new SWFByteArray(this.loaderInfo.bytes);
			if (bytes.length > 18) {
				if (bytes.version >= 3) {
					bytes.position = 13; //( bytes.version >= 8 ? 0x18 : 0x12 );
					// массив готов к поиску шрифтов
					var swf:ByteArray;
					var tagBytes:uint;
					var tagID:int;
					var tagLength:uint;
					while (bytes.bytesAvailable >= 6) {
						tagBytes = bytes.readUnsignedShort();
						tagID = tagBytes >> 6;
						if (
							(tagBytes & 0x3F == 0x3F) && (
								(tagID == FONT_2 && bytes.version <= 7) ||
								(tagID == FONT_3 && bytes.version >= 8)
							)
						) {
							swf = this.getFontSWF(bytes, tagID);
							if (swf) fonts.push( swf );
						} else {
							bytes.position--;
						}
					}
				}

			}

			return fonts;
		}

		/**
		 * @private
		 * Получаем СВФ с фонтом.
		 */
		private function getFontSWF(bytes:ByteArray, type:uint):ByteArray {
			var currentPosition:uint = bytes.position;
			var definitionSize:uint = bytes.readUnsignedInt();

			var isValid:Boolean = false;

			var length:uint;

			if (bytes.bytesAvailable > definitionSize) {
				var definitionData:ByteArray = new ByteArray();
				definitionData.endian = Endian.LITTLE_ENDIAN;
				bytes.readBytes(definitionData, 0, definitionSize);
				definitionData[0] = 1;
				definitionData[1] = 0;
				length = definitionSize + 6;
				var fontInfo:uint = definitionData[2];
				var fontLanguage:uint = definitionData[3];
				var hasLayout:Boolean = Boolean(fontInfo >> 7);
				if (fontLanguage < 5 && (this._useStaticFonts || hasLayout)) {
					if (this._useStaticFonts && !hasLayout) {
						definitionData[2] += 0x80;
					}
					if (type == FONT_3) {
						var alignZonesSize:uint = 0;
						var alignZonesData:ByteArray = new ByteArray();
						alignZonesData.endian = Endian.LITTLE_ENDIAN;
						var tagBytes:uint = bytes.readShort();
						var tagID:uint = tagBytes >> 6;
						if ((tagBytes & 0x3F) == 0x3F && tagID == FONT_ALIGN_ZONES) {
							alignZonesSize = bytes.readUnsignedInt();
							if (bytes.bytesAvailable > alignZonesSize) {
								bytes.readBytes(alignZonesData, 0, alignZonesSize);
								isValid = true;
								length += alignZonesSize + 6;
							}
						}
					} else {
						isValid = true;
					}
				}
			}
			if (!isValid) { // не валидно
				bytes.position = currentPosition;
				return null;
			} else {
				// закреейтим СВФ
				var swf:ByteArray = new ByteArray();
				swf.endian = Endian.LITTLE_ENDIAN;
				swf.writeMultiByte(SWFByteArray.TAG_SWF, "x-ansi");
				swf.writeByte(SWFVersion.FLASH9);
				swf.writeUnsignedInt(length + 228);
				swf.writeBytes(swf_beginning);
				swf.writeShort( ( type << 6 ) + 0x3F );
				swf.writeUnsignedInt(definitionSize);
				swf.writeBytes(definitionData);
				if (type == FONT_3) {
					swf.writeShort( ( FONT_ALIGN_ZONES << 6 ) + 0x3F );
					swf.writeUnsignedInt(alignZonesSize);
					swf.writeBytes(alignZonesData);
				}
				swf.writeBytes(swf_ending);
				return swf;

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
		protected override function handler_complete(event:Event):void {
			this._fonts = new Array();
			var fonts:Array = this.getFonts();
			var loader:flash.display.Loader;
			this._loadedFonts = fonts.length;
			for each ( var swf:ByteArray in fonts ) {
				loader = new flash.display.Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.handler_completeFont);
				loader.loadBytes(swf, this.loaderContext);
			}
			if (this._loadedFonts<=0) super.handler_complete(event);
		}

		/**
		 * @private
		 * Созданный шрифт загрузился.
		 */
		private function handler_completeFont(event:Event):void {
			var info:LoaderInfo = event.target as LoaderInfo;
			info.removeEventListener(Event.COMPLETE, this.handler_completeFont);
			if (info.applicationDomain.hasDefinition("FontClass")) {
				var FontClass:Class = info.applicationDomain.getDefinition("FontClass") as Class;
				var font:Font = new FontClass();
				this._fonts.push(font);
			}
			info.loader.unload();
			if (--this._loadedFonts<=0) super.handler_complete(event);
		}

	}

}