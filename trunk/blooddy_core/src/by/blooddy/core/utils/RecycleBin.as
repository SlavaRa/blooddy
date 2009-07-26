////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

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

		public function takeIn(key:String!, resource:Object, time:uint=3*60*1E3):void {
			if ( resource == null || time <= 0 ) throw new ArgumentError();
			var resources:Vector.<ResourceContainer> = this._hash[ key ] as Vector.<ResourceContainer>;
			if ( !resources ) this._hash[ key ] = resources = new Vector.<ResourceContainer>();
			if ( resources.indexOf( resource ) >= 0 ) return;
			time += getTimer();
			for ( var i:uint = resources.length - 1; i >= 0; i-- ) {
				if ( resources[ i ].time > time ) {
					i++;
					break;
				}
			}
			if ( this._length == 0 ) {
				_TIMER.addEventListener( TimerEvent.TIMER, this.handler_timer );
			}
			this._length++;
			resources.splice( i, 0, new ResourceContainer( resource, time ) );
		}

		public function has(key:String!):Boolean {
			if ( key in this._hash ) {
				return ( this._hash[ key ].length > 0 );
			}
			return false;
		}

		public function takeOut(key:String!):Object {
			var resources:Vector.<ResourceContainer> = this._hash[ key ] as Vector.<ResourceContainer>;
			if ( resources && resources.length > 0 ) {
				this._length--;
				if ( this._length == 0 ) {
					_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
				}
				return resources.pop();
			}
			return null;
		}

		/**
		 */
		public function clear(pattern:*):void {
			var key:String;
			if ( pattern ) {
				for ( key in this._hash ) {
					if ( key.search( pattern ) >= 0 ) {
						this._length -= this._hash[ key ].length;
						delete this._hash[ key ];
					}
				}
			} else {
				for ( key in this._hash ) {
					delete this._hash[ key ];
				}
				this._length = 0;
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

			var resources:Vector.<ResourceContainer>;
			var i:int, l:uint;

			for each ( resources in this._hash ) {
				l = resources.length;
				for ( i=0; i<l; i++ ) {
					// если условие проходит, то всё что там лежит совсем не старое
					if ( resources[i].time <= time ) break;
				}
				if ( i >= 1 ) { // минимум один элемент на удаление
					this._length -= i;
					if ( this._length == 0 ) {
						_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
					}
					resources.splice( 0, i );
				}
			}
		}

	}

}

/**
 * @private
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