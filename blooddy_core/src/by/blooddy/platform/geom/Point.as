package by.blooddy.platform.geom {

	import by.blooddy.platform.events.PointEvent;

	import flash.geom.Point;

	import flash.events.EventDispatcher;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Транслируется, когда происходит изменение точки.
	 * 
	 * @eventType				by.blooddy.platform.events.PointEvent.POINT_CHANGED
	 */
	[Event(name="pointChanged", type="by.blooddy.platform.events.PointEvent")]

	public class Point extends EventDispatcher implements IPoint {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function polar(length:Number, angle:Number):Point {
			var p:Point = new Point();
			p.setPolar(length, angle);
			return p;
		} 

		public static function getDistance(p1:IPoint, p2:IPoint):Number {
			var d1:Number, d2:Number;
			if ( p1 is Point ) d1 = ( p1 as Point )._length;
			else if ( p1 is Vector ) d1 = ( p1 as Vector ).weight;
			else d1 = Math.sqrt( p1.x * p1.x + p1.y * p1.y );
			if ( p2 is Point ) d2 = ( p2 as Point )._length;
			else if ( p2 is Vector ) d2 = ( p2 as Vector ).weight;
			else d2 = Math.sqrt( p2.x * p2.x + p2.y * p2.y );
			return Math.abs( d1 - d2 );
		}

		public static function interpolate(p1:Point, p2:Point, f:Number):Point {
			var p:Point = p1.clone();
			p.offset( ( p2.x - p1.x ) * f, ( p2.y - p1.y ) * f );
			return p;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function Point(x:Number=0.0, y:Number=0.0) {
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
		private var _point:flash.geom.Point = new flash.geom.Point();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  x
		//----------------------------------

		public function get x():Number {
			return this._point.x;
		}

		/**
		 * @private
		 */
		public function set x(value:Number):void {
			if (this._point.x == value) return;
			this._point.x = value;
			this.updatePolar();
		}

		//----------------------------------
		//  y
		//----------------------------------

		public function get y():Number {
			return this._point.y;
		}

		/**
		 * @private
		 */
		public function set y(value:Number):void {
			if (this._point.y == value) return;
			this._point.y = value;
			this.updatePolar();
		}

		//----------------------------------
		//  angle
		//----------------------------------

		/**
		 * @private
		 */
		private var _angle:Number;

		public function get angle():Number {
			return this._angle;
		}

		/**
		 * @private
		 */
		public function set angle(value:Number):void {
			if (this._angle == value) return;
			this._angle = value;
			this.updateCoord();
		}

		//----------------------------------
		//  length
		//----------------------------------

		/**
		 * @private
		 */
		private var _length:Number;

		public function get length():Number {
			return this._length;
		}

		/**
		 * @private
		 */
		public function set length(value:Number):void {
			if (this._length == value) return;
			this._length = value;
			this.updateCoord();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function equals(p:IPoint):Boolean {
			return ( this === p || ( this._point.x == p.x && this._point.y == p.y ) );
		} 

		public function add(p:IPoint):Point {
			return new Point( this._point.x + p.x, this._point.y + p.y );
		}

		public function subtract(p:IPoint):Point {
			return new Point( this._point.x - p.x, this._point.y - p.y );
		}

		public function offset(dx:Number, dy:Number):void {
			this.setCoord( this._point.x + dx, this._point.y + dy );
		} 

		public function clone():Point {
			return new Point( this._point.x, this._point.y );
		}

		public override function toString():String {
			return '(x=' + this._point.x +' y=' + this._point.y + ')';
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected function setCoord(x:Number, y:Number):void {
			if (this._point.x==x && this._point.y==y) return;
			this._point.x = x;
			this._point.y = y;
			this.updatePolar();
		}

		/**
		 * @private
		 */
		protected function setPolar(length:Number, angle:Number):void {
			if (this._length==x && this._angle==angle) return;
			this._length = length;
			this._angle = angle;
			this.updateCoord();
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updatePolar():void {
			this._angle = Math.atan2( this._point.x, this._point.y );
			this._length = this._point.length;
			super.dispatchEvent( new PointEvent(PointEvent.POINT_CHANGED) );
		}

		/**
		 * @private
		 */
		private function updateCoord():void {
			this._point = flash.geom.Point.polar( this._length, this._angle );
			super.dispatchEvent( new PointEvent(PointEvent.POINT_CHANGED) );
		}

	}

}