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
		private static const _TIMER:AutoTimer = new AutoTimer( 10*1E3 );

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

		public function takeIn(key:String, resource:Object, time:uint=3*60*1E3):void {
			if ( resource == null || time <= 0 ) throw new ArgumentError();
			var rcs:Vector.<ResourceContainer> = this._hash[ key ] as Vector.<ResourceContainer>;
			if ( !rcs ) this._hash[ key ] = rcs = new Vector.<ResourceContainer>();
			time += getTimer();
			for ( var i:int = rcs.length - 1; i >= 0; i-- ) {
				if ( rcs[ i ].time > time ) {
					i++;
					break;
				}
			}
			if ( this._length == 0 ) {
				_TIMER.addEventListener( TimerEvent.TIMER, this.handler_timer );
			}
			this._length++;
			rcs.splice( i, 0, new ResourceContainer( resource, time ) );
		}

		public function has(key:String!):Boolean {
			if ( key in this._hash ) {
				if ( this._hash[ key ].length > 0 ) {
					return true;
				}
			}
			return false;
		}

		public function takeOut(key:String):Object {
			var rcs:Vector.<ResourceContainer> = this._hash[ key ] as Vector.<ResourceContainer>;
			if ( rcs && rcs.length > 0 ) {
				this._length--;
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
				for ( i=0; i<l; i++ ) {
					rc = rcs[ i ];
					// если условие проходит, то всё что там лежит совсем не старое
					if ( rc.time <= time ) {
						i++;
						break;
					}
					dispose( rc.resource );
				}
				rcs.splice( 0, i );
				if ( i >= 1 ) { // минимум один элемент на удаление
					this._length -= i;
					if ( this._length == 0 ) {
						_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
					}
				}
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

	public function ResourceContainer(resource:Object, time:Number=0) {
		super();
		this.resource = resource;
		this.time = time;
	}

	public var resource:Object;

	public var time:Number;

}