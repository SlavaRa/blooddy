package by.blooddy.platform.managers {

	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public final class DragManager {

		private static const _dragInfo:DragInfo = DragInfo.getNewInstance();

		public static function get dragInfo():DragInfo {
			return _dragInfo;
		}

		public static function doDrag(dragSource:DisplayObject, rescale:Boolean=false, offset:Point=null, bounds:Rectangle=null):void {
			_dragInfo.doDrag( dragSource, rescale, offset, bounds );
		}

	}

}