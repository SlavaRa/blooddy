////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					urlloader
	 * 
	 * @see						flash.net.URLLoader
	 */
	public class URLLoader extends LoaderBase {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected_load;
		
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
		public function URLLoader(request:URLRequest=null) {
			super( request );
		}

		//--------------------------------------------------------------------------
		//
		//  Includes
		//
		//--------------------------------------------------------------------------

		include "../../../../includes/override_EventDispatcher.as"

		//--------------------------------------------------------------------------
		//
		//  Variblies
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _stream:flash.net.URLStream;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  content
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _content:*;
		
		/**
		 * @copy			flash.net.URLLoader#data
		 */
		public function get content():* {
			return this._content;
		}
		
		//----------------------------------
		//  dataFormat
		//----------------------------------

		/**
		 * @private
		 */
		private var _dataFormat:String
		
		/**
		 * @copy			flash.net.URLLoader#dataFormat
		 */
		public function get dataFormat():String {
			return this._dataFormat;
		}

		/**
		 * @private
		 */
		public function set dataFormat(value:String):void {
			if ( this._dataFormat == value ) return;
			if ( !super.isIdle() ) throw new ArgumentError();
			this._dataFormat = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected_load override function $load(request:URLRequest):void {
			this._stream = this.create_stream();
			this._stream.load( request );
		}

		$protected_load override function $loadBytes(bytes:ByteArray):void {
			switch ( this._dataFormat ) {
				
				case URLLoaderDataFormat.TEXT:
				case URLLoaderDataFormat.VARIABLES:
					try {
						var s:String = ( bytes.length > 0
							?	bytes.readUTFBytes( bytes.length )
							:	''
						);
						this._content = ( this._dataFormat == URLLoaderDataFormat.VARIABLES
							?	new URLVariables( s )
							:	s
						);
					} catch ( e:Error ) {
						super.handler_complete( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, e.toString() ) );
						return; // выходим :(
					} finally {
						bytes.clear();
					}
					break;
				
				default:
					this._content = bytes;
					break;
			}
			
			if ( super.hasEventListener( Event.INIT ) ) {
				super.dispatchEvent( new Event( Event.INIT ) );
			}
			super.updateProgress( bytes.length, bytes.length );
			super.handler_complete( new Event( Event.COMPLETE ) );
		}

		/**
		 * @private
		 * очисщает данные
		 */
		$protected_load override function $unload():Boolean {
			var unload:Boolean = Boolean( this._content || this._stream );
			this.clear_stream();
			if ( this._content ) {
				if ( this._content is ByteArray ) {
					( this._content as ByteArray ).clear();
				}
				this._content = undefined;
			}
			return unload;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * создаёт URLStream для загрузки
		 */
		private function create_stream():flash.net.URLStream {
			var result:flash.net.URLStream = new flash.net.URLStream();
			result.addEventListener( Event.OPEN,						super.dispatchEvent );
			result.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
			if ( HTTP_RESPONSE_STATUS ) {
				result.addEventListener( HTTP_RESPONSE_STATUS,			super.dispatchEvent );
			}
			result.addEventListener( ProgressEvent.PROGRESS,			super.handler_progress );
			result.addEventListener( Event.COMPLETE,					this.handler_stream_complete );
			result.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_stream_error );
			result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_stream_error );
			return result;
		}
		
		/**
		 * @private
		 * очищает stream
		 */
		private function clear_stream():void {
			if ( this._stream ) {
				if ( this._stream.connected ) {
					this._stream.close();
				}
				this._stream.removeEventListener( Event.OPEN,							super.dispatchEvent );
				this._stream.removeEventListener( HTTPStatusEvent.HTTP_STATUS,			super.dispatchEvent );
				if ( HTTP_RESPONSE_STATUS ) {
					this._stream.removeEventListener( HTTP_RESPONSE_STATUS,				super.dispatchEvent );
				}
				this._stream.removeEventListener( ProgressEvent.PROGRESS,				super.handler_progress );
				this._stream.removeEventListener( Event.COMPLETE,						this.handler_stream_complete );
				this._stream.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_stream_error );
				this._stream.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_stream_error );
				this._stream = null;
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
		private function handler_stream_complete(event:Event):void {
			var input:ByteArray = new ByteArray();
			this._stream.readBytes( input );
			this.clear_stream();
			this.$loadBytes( input );
		}

		/**
		 * @private
		 */
		private function handler_stream_error(event:Event):void {
			this.clear_stream();
			super.handler_complete( event );
		}
		
	}

}