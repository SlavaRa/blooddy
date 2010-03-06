////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.parsers {

	import by.blooddy.core.errors.getErrorMessage;
	import by.blooddy.core.net.loading.ILoadable;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	//--------------------------------------
	//  Implements events: ILoadable
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
	 * Класс для парсинга больших данных. В несколько этапов, что бы
	 * сохранить ресурсы.
	 * 
	 * @author			BlooDHounD
	 * @version			1.0
	 * @langversion		3.0
	 * @playerversion	Flash 9
	 * 
	 * @keyword			bytesparser, parser, bytes
	 */
	public class BytesParser extends EventDispatcher implements ILoadable {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BytesParser() {
			super();
			this._timer = new Timer(10);
			this._timer.addEventListener(TimerEvent.TIMER, this.handler_timer);
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _timer:Timer;

		/**
		 * @private
		 * Запущен ли сейчас парсер.
		 */
		private var _isProgress:Boolean;

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoadable
		//
		//--------------------------------------------------------------------------

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
		public final function get loaded():Boolean {
			return this._loaded;
		}

		//----------------------------------
		//  bytesLoaded
		//----------------------------------

	    [Bindable( "progress" )]
		/**
		 * @inheritDoc
		 */
		public final function get bytesLoaded():uint {
			return this._bytes.position;
		}

		//----------------------------------
		//  bytesTotal
		//----------------------------------

	    [Bindable( "complete" )]
		/**
		 * @inheritDoc
		 */
		public final function get bytesTotal():uint {
			return this._bytes.length;
		}

		public function get progress():Number {
			return 0; // TODO
		}
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  delay
		//----------------------------------

		/**
		 * @copy					flash.utils.Timer#delay
		 */
		public final function get delay():Number {
			return this._timer.delay;
		}

		/**
		 * @private
		 */
		public final function set delay(value:Number):void {
			this._timer.delay = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _bytes:ByteArray;

		/**
		 * 
		 */
		protected final function get bytes():ByteArray {
			return this._bytes;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Стартануть парсинг.
		 * 
		 * @param	bytes			Объект, который надо распарсить.
		 * 
		 * @keyword					bytesparser.loadbytes, loadbytes
		 */
		public final function loadBytes(bytes:ByteArray):void {
			this.clearVariables();
			this._bytes = bytes;
			this.parser_start();
			this._timer.start();
			this.dispatchEvent( new Event(Event.OPEN) );
		}

		/**
		 * Остановить парсинг.
		 * 
		 * @keyword					bytesparser.close, close
		 */
		public final function close():void {
			if ( this._isProgress ) throw new IOError( getErrorMessage( 2029 ), 2029 );
			this.parser_stop();
			this._timer.stop();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Функа вызывается, когда начинается парсинг объекта.
		 * 
		 * @keyword					bytesparser.parser_start, parser_start
		 * 
		 * @see						#loadbytes()
		 * @see						#parser_action()
		 * @see						#parser_stop()
		 */
		protected virtual function parser_start():void {
			// must be everrited
		}

		/**
		 * Функа обрабатывается, когда происходит шаг парсинга. Обрабатывается один пакет данных.
		 * Контролировать количество обрабатываемых данных должна сама функция.
		 * 
		 * Что бы сохраниться отпарсеные данные, нужно использовать методы IDataOutput. 
		 * 
		 * @return					Возвращает true, если парсигн ещё не окончен, и false, если всё готово.
		 * 
		 * @keyword					bytesparser.parser_action, parser_action
		 * 
		 * @see						#parser_start()
		 */
		protected virtual function parser_action():Boolean {
			// must be everrited
			return false;
		}

		/**
		 * Функа вызывается при окончании/остановке парсинга.
		 * 
		 * @keyword					bytesparser.parser_stop, parser_stop
		 * 
		 * @see						#parser_start()
		 * @see						#parser_stop()
		 */
		protected virtual function parser_stop():void {
			// must be everrited
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Чистит переменные
		 */
		private function clearVariables():void {
			try {
				this.close();
			} catch ( e:Error ) {
			}
			this._bytes = new ByteArray();
			this._loaded = false;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Срабатывает, по таймаут, для отработки цикличного парсинга.
		 */
		private function handler_timer(event:TimerEvent):void {
			this._isProgress = this.parser_action();
			this.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this.bytesLoaded, this.bytesTotal ) );
			if ( !this._isProgress ) {
				this.parser_stop();
				this._timer.stop();
				this._loaded = true;
				this.dispatchEvent( new Event( Event.COMPLETE ) );
			}
		}

	}

}