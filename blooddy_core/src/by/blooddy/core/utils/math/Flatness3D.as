////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////


package by.blooddy.core.utils.math {
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * @author					andreus, bloodhound
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	
	public class Flatness3D {
		
		//точки
		/**
		 * @private
		 */
		private var _p1:Point;
		/**
		 * @private
		 */ 
		private var _p2:Point;
		/**
		 * @private
		 */
		private var _p3:Point;
		/**
		 * @private
		 */
		private var _p4:Point;
		
		
		// линии образующее поле
		/**
		 * @private
		 */
		private var _l1:Line;
		/**
		 * @private
		 */
		private var _l2:Line;
		/**
		 * @private
		 */ 
		private var _l3:Line;
		/**
		 * @private
		 */ 
		private var _l4:Line;
		
		//количество клеток вер/гор
		/**
		 * @private
		 */
		private var _xCells:uint;
		/**
		 * @private
		 */
		private var _yCells:uint;
		
		/**
		 * @private
		 */
		private var _px:Point;
		/**
		 * @private
		 */
		private var _py:Point;
		/**
		 * @private
		 */
		private var _dpxa1:Number
		/**
		 * @private
		 */
		private var _dpxa2:Number
		/**
		 * @private
		 */
		private var _dpya1:Number
		/**
		 * @private
		 */
		private var _dpya2:Number;
		/**
		 * @private
		 */
		private var _quadrangle:Array;

		
		public function Flatness3D(xCells:uint, yCells:uint, p1:Point, p2:Point, p3:Point, p4:Point) {
			super();
			this._xCells = xCells || 1;
			this._yCells = yCells || 1;
			this._p1 = p1;
			this._p2 = p2;
			this._p3 = p3;
			this._p4 = p4;

			this.init();
		}
		
		//поиск индекса по координатам
		public function getIndexUnderPoint(point:Point):int {
			// x y ячейкм
			var celX:Number = this._xCells-(this._xCells*(Math.atan2(this._py.x-point.x, this._py.y-point.y)+Math.PI-this._dpya1)/(this._dpya2-this._dpya1));
			var celY:Number = this._yCells-(this._yCells*(Math.atan2(this._px.x-point.x, this._px.y-point.y)+Math.PI-this._dpxa1)/(this._dpxa2-this._dpxa1));
			//если за пределами поля выходим
			if ((celY<0) || (celY>this._yCells) || (celX<0) || (celX>this._xCells)) {
				return -1;
			}
			return ((Math.floor(celX)+Math.floor(celY)*this._xCells));
		}
		
		//поиск ячейки по координатам
		public function getQuadrangleUnderPoint(point:Point):Array {
			var index:int = this.getIndexUnderPoint( point );
			
			if (index==1) return null;

			return this._quadrangle[index];
		}
		
		//поиск ячейки по координатам
		public function getQuadrangleByIndex(index:int):Array {
			return this._quadrangle[index];
		}
		
		/**
		 * @private
		 */
		private function init():void {
			var i:int;
			var j:int;
			this._quadrangle = new Array();
			this._l1 = this.getLine(this._p1, this._p2);
			this._l3 = this.getLine(this._p4, this._p3);
			this._px = this.getCross(this._l1, this._l3);
			// точка искажения для Y коордлинат
			this._dpxa1 = Math.atan2(this._px.x-this._p4.x, this._px.y-this._p4.y)+Math.PI;
			this._dpxa2 = Math.atan2(this._px.x-this._p1.x, this._px.y-this._p1.y)+Math.PI;
			// дельта тангенса угла.
			var da:Number = (this._dpxa2-this._dpxa1)/this._yCells;
			//массив линий по х
			var pxArr:Array = new Array();
			for (i = this._yCells; i>=0; i--) {
				pxArr.push(this.getLine(this._px, new Point(this._px.x+Math.sin(this._dpxa1+i*da), this._px.y+Math.cos(this._dpxa1+i*da) )));
			}
			this._l4 = this.getLine(_p1, _p4);
			this._l2 = this.getLine(_p2, _p3);
			this._py = this.getCross(this._l4, this._l2);
			// точка искажения для X коордлинат
			this._dpya1 = Math.atan2(this._py.x-this._p2.x, this._py.y-this._p2.y)+Math.PI;
			this._dpya2 = Math.atan2(this._py.x-this._p1.x, this._py.y-this._p1.y)+Math.PI;
			// дельта тангенса угла.
			da = (this._dpya2-this._dpya1)/this._xCells;
			//массив линий по y
			var pyArr:Array = new Array();
			for (i = this._xCells; i>=0; i--) {
				pyArr.push(this.getLine(this._py, new Point(this._py.x+Math.sin(this._dpya1+i*da), this._py.y+Math.cos(this._dpya1+i*da) ) ) );
			}
			//расчет получающихся прямоугольников, при пересечении всех линий
			for (i = 0; i<pxArr.length-1; i++) {
				for (j = 0; j<pyArr.length-1; j++) {
					var a:Array = this.getQuadrangle(pxArr[i], pyArr[j], pxArr[i+1], pyArr[j+1]);
					this._quadrangle.push(a);
				}
			}
		}
		
		
		/**
		 * @private
		 * ищет прямую по 2м точкам
		 */
		private function getLine(p1:Point, p2:Point):Line {
			var k:Number = (p1.y-p2.y)/(p1.x-p2.x);
			var b:Number = p1.y-p1.x*k;
			return new Line(k, b);
		}
		
		/**
		 * @private
		 * по 4 линиям возвращает 4 вершины
		 */ 
		private function getQuadrangle(lx1:Line, ly1:Line, lx2:Line, ly2:Line):Array {
			var a:Array = new Array();
			a.push(this.getCross(lx1, ly1));
			a.push(this.getCross(lx1, ly2));
			a.push(this.getCross(lx2, ly2));
			a.push(this.getCross(lx2, ly1));
			return a;
		}
		
		/**
		 * @private
		 * пересечение прямых
		 */
		public function getCross(l1:Line, l2:Line):Point {
			var x:Number = (l2.b-l1.b)/(l1.k-l2.k);
			var y:Number = x*l1.k+l1.b;
			return new Point(x, y);
		}
		
	}
}

internal class Line {
	
	public var k:Number;
	
	public var b:Number;
	
	public function Line(k:Number, b:Number) {
		super();
		this.k = k;
		this.b = b;
	}
}