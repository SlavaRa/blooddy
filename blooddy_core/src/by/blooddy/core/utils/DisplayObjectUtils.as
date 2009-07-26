package by.blooddy.core.utils {

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.SimpleButton;
	import flash.geom.Point;
	import flash.text.TextField;

	public final class DisplayObjectUtils {

		public static function toString(obj:DisplayObject):String {
			var arr:Array = new Array();
			do {
				if (obj.name)	arr.unshift(obj.name);
				else			arr.unshift(obj.toString());
			} while( obj = obj.parent );
			return arr.join(".");
		}
		
		/**
		 * @private
		 */
		private static function filter(objects:Array):void {
			var currentTarget:InteractiveObject;
			var currentParent:DisplayObject;
			var i:int = objects.length;
		
			while (i--) {
				currentParent = objects[i];
		
				while (currentParent) {
					if (currentTarget && (currentParent is SimpleButton || currentParent is TextField)) {
						currentTarget = null;
					} else if (currentTarget && !(currentParent as DisplayObjectContainer).mouseChildren) {
						currentTarget = null;
					}
					
					if (!currentTarget && currentParent is InteractiveObject && (currentParent as InteractiveObject).mouseEnabled) {
						currentTarget = (currentParent as InteractiveObject);
					}
					
					currentParent = currentParent.parent;
				}
				
//				trace('not filtered:', i, objects[i].name,  objects[i]);
				objects[i] = currentTarget;
//				trace('filtered:', i, currentTarget.name, currentTarget);
				currentTarget = null;
			}
			
		}
		
		public static function getDropTarget(container:DisplayObjectContainer, point:Point, objects:Array = null):DisplayObject {
			if (!objects) {
				objects = container.getObjectsUnderPoint(point);
				filter(objects);
			}
			
			var o:DisplayObject;
			var doc:DisplayObjectContainer;
			var i:uint;
			
			while (objects.length) {
				o = objects.pop() as DisplayObject;
				if (!(o is DisplayObjectContainer)) return o;
				doc = o as DisplayObjectContainer;
				
				if (doc !== container) {
					for (i = 0;i < objects.length;i++) {
						if (!doc.contains(objects[i])) objects.splice(i--, 1);
					}
					
					return DisplayObjectUtils.getDropTarget(doc, point, objects);
				}
			}
			
			return container;
		}

	}
}
