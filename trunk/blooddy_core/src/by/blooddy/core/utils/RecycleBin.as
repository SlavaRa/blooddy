////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import by.blooddy.core.utils.time.AutoTimer;
	import by.blooddy.core.utils.time.getTimer;
	
	import flash.events.TimerEvent;

	/**
	 * Сборщик всякого дерьма.
	 * Что бы не создавать дополнительные экземпляры классов, если те часто удаляются и добавляются.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					recycle, bin, recyclebin
	 */
	public class RecycleBin {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _TIMER:AutoTimer = new AutoTimer( 30*1E3 );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function RecycleBin() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Varaibles
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _hash:Object = new Object();

		/**
		 * @private
		 */
		private var _length:uint = 0;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function has(key:String!):Boolean {
			return ( key in this._hash && this._hash[ key ].length > 0 );
		}

		public function takeIn(key:String, resource:*, time:uint=3*60*1E3):void {
			if ( resource == null || time <= 0 ) throw new ArgumentError();
			var rcs:Vector.<ResourceContainer> = this._hash[ key ] as Vector.<ResourceContainer>;
			if ( !rcs ) this._hash[ key ] = rcs = new Vector.<ResourceContainer>();
			time += getTimer();
			var l:uint = rcs.length;
			for ( var i:int=0; i < l; ++i ) {
				if ( rcs[ i ].time <= time ) break;
			}
			rcs.splice( i, 0, new ResourceContainer( resource, time ) );
			if ( this._length == 0 ) {
				_TIMER.addEventListener( TimerEvent.TIMER, this.handler_timer );
			}
			++this._length;
		}

		public function takeOut(key:String):* {
			var rcs:Vector.<ResourceContainer> = this._hash[ key ] as Vector.<ResourceContainer>;
			if ( rcs && rcs.length > 0 ) {
				--this._length;
				if ( this._length == 0 ) {
					_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
				}
				return rcs.pop().resource;
			}
			return null;
		}

		/**
		 */
		public function clear(pattern:*=null):void {
			var key:String;
			var rc:ResourceContainer;
			if ( pattern ) {
				for ( key in this._hash ) {
					if ( key.search( pattern ) >= 0 ) {
						for each ( rc in this._hash[ key ] ) {
							dispose( rc.resource );
						}
						this._length -= this._hash[ key ].length;
						delete this._hash[ key ];
					}
				}
				if ( this._length == 0 ) {
					_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
				}
			} else {
				for ( key in this._hash ) {
					for each ( rc in this._hash[ key ] ) {
						dispose( rc.resource );
					}
					delete this._hash[ key ];
				}
				this._length = 0;
				_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
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
		private function handler_timer(event:TimerEvent):void {
			var time:uint = getTimer() + 1E3;
			var rcs:Vector.<ResourceContainer>;
			var i:int, l:uint;
			var rc:ResourceContainer;
			for each ( rcs in this._hash ) {
				l = rcs.length;
				for ( i=0; i<l; ++i ) {
					rc = rcs[ i ];
					// если условие проходит, то всё что там лежит совсем не старое
					if ( rc.time > time ) break;
					dispose( rc.resource );
				}
				if ( i > 0 ) { // минимум один элемент на удаление
					rcs.splice( 0, i );
					this._length -= i;
				}
			}
			if ( this._length == 0 ) {
				_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
			}
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: EventContainer
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 */
internal final class ResourceContainer {

	public function ResourceContainer(resource:*, time:Number=0) {
		super();
		this.resource = resource;
		this.time = time;
	}

	public var resource:*;

	public var time:Number;

}