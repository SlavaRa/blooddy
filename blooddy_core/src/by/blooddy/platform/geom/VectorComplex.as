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
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					vectorcomplex, vector, complex
	 */
	public class VectorComplex extends Vector {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

//		public static function addition(...vectors):VectorComplex {
//			var vector:VectorComplex = new VectorComplex();
//			for each (var o:Object in vectors) {
//				if ( o is Vector ) {
//					vector.addVector( o as Vector );
//				} else {
//					throw new ArgumentError();
//				}
//			}
//			return vector;
//		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function VectorComplex() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		private const _composite:Array = new Array();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public override function set x(value:Number):void {
			throw new IllegalOperationError();
		}

		public override function set y(value:Number):void {
			throw new IllegalOperationError();
		}

		public override function set direction(value:Number):void {
			throw new IllegalOperationError();
		}

		public override function set weight(value:Number):void {
			throw new IllegalOperationError();
		}

		private var _modifier:Number = 1;

		public function get modifier():Number {
			return this._modifier;
		}

		public function set modifier(value:Number):void {
			if (this._modifier == value) return;
			var x:Number = super.x / this._modifier;
			var y:Number = super.y / this._modifier;
			this._modifier = value;
			super.setCoord( x * this._modifier, y * this._modifier );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function addVector(v:Vector):void {
			if (this._composite.indexOf(v)>=0) return;
			v.addEventListener(VectorEvent.VECTOR_CHANGED, this.handler_vectorChanged, false, int.MAX_VALUE);
			this._composite.push(v);
			super.setCoord(
				super.x + v.x * this._modifier,
				super.y + v.y * this._modifier
			);
		}

		public function removeVector(v:Vector):void {
			var index:uint = this._composite.indexOf(v);
			if (index<0) return;
			v.removeEventListener(VectorEvent.VECTOR_CHANGED, this.handler_vectorChanged);
			this._composite.splice(index, 1);
			super.setCoord(
				super.x - v.x * this._modifier,
				super.y - v.y * this._modifier
			);
		}

		public function hasVector(v:Vector):Boolean {
			return this._composite.indexOf(v)>=0;
		}

		public override function clone():Vector {
			var v:VectorComplex = new VectorComplex();
			v._modifier = this._modifier;
			v._composite.push.apply( v._composite, this._composite );
			v.update();
			return v;
		}

		public function toVector():Vector {
			return super.clone();
		}

		public override function add(v:Vector):void {
			throw new IllegalOperationError();
		}

		public override function subtract(v:Vector):void {
			throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		private function update():void {
			var x:Number = 0;
			var y:Number = 0;
			for each (var v:Vector in this._composite) {
				x += v.x;
				y += v.y;
			}
			x *= this._modifier;
			y *= this._modifier;
			super.setCoord(x, y);
		}

		//--------------------------------------------------------------------------
		//
		//  Events handlers
		//
		//--------------------------------------------------------------------------

		private function handler_vectorChanged(event:VectorEvent):void {
			this.update();
		}

	}

}