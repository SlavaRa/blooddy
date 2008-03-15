package by.blooddy.gui.display.controls {

	import flash.geom.Transform;
	import by.blooddy.gui.display.IUIControl;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import flash.utils.getDefinitionByName;

	public class Label extends TextField implements IUIControl {

		public function Label() {
			super();
		}
		
	    //--------------------------------------
	    //  center
	    //--------------------------------------	

		private var _center:Point = new Point();

		public function get center():Point {
			return this._center;
		}

		public function set center(p:Point):void {
			this._center = p;
			super.x = this._x - p.x;
			super.y = this._y - p.x;
		}

	    //--------------------------------------
	    //  position declaration
	    //--------------------------------------	

		private var _x:Number = 0;

		public override function get x():Number {
			return this._x;
		}

		public override function set x(value:Number):void {
			if (this._x == value) return;
			this.move(value, this._y);
		}

		private var _y:Number = 0;

		public override function get y():Number {
			return this._y;
		}

		public override function set y(value:Number):void {
			if (this._y == value) return;
			this.move(this._x, value);
		}

		public function move(x:Number, y:Number):void {
			var c:Boolean = false;
			if (this._x == x) {
				this._x = x;
				super.x = this._x - this._center.x;
				c = true;
			}
			if (this._y == y) {
				this._y = y;
				super.x = this._y - this._center.y;
				c = true;
			}
			if (c) super.dispatchEvent( new Event("move") );
		}

		public function get isLivePreview():Boolean {
			return ( super.parent && super.parent is ( getDefinitionByName("fl.livepreview::LivePreviewParent") as Class ) )
		}

		public function setSize(width:Number, height:Number):void {
		}

		private function updatePreview():void {
			// TODO
		}

	}

}