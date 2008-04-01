package by.blooddy.gui.display {

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;

	public interface IUIControl extends IEventDispatcher, ILivePreview {

		function get name():String;
		function set name(value:String):void; 

		function get alpha():Number;
		function set alpha(value:Number):void;

		function get blendMode():String;
		function set blendMode(value:String):void;

		function get cacheAsBitmap():Boolean;
		function set cacheAsBitmap(value:Boolean):void; 

		function get filters():Array;
		function set filters(value:Array):void; 

		function get mask():DisplayObject;
		function set mask(value:DisplayObject):void; 

		function get scrollRect():Rectangle;
		function set scrollRect(value:Rectangle):void;

		function get parent():DisplayObjectContainer;
		function get root():DisplayObject;
		function get stage():Stage;

		function get scale9Grid():Rectangle;
		function set scale9Grid(value:Rectangle):void;

		function get transform():Transform;
		function set transform(value:Transform):void;

		function get visible():Boolean;
		function set visible(value:Boolean):void;

		function get rotation():Number;
		function set rotation(value:Number):void;

		function get x():Number;
		function set x(value:Number):void; 

		function get xPercent():Number;
		function set xPercent(value:Number):void;

		function get y():Number;
		function set y(value:Number):void; 

		function get yPercent():Number;
		function set yPercent(value:Number):void;

		function get width():Number;
		function set width(value:Number):void; 

		function get widthPercent():Number;
		function set widthPercent(value:Number):void;

		function get height():Number;
		function set height(value:Number):void; 

		function get heightPercent():Number;
		function set heightPercent(value:Number):void;

		function get scaleX():Number;
		function set scaleX(value:Number):void;

		function get scaleY():Number;
		function set scaleY(value:Number):void;

		function get mouseX():Number;

		function get mouseY():Number;

		function get center():Point;
		function set center(p:Point):void;

		function get layout():DisplayObjectContainer;

		function getBounds(targetCoordinateSpace:DisplayObject):Rectangle;
		function getRect(targetCoordinateSpace:DisplayObject):Rectangle ;

		function hitTestObject(obj:DisplayObject):Boolean;
		function hitTestPoint(x:Number, y:Number, shapeFlag:Boolean = false):Boolean;

		function localToGlobal(point:Point):Point;
		function globalToLocal(point:Point):Point;

	}

}