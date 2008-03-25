package by.blooddy.gui.display.controls {

	import by.blooddy.gui.display.IUIControl;
	import by.blooddy.gui.utils.UIControlInfo;
	import by.blooddy.platform.utils.ObjectInfo;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;

	[DefaultProperty("text")]
	/**
	 */
	public class Label extends TextField implements IUIControl {

		public function Label() {
			super();
			this._info = UIControlInfo.getInfo( this );

			// класс обстрактный
			if ( this._info.hasMetadata("AbstractControl", ObjectInfo.META_SELF) ) {
				throw new ArgumentError();
			}

		}

		private var _info:UIControlInfo;
		
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

	    //--------------------------------------
	    //  livepreview declaration
	    //--------------------------------------	

		public function get isLivePreview():Boolean {
			var C:Class;
			if ( super.parent ) {
				// flash
				C = getDefinitionByName("fl.livepreview::LivePreviewParent") as Class;
				if ( C && super.parent is C ) return true;
				// flex
				C = getDefinitionByName("mx.core::UIComponentGlobals") as Class;
				if ( C && "designMode" in C && C.designMode ) return true;
			}
			return false;
		}

		public function setSize(width:Number, height:Number):void {
		}

	}

}