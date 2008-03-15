package by.blooddy.gui.managers {

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class FocusManager extends EventDispatcher implements IFocusManager {

		public static function getFocusManager( container:DisplayObjectContainer ):FocusManager {
			var focusManager:FocusManager = _HASH[ container ];
			if (!focusManager) {
				constructorLock = false;
				_HASH[ container ] = focusManager = new FocusManager( container );
				constructorLock = true;
			}
			return focusManager;
		}

		private static var constructorLock:Boolean = true;

		private static const _HASH:Dictionary = new Dictionary(true);

		public function FocusManager( container:DisplayObjectContainer ) {
			super();
			if ( constructorLock ) throw new ArgumentError();
			if ( !container ) throw new ArgumentError();

			this._container = container;
			if (this._container.stage) {
				this.init();
			} else {
				this._container.addEventListener(Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MAX_VALUE, true);
			}

			if ( this._container is FocusManager ) this._instance = this._container as FocusManager;
			else this._instance = this;
		}

		private var _container:DisplayObjectContainer;

		private var _instance:IFocusManager;

		private function init():void {
			var list:Array = this.getFocusElementList( this._container );
			this._container.addEventListener(Event.ADDED, this.handler_added, false, int.MAX_VALUE, true);
			this._container.addEventListener(Event.REMOVED, this.handler_removed, false, int.MAX_VALUE, true);
		}

		private function getFocusElementList(container:DisplayObjectContainer):Array {
			var result:Array = new Array();
			var index:uint = container.numChildren;
			var child:DisplayObject;
			while (index--) {
				child = container.getChildAt(index);
				if ( child is IFocusElement && ( child as IFocusElement ).focusManager === this._instance ) result.push( child );
				if ( child is DisplayObjectContainer && !( child is IFocusManager ) ) {
					result.push.apply( result, this.getFocusElementList( child as DisplayObjectContainer ) );
				}
			}
			return result;
		}

		private function handler_added(event:Event):void {
			if ( ( event.target is IFocusElement ) && ( event.target as IFocusElement ).focusManager === this._instance ) {
				
			}
		}

		private function handler_removed(event:Event):void {
			if ( ( event.target is IFocusElement ) && ( event.target as IFocusElement ).focusManager === this._instance ) {
			}
		}

		private function handler_addedToStage(event:Event):void {
			this.init();
		}

	}

}