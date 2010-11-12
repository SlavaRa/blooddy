////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					08.11.2010 16:53:47
	 */
	public class ZIPLoader extends LoaderBase {
		
		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		internal namespace $internal_zip;
		
		use namespace $protected_load;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function ZIPLoader(request:URLRequest=null) {
			super( request );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variblies
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _stream:flash.net.URLStream;
		
		/**
		 * @private
		 */
		private var _input:ByteArray;
		
		//--------------------------------------------------------------------------
		//
		//  Internal methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * метод хак, существует для того что бы HeuristicLoader просто сделал
		 * перенаправление а не начинал загрузку заново
		 */
		$internal_zip function $load(input:ByteArray, stream:flash.net.URLStream=null, url:String=null):void {
			this.start();
			if ( stream ) {
				this.assign_stream( stream );
				this._stream = stream;
				this._input = input;
			} else {
				this.$loadBytes( input );
			}
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
		}

		$protected_load override function $unload():Boolean {
			var unload:Boolean = Boolean( this._stream );
			this.clear_stream();
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
			this.assign_stream( result );
			return result;
		}
		
		/**
		 * @private
		 * создаёт URLStream для загрузки
		 */
		private function assign_stream(stream:flash.net.URLStream):void {
			stream.addEventListener( Event.OPEN,						super.dispatchEvent );
			stream.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
			if ( _HTTP_RESPONSE_STATUS ) {
				stream.addEventListener( _HTTP_RESPONSE_STATUS,			super.dispatchEvent );
			}
			stream.addEventListener( ProgressEvent.PROGRESS,			this.handler_stream_progress );
			stream.addEventListener( Event.COMPLETE,					this.handler_stream_complete );
			stream.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_stream_error );
			stream.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_stream_error );
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
				if ( _HTTP_RESPONSE_STATUS ) {
					this._stream.removeEventListener( _HTTP_RESPONSE_STATUS,			super.dispatchEvent );
				}
				this._stream.removeEventListener( ProgressEvent.PROGRESS,				this.handler_stream_progress );
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
		}
		
		/**
		 * @private
		 */
		private function handler_stream_error(event:ErrorEvent):void {
			this.clear_stream();
			super.completeHandler( event );
		}

		/**
		 * @private
		 */
		private function handler_stream_progress(event:ProgressEvent):void {
			// TODO: parse
			super.progressHandler( event );
		}

	}
	
}