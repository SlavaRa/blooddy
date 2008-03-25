package by.blooddy.platform.net {

	import flash.display.LoaderInfo;
	import flash.utils.ByteArray;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.Endian;
	import by.blooddy.abc.swf.Tag;

	public final class SWFInfo {

		public function SWFInfo(loaderInfo:LoaderInfo) {
			super();
			this._loaderInfo = loaderInfo;
			if ( this._loaderInfo.bytesLoaded < this._loaderInfo.bytesTotal ) {
				this._loaderInfo.addEventListener(Event.COMPLETE, this.handler_complete);
				this._loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.handler_ioError);
			} else {
				this._loaded = true;
			}
		}

		private var _loaded:Boolean = false;

		private var _loaderInfo:LoaderInfo;

		private var _compiledTime:Number;

		public function get compiledDate():Date {
			if (!this._compiledTime) this.parseBytes( Tag.COMPILED_INFO );
			return new Date( this._compiledTime );
		}

		private var _metadata:XML;

		public function get metadata():XML {
			if (!this._metadata) this.parseBytes( Tag.SWF_METADATA );
			return this._metadata.copy();
		}

		private var _lastPosition:uint = 21;

		private function parseBytes(...tagsID):void {
			if (!this._loaded) throw new Error();
			var bytes:ByteArray = this._loaderInfo.bytes;

			var endian:String = bytes.endian;
			var position:uint = bytes.position;

			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.position = this._lastPosition;

			var tag:Tag = new Tag();

			while (bytes.bytesAvailable && tagsID.indexOf( tag.id )<0 ) {

				tag.readExternal( bytes );

				switch (tag.id) {
					case Tag.COMPILED_INFO:
						bytes.position += 18;
						// как-то прочитать 64 бита
						var n1:uint = bytes.readUnsignedInt();
						var n2:uint = bytes.readUnsignedInt();
						this._compiledTime =  n2 * 0x100000000 + n1;
						break;
					case Tag.SWF_METADATA:
						this._metadata = new XML( bytes.readUTFBytes( tag.length - 1 ) );
						bytes.position += 1;
						break;
					default:
						bytes.position += tag.length; 
				}

			}

			// сохраним где остановились
			this._lastPosition = bytes.position;

			bytes.position = position;
			bytes.endian = endian;

		}

		private function handler_complete(event:Event):void {
			this._loaderInfo.removeEventListener(Event.COMPLETE, this.handler_complete);
			this._loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.handler_ioError);
			this._loaded = true;
		}

		private function handler_ioError(event:IOErrorEvent):void {
			this._loaderInfo.removeEventListener(Event.COMPLETE, this.handler_complete);
			this._loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.handler_ioError);
		}

	}

}