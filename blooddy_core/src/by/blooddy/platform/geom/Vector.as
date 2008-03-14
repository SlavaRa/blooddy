////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 BlooDHounD.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.geom {

	import by.blooddy.platform.events.VectorEvent;

	import flash.geom.Point;

	import flash.events.EventDispatcher;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Транслируется, когда происходит изменение вектора.
	 * 
	 * @eventType				by.blooddy.platform.events.VectorEvent.VECTOR_CHANGED
	 */
	[Event(name="vectorChanged", type="by.blooddy.platform.events.VectorEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					vector
	 */
	public class Vector extends EventDispatcher implements IPoint {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function Vector(x:Number=0, y:Number=0) {
			super();
			this._point.x = x;
			this._point.y = y;
			this.updatePolar();
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
		//  direction
		//----------------------------------

		/**
		 * @private
		 */
		private var _direction:Number;

		public function get direction():Number {
			return this._direction;
		}

		/**
		 * @private
		 */
		public function set direction(value:Number):void {
			if (this._direction == value) return;
			this._direction = value;
			this.updateCoord();
		}

		//----------------------------------
		//  weight
		//----------------------------------

		/**
		 * @private
		 */
		private var _weight:Number;

		public function get weight():Number {
			return this._weight;
		}

		/**
		 * @private
		 */
		public function set weight(value:Number):void {
			if (this._weight == value) return;
			this._weight = value;
			this.updateCoord();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function add(v:Vector):void {
			this.setCoord( this._point.x + v._point.x, this._point.y + v._point.y );
		}

		public function subtract(v:Vector):void {
			this.setCoord( this._point.x - v._point.x, this._point.y - v._point.y );
		}

		public function equals(v:Vector):Boolean {
			return ( this === v || ( this._point.x == v._point.x && this._point.y == v._point.y ) );
		}

		public function clone():Vector {
			return new Vector( this._point.x, this._point.y );
		}

		public function toPoint():by.blooddy.platform.geom.Point {
			return new by.blooddy.platform.geom.Point(this._point.x, this._point.y);
		}

		public override function toString():String {
			return '(direction=' + this._direction +' weight=' + this._weight + ')';
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

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updatePolar():void {
			this._direction = Math.atan2( this._point.x, this._point.y );
			this._weight = this._point.length;
			super.dispatchEvent( new VectorEvent(VectorEvent.VECTOR_CHANGED) );
		}

		/**
		 * @private
		 */
		private function updateCoord():void {
			this._point = flash.geom.Point.polar( this._weight, this._direction );
			super.dispatchEvent( new VectorEvent(VectorEvent.VECTOR_CHANGED) );
		}

	}

}