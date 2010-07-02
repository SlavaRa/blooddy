////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image.palette {

	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
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

			maxColors--; // сдвиг для ускорения проверки

			var lpoints:Vector.<uint> = new Vector.<uint>();
			var hash:Object = new Object();

			var width:uint = image.width;
			var height:uint = image.height;

			var cx:uint;

			var t:uint;
			var c:uint;
			var x:uint;
			var y:uint = 0;

			var lminA:uint = 0xFF000000;
			var lminR:uint = 0x00FF0000;
			var lminG:uint = 0x0000FF00;
			var lminB:uint = 0x000000FF;

			var lmaxA:uint = 0x00000000;
			var lmaxR:uint = 0x00000000;
			var lmaxG:uint = 0x00000000;
			var lmaxB:uint = 0x00000000;

			for ( y=0; y<height; y++ ) {
				for ( x=0; x<width; x++ ) {

					c = image.getPixel32( x, y );
					if ( c == cx || c == image.getPixel32( x, y-1 ) ) continue;
					cx = c;

					t = c & 0xFF000000;
					if ( t < lminA ) lminA = t;
					if ( t > lmaxA ) lmaxA = t;

					t = c & 0x00FF0000;
					if ( t < lminR ) lminR = t;
					if ( t > lmaxR ) lmaxR = t;

					t = c & 0x0000FF00;
					if ( t < lminG ) lminG = t;
					if ( t > lmaxG ) lmaxG = t;

					t = c & 0x000000FF;
					if ( t < lminB ) lminB = t;
					if ( t > lmaxB ) lmaxB = t;
					
					lpoints.push( c );

				}
			}

			var block:Block = new Block(
				lpoints,
				lminA, lminR, lminG, lminB,
				lmaxA, lmaxR, lmaxG, lmaxB
			);

			if ( block.count > 1 ) {

				var rpoints:Vector.<uint>;
				
				var rminA:uint;
				var rminR:uint;
				var rminG:uint;
				var rminB:uint;
				
				var rmaxA:uint;
				var rmaxR:uint;
				var rmaxG:uint;
				var rmaxB:uint;
				
				var mask:uint;
				var mid:uint;

				var count:uint;
				var lblock:Block;
				var rblock:Block;

				var i:int;
				var l:uint;

				do {
	
					lpoints = new Vector.<uint>();
					rpoints = new Vector.<uint>();
	
					lminA = 0xFF000000;
					lminR = 0x00FF0000;
					lminG = 0x0000FF00;
					lminB = 0x000000FF;
					lmaxA = 0x00000000;
					lmaxR = 0x00000000;
					lmaxG = 0x00000000;
					lmaxB = 0x00000000;
					rminA = 0xFF000000;
					rminR = 0x00FF0000;
					rminG = 0x0000FF00;
					rminB = 0x000000FF;
					rmaxA = 0x00000000;
					rmaxR = 0x00000000;
					rmaxG = 0x00000000;
					rmaxB = 0x00000000;
	
					mid = block.mid;
					mask = block.mask;
					trace( mid.toString( 16 ), mask );
					cx = 0;
					i = 0;

					for each ( c in block.points ) {

						trace( c.toString( 16 ) );
						if ( c == cx ) continue;
						cx = c;

						if ( uint( c & mask ) <= mid ) {

							t = c & 0xFF000000;
							if ( t < lminA ) lminA = t;
							if ( t > lmaxA ) lmaxA = t;
							
							t = c & 0x00FF0000;
							if ( t < lminR ) lminR = t;
							if ( t > lmaxR ) lmaxR = t;

							t = c & 0x0000FF00;
							if ( t < lminG ) lminG = t;
							if ( t > lmaxG ) lmaxG = t;

							t = c & 0x000000FF;
							if ( t < lminB ) lminB = t;
							if ( t > lmaxB ) lmaxB = t;

							lpoints.push( c );

						} else {

							t = c & 0xFF000000;
							if ( t < rminA ) rminA = t;
							if ( t > rmaxA ) rmaxA = t;
							
							t = c & 0x00FF0000;
							if ( t < rminR ) rminR = t;
							if ( t > rmaxR ) rmaxR = t;
							
							t = c & 0x0000FF00;
							if ( t < rminG ) rminG = t;
							if ( t > rmaxG ) rmaxG = t;
							
							t = c & 0x000000FF;
							if ( t < rminB ) rminB = t;
							if ( t > rmaxB ) rmaxB = t;

							rpoints.push( c );

						}
					}

					lblock = new Block(
						lpoints,
						lminA, lminR, lminG, lminB,
						lmaxA, lmaxR, lmaxG, lmaxB
					);
					rblock = new Block(
						rpoints,
						rminA, rminR, rminG, rminB,
						rmaxA, rmaxR, rmaxG, rmaxB
					);

					l = this._blocks.length;

					if ( lblock.count > rblock.count ) {
						block = rblock;
						rblock = lblock;
						lblock = block;
					}
					block = lblock;
					count = block.count;
					
					for ( i=0; i<l; i++ ) {
						if ( count < this._blocks[ i ].count ) {
							this._blocks.splice( i, 0, block );
							if ( lblock ) {
								block = rblock
								count = block.count;
								i--;
								l++;
								lblock = null;
							} else {
								rblock = null;
								break;
							}
						}
					}

					if ( lblock ) this._blocks.push( lblock );
					if ( rblock ) this._blocks.push( rblock );


					block = this._blocks.pop();

				} while ( this._blocks.length < maxColors && block.count > 1 );

			}

			this._blocks.push( block ); // push back
			
//			trace( this._blocks );

			for each ( block in this._blocks ) {
				this._colors.push( block.color );
			}
			trace( this._colors );
//			
		}

		/**
		 * @private
		 */
		private const _blocks:Vector.<Block> = new Vector.<Block>();

		/**
		 * @private
		 */
		private const _colors:Vector.<uint> = new Vector.<uint>();
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function getColors():Vector.<uint> {
			return null;
		}

		public function getIndexByColor(color:uint):uint {
			return 0;
		}

	}

}

internal final class Block {

	public function Block(
		points:Vector.<uint>,
		minA:uint, minR:uint, minG:uint, minB:uint,
		maxA:uint, maxR:uint, maxG:uint, maxB:uint
	) {
		super();
		this.minA = minA;
		this.minR = minR;
		this.minG = minG;
		this.minB = minB;
		this.maxA = maxA;
		this.maxR = maxR;
		this.maxG = maxG;
		this.maxB = maxB;
		var midA:uint = ( ( maxA + minA ) / 2 ) & 0xFF000000;
		if ( midA > 0 ) {
			var midR:uint = ( ( maxR + minR ) >>> 1 ) & 0xFF0000;
			var midG:uint = ( ( maxG + minG ) >>> 1 ) & 0xFF00;
			var midB:uint = ( ( maxB + minB ) >>> 1 ) & 0xFF;
			var t:uint = maxB - minB;
			if ( t > this.count ) {
				this.count = t;
				this.mid = midB;
				this.mask = 0x000000FF;
			}
			t = ( maxG - minG ) >>> 8;
			if ( t > this.count ) {
				this.count = t;
				this.mid = midG;
				this.mask = 0x0000FF00;
			}
			t = ( maxR - minR ) >>> 16;
			if ( t > this.count ) {
				this.count = t;
				this.mid = midR;
				this.mask = 0x00FF0000;
			}
			t = ( maxA - minA ) >>> 24;
			if ( t > this.count ) {
				this.count = t;
				this.mid = midA;
				this.mask = 0xFF000000;
			}
			if ( this.count > 1 ) {
				this.points = points;
			}
			this.color = midA | midR | midG | midB;
//			trace( this.color.toString( 16 ) );
		}
	}

	public var points:Vector.<uint>;

	public var minA:uint;
	public var minR:uint;
	public var minG:uint;
	public var minB:uint;
	
	public var maxA:uint;
	public var maxR:uint;
	public var maxG:uint;
	public var maxB:uint;
	
	public var mid:uint;
	public var mask:uint;
	public var count:uint;

	public var color:uint;

	public function toString():String {
		return this.color.toString( 16 ) + '[' + this.count + '](' + this.mid.toString( 16 ) + ')';
	}
	
}