////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image.palette {

	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.06.2010 23:05:22
	 */
	public class MedianCutPalette implements IPalette {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function MedianCutPalette(image:BitmapData, maxColors:uint=256) {
			super();

			if ( maxColors < 2 || maxColors > 256 ) Error.throwError( RangeError, 2006 );

			var colors:Vector.<uint> = image.getVector( image.rect );
			
			var block:Block = new Block( image.getVector( image.rect ), 1 );
			var blockQueue:Array = new Array();

			blockQueue.push( block );

			while( blockQueue.length < maxColors ){
				block = blockQueue.pop();
				if( block.maxSideLength <= 1 ){
					blockQueue.push( block );//push back
					break; //all splited
				}
				var splited:Vector.<Block> = block.splite();
				this.addToQueue( blockQueue, splited[0] );
				this.addToQueue( blockQueue, splited[1] );
			}

		}

		/**
		 * @private
		 */
		private const _blocks:Vector.<Block> = new Vector.<Block>();

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function getIndexByColor(color:uint):uint {
			return 0;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function addToQueue(queue:Array, block:Block):void{
			var blockV:uint = block.maxSideLength;
			var n:int = queue.length;
			for(var i:int=0; i<n; i++){
				if(blockV < queue[i].maxSideLength){
					queue.splice( i, 0, block );
					return;
				}
			}
			queue.push (block );
		}
		
	}

}

internal final class Block{
	
	public static const NUM_DIM:int = 4;
	
	private var points:Vector.<uint>;
	public var minCorner:uint;
	public var maxCorner:uint;
	public var midCorner:uint;
	public var publishColor:uint;
	
	private var alphaWeight:int;
	private var maxSideLengthOffset:uint;
	public var maxSideLength:uint;
	
	public function Block(points:Vector.<uint>, alphaWeight:int, counted:Boolean=false, minCo:uint=0, maxCo:uint=0){
		this.points = points;
		this.alphaWeight = alphaWeight;
		if(points.length < 1){
			throw new Error("points.length < 1");
		}
		
		if(counted){
			minCorner = minCo;
			maxCorner = maxCo;
		}else{
			minCorner = minDim(points);
			maxCorner = maxDim(points);
		}
		
		maxSideLengthOffset = 0;
		maxSideLength = 0;
		midCorner = 0;
		publishColor = 0;
		for(var i:int=0; i<NUM_DIM; i++){
			var offset:uint = i*8;
			var mask:uint = uint(0x000000FF << offset);
			var minC:uint = uint((minCorner&mask)>>>offset);
			var maxC:uint = uint((maxCorner&mask)>>>offset);
			midCorner |= ((uint((minC+maxC)/2)) << offset);
			if(i<3){
				publishColor |= ((uint((minC+maxC)/2)) << offset);
			}else{//means alpha
				if(minC == 0){
					//do nothing means keep 0 alpha -- transparent
				}else if(maxC == 255){
					publishColor |= (0xFF000000); //opaque
				}else{
					publishColor |= ((uint((minC+maxC)/2)) << offset); //middle
				}
			}
			var length:uint = uint(uint((maxCorner&mask)>>>offset)-uint((minCorner&mask)>>>offset));
			if(i == 3){//the rbg weight is 2 times of alpha
				if(length > maxSideLength*alphaWeight){
					maxSideLengthOffset = offset;
					maxSideLength = length;
				}
			}else{
				if(length > maxSideLength){
					maxSideLengthOffset = offset;
					maxSideLength = length;
				}
			}
		}
	}
	
	/**
	 * Splits to two Block.
	 */
	public function splite():Vector.<Block>{
		if(maxSideLength <= 1){
			trace("Error maxSideLength = 1 can't splite!!!");
		}
		var offset:uint = maxSideLengthOffset;
		var mask:uint = uint(0x000000FF << offset);
		
		var left:Vector.<uint> = new Vector.<uint>();
		var right:Vector.<uint> = new Vector.<uint>();
		var mid:uint = uint(midCorner & mask);
		var p:uint;
		
		var lminA:uint = uint.MAX_VALUE;
		var lminR:uint = uint.MAX_VALUE;
		var lminG:uint = uint.MAX_VALUE;
		var lminB:uint = uint.MAX_VALUE;
		var lmaxA:uint = 0;
		var lmaxR:uint = 0;
		var lmaxG:uint = 0;
		var lmaxB:uint = 0;
		var rminA:uint = uint.MAX_VALUE;
		var rminR:uint = uint.MAX_VALUE;
		var rminG:uint = uint.MAX_VALUE;
		var rminB:uint = uint.MAX_VALUE;
		var rmaxA:uint = 0;
		var rmaxR:uint = 0;
		var rmaxG:uint = 0;
		var rmaxB:uint = 0;
		var test:uint;
		
		var n:int = points.length;
		
		for(var i:int=0; i<n; i++){
			p = points[i];
			if((uint(p & mask)) <= mid){
				//min
				test = p&0xFF000000;
				if(test < lminA){
					lminA = test;
				}
				
				test = (p&0x00FF0000);
				if(test < lminR){
					lminR = test;
				}
				
				test = (p&0x0000FF00);
				if(test < lminG){
					lminG = test;
				}
				
				test = p&0x000000FF;
				if(test < lminB){
					lminB = test;
				}
				
				//max
				test = p&0xFF000000;
				if(test > lmaxA){
					lmaxA = test;
				}
				
				test = (p&0x00FF0000);
				if(test > lmaxR){
					lmaxR = test;
				}
				
				test = (p&0x0000FF00);
				if(test > lmaxG){
					lmaxG = test;
				}
				
				test = p&0x000000FF;
				if(test > lmaxB){
					lmaxB = test;
				}
				//push
				left.push(p);
			}else{
				//min
				test = p&0xFF000000;
				if(test < rminA){
					rminA = test;
				}
				
				test = (p&0x00FF0000);
				if(test < rminR){
					rminR = test;
				}
				
				test = (p&0x0000FF00);
				if(test < rminG){
					rminG = test;
				}
				
				test = p&0x000000FF;
				if(test < rminB){
					rminB = test;
				}
				
				//max
				test = p&0xFF000000;
				if(test > rmaxA){
					rmaxA = test;
				}
				
				test = (p&0x00FF0000);
				if(test > rmaxR){
					rmaxR = test;
				}
				
				test = (p&0x0000FF00);
				if(test > rmaxG){
					rmaxG = test;
				}
				
				test = p&0x000000FF;
				if(test > rmaxB){
					rmaxB = test;
				}
				right.push(p);
			}
		}
		var lmx:uint = uint(lminA|lminR|lminG|lminB);
		var rmx:uint = uint(rminA|rminR|rminG|rminB);
		var lmn:uint = uint(lmaxA|lmaxR|lmaxG|lmaxB);
		var rmn:uint = uint(rmaxA|rmaxR|rmaxG|rmaxB);
		
		var result:Vector.<Block> = new Vector.<Block>( 2, true );
		result[ 0 ] = new Block(left, alphaWeight, true, lmx, lmn);
		result[ 1 ] = new Block(right, alphaWeight, true, rmx, rmn);
		return result;
	}
	
	private function minDim(ps:Vector.<uint>):uint{
		var p:uint = ps[0];
		var minA:uint = p&0xFF000000;
		var minR:uint = p&0x00FF0000;
		var minG:uint = p&0x0000FF00;
		var minB:uint = p&0x000000FF;
		var test:uint;
		var n:int = ps.length;
		for(var i:int=1; i<n; i++){
			p = ps[i];
			test = p&0xFF000000;
			if(test < minA){
				minA = test;
			}
			
			test = (p&0x00FF0000);
			if(test < minR){
				minR = test;
			}
			
			test = (p&0x0000FF00);
			if(test < minG){
				minG = test;
			}
			
			test = p&0x000000FF;
			if(test < minB){
				minB = test;
			}
		}
		
		return minA|minR|minG|minB;
	}
	
	private function maxDim(ps:Vector.<uint>):uint{
		var p:uint = ps[0];
		var maxA:uint = p&0xFF000000;
		var maxR:uint = p&0x00FF0000;
		var maxG:uint = p&0x0000FF00;
		var maxB:uint = p&0x000000FF;
		var test:uint;
		var n:int = ps.length;
		for(var i:int=1; i<n; i++){
			p = ps[i];
			test = p&0xFF000000;
			if(test > maxA){
				maxA = test;
			}
			
			test = (p&0x00FF0000);
			if(test > maxR){
				maxR = test;
			}
			
			test = (p&0x0000FF00);
			if(test > maxG){
				maxG = test;
			}
			
			test = p&0x000000FF;
			if(test > maxB){
				maxB = test;
			}
		}
		
		return maxA|maxR|maxG|maxB;
	}
}