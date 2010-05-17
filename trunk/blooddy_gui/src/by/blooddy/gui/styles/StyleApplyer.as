////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.styles {

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					15.05.2010 16:46:29
	 */
	public class StyleApplyer {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function StyleApplyer() {
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _hash:Dictionary = new Dictionary( true );

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function addStyleListener(target:DisplayObject):void {
			if ( target in this._hash ) return;
			// проверяем нашего папу
			var p:DisplayObject = target;
			while ( p = p.parent ) {
				if ( p in this._hash ) {
					throw new ArgumentError();
				}
			}
			// проверяем наших детей
			for ( var o:Object in this._hash ) {
				if (
					o is DisplayObjectContainer &&
					( o as DisplayObjectContainer ).contains( target )
				) {
					throw new ArgumentError();
				}
			}
			// всё ок
			this._hash[ target ] = true;
			target.addEventListener( Event.ADDED, this.handler_added, false, int.MIN_VALUE, true );
		}

		public function removeStyleListener(target:DisplayObject):void {
			if ( !( target in this._hash ) ) return;
			delete this._hash[ target ];
			target.removeEventListener( Event.ADDED, this.handler_added );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function apply(target:DisplayObject):void {
			// TODO:
			if ( target is DisplayObjectContainer ) {
				var cont:DisplayObjectContainer = target as DisplayObjectContainer;
				var l:uint = cont.numChildren;
				var c:DisplayObject;
				for ( var i:uint = 0; i<l; i++ ) {
					c = cont.getChildAt( i );
					if ( c ) this.apply( c );
				}
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
		private function handler_added(event:Event):void {
			this.apply( event.target as DisplayObject );
		}

	}

}