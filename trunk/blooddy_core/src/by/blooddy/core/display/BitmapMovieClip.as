////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import by.blooddy.core.utils.IDisposable;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="method", name="addChild" )]
	[Exclude( kind="method", name="addChildAt" )]
	[Exclude( kind="method", name="removeChild" )]
	[Exclude( kind="method", name="removeChildAt" )]
	[Exclude( kind="method", name="getChildAt" )]
	[Exclude( kind="method", name="getChildIndex" )]
	[Exclude( kind="method", name="getChildByName" )]
	[Exclude( kind="method", name="setChildIndex" )]
	[Exclude( kind="method", name="swapChildren" )]
	[Exclude( kind="method", name="swapChildrenAt" )]
	[Exclude( kind="method", name="contains" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					bitmapmovieclip, bitmap, movieclip
	 */
	public class BitmapMovieClip extends MovieClipEquivalent implements IDisposable {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------
		
		use namespace $protected_mc;
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _EMPTY:BitmapData = new BitmapData( 1, 1, true, 0x000000 );

		//--------------------------------------------------------------------------
		//
		//  Class private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function getElement(bitmap:IBitmapDrawable):CollectionElement {
			var bmp:BitmapData;
			var x:Number = 0;
			var y:Number = 0;
			if ( bitmap is BitmapData ) {
				bmp = bitmap as BitmapData;
			} else if ( bitmap is Bitmap ) {
				bmp = ( bitmap as Bitmap ).bitmapData;
			} else if ( bitmap is DisplayObject ) {
				var obj:DisplayObject = bitmap as DisplayObject;
				var bounds:Rectangle = obj.getBounds( obj );
				if ( bounds.width > 0 && bounds.height > 0 ) {
					bmp = new BitmapData( Math.ceil( bounds.width + 2 ), Math.ceil( bounds.height + 2 ), true, 0x000000 );
					bmp.draw( obj, new Matrix( 1, 0, 0, 1, Math.ceil( -bounds.left + 1 ), Math.ceil( -bounds.top + 1 ) ) );
					x = Math.floor( bounds.left - 1 );
					y = Math.floor( bounds.top - 1 );
				} else {
					bmp = _EMPTY;
				}
			}
			return new CollectionElement( bmp, x, y );
		}

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * 
		 * @param	bitmap
		 * @param	pixelSnapping
		 * @param	smoothing
		 * 
		 * @return
		 * 
		 * @note					после выполнения метода MovieClip будет остановлен на последнем кадре. 
		 *  
		 */
		public static function getAsMovieClip(bitmap:IBitmapDrawable, pixelSnapping:String='auto', smoothing:Boolean=false):BitmapMovieClip {
			var result:BitmapMovieClip;
			if ( bitmap is MovieClip ) {
				if ( bitmap is BitmapMovieClip ) {
					result = ( bitmap as BitmapMovieClip ).clone();
					result.pixelSnapping = pixelSnapping;
					result.smoothing = smoothing;
				} else {
					var mc:MovieClip = bitmap as MovieClip;
					result = new BitmapMovieClip( pixelSnapping, smoothing );
					const l:uint = mc.totalFrames;
					for ( var i:uint = 0; i<l; ++i ) {
						mc.gotoAndStop( i + 1 );
						result.addBitmap( mc );
					}
				}
			} else {
				result = new BitmapMovieClip();
				result.addBitmap( bitmap );
			}
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
 		 * Constructor
		 */
		public function BitmapMovieClip(pixelSnapping:String='auto', smoothing:Boolean=false) {
			super();
			this._container.pixelSnapping = pixelSnapping;
			this._container.smoothing = smoothing;
			super.addChild( this._container );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _list:Vector.<CollectionElement> = new Vector.<CollectionElement>();

		/**
		 * @private
		 */
		private const _container:Bitmap = new Bitmap();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public function get pixelSnapping():String {
			return this._container.pixelSnapping;
		}

		/**
		 * @private
		 */
		public function set pixelSnapping(value:String):void {
			this._container.pixelSnapping = value;
		}

		public function get smoothing():Boolean {
			return this._container.smoothing;
		}

		/**
		 * @private
		 */
		public function set smoothing(value:Boolean):void {
			this._container.smoothing = value;
		}

		public function get bitmapData():BitmapData {
			return this._container.bitmapData;
		}

		public function get relativeX():Number {
			return this._container.x;
		}

		public function get relativeY():Number {
			return this._container.y;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: MovieClip
		//
		//--------------------------------------------------------------------------

		[Deprecated( message="метод запрещён", replacement="addBitmap" )]
		public override function addChild(child:DisplayObject):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'addChild' );
			return null;
		}

		[Deprecated( message="метод запрещён", replacement="addBitmapAt" )]
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'addChildAt' );
			return null;
		}

		[Deprecated( message="метод запрещён", replacement="removeBitmap" )]
		public override function removeChild(child:DisplayObject):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'removeChild' );
			return null;
		}

		[Deprecated( message="метод запрещён", replacement="removeBitmapAt" )]
		public override function removeChildAt(index:int):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'removeChildAt' );
			return null;
		}

		[Deprecated( message="метод запрещён", replacement="getBitmapAt" )]
		public override function getChildAt(index:int):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'getChildAt' );
			return null;
		}

		[Deprecated( message="метод запрещён", replacement="getBitmapIndex" )]
		public override function getChildIndex(child:DisplayObject):int {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'getChildIndex' );
			return -1;
		}

		[Deprecated( message="метод запрещён" )]
		public override function getChildByName(name:String):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'getChildByName' );
			return null;
		}

		[Deprecated( message="метод запрещён", replacement="setBitmapIndex" )]
		public override function setChildIndex(child:DisplayObject, index:int):void {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'setChildIndex' );
		}

		[Deprecated( message="метод запрещён", replacement="swapBitmaps" )]
		public override function swapChildren(child1:DisplayObject, child2:DisplayObject):void {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'swapChildren' );
		}

		[Deprecated( message="метод запрещён", replacement="swapBitmapsAt" )]
		public override function swapChildrenAt(index1:int, index2:int):void {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'swapChildrenAt' );
		}

		[Deprecated( message="метод запрещён", replacement="containsBitmap" )]
		public override function contains(child:DisplayObject):Boolean {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'contains' );
			return false;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @param	bind	если установлен в true, то копирует только ссылки на эленты, аставляя связывание.
		 */
		public function clone(bind:Boolean=true):BitmapMovieClip {
			var result:BitmapMovieClip = new BitmapMovieClip( this._container.pixelSnapping, this._container.smoothing );
			var i:uint;
			const l:uint = this._list.length;
			if ( bind ) {
				for ( i=0; i<l; ++i ) {
					result._list.push( this._list[ i ] );
				}
			} else {
				for ( i=0; i<l; ++i ) {
					result._list.push( this._list[ i ].clone() );
				}
			}
			result._totalFrames = this._totalFrames;
			return result;
		}

		public function addBitmap(bitmap:IBitmapDrawable, x:Number=0, y:Number=0):BitmapData {
			var element:CollectionElement = getElement( bitmap );
			element.x += x;
			element.y += y;
			this._list.push( element );
			++this._totalFrames;
			return element.bmp;
		}

		public function addBitmapAt(bitmap:IBitmapDrawable, index:int, x:Number=0, y:Number=0):BitmapData {
			var element:CollectionElement = getElement( bitmap );
			element.x += x;
			element.y += y;
			this._list.splice( index, 0, element );
			++this._totalFrames;
			if ( index <= this._currentFrame ) {
				++this._currentFrame;
			}
			return element.bmp;
		}

		public function removeBitmap(bitmap:BitmapData):BitmapData {
			return this.$removeBitmapAt( this.$getBitmapIndex( bitmap ) );
		}

		public function removeBitmapAt(index:int):BitmapData {
			return this.$removeBitmapAt( index );
		}

		public function getBitmapAt(index:int):BitmapData {
			return this.$getBitmapAt( index );
		}

		public function getBitmapIndex(bitmap:BitmapData):int {
			return this.$getBitmapIndex( bitmap );
		}

		public function setBitmapIndex(bitmap:BitmapData, index:int):void {
			this.$setBitmapIndex( bitmap, index );
		}

		public function swapBitmaps(bitmap1:BitmapData, bitmap2:BitmapData):void {
			this.$swapBitmaps( bitmap1, bitmap2, this.$getBitmapIndex( bitmap1 ), this.$getBitmapIndex( bitmap2 ) );
		}

		public function swapBitmapsAt(index1:int, index2:int):void {
			this.$swapBitmaps( this.getBitmapAt( index1 ), this.getBitmapAt( index2 ), index1, index2 );
		}

		public function containsBitmap(bitmap:BitmapData):Boolean {
			return this.$getBitmapIndex( bitmap ) >= 0;
		}

		public function dispose():void {
			this._container.bitmapData = null;
			this._totalFrames = 0;
			var bmp:BitmapData;
			while ( this._list.length ) {
				bmp = this._list.pop().bmp;
				if ( bmp !== _EMPTY ) bmp.dispose();
			}
			super.stop();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected_mc override function setCurrentFrame(value:int):void {
			this._currentFrame = value;
			if ( this._list.length < value ) return;
			var element:CollectionElement = this._list[ value - 1 ];
			this._container.bitmapData = element.bmp;
			this._container.x = element.x;
			this._container.y = element.y;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function $removeBitmapAt(index:Number):BitmapData {
			--this._totalFrames;
			return this._list.splice( index, 1 )[0].bmp;
		}

		/**
		 * @private
		 */
		private function $getBitmapIndex(bitmap:BitmapData):int {
			var l:uint = this._list.length;
			for ( var i:uint=0; i<l; ++i ) {
				if ( this._list[ i ].bmp === bitmap ) return i;
			}
			return -1;
		}

		/**
		 * @private
		 */
		private function $getBitmapAt(index:int):BitmapData {
			return this._list[ index ].bmp;
		}

		/**
		 * @private
		 */
		private function $setBitmapIndex(bitmap:BitmapData, index:int):void {
			this._list.splice( this.$getBitmapIndex( bitmap ), 1 );
			this._list.splice( index, 0, bitmap );
		}

		/**
		 * @private
		 */
		private function $swapBitmaps(bmp1:BitmapData, bmp2:BitmapData, index1:int, index2:int):void {
			// надо сперва поставить того кто выше
			if ( index1 > index2 ) {
				this.$setBitmapIndex( bmp1, index2 );
				this.$setBitmapIndex( bmp2, index1 );
			} else {
				this.$setBitmapIndex( bmp2, index1 );
				this.$setBitmapIndex( bmp1, index2 );
			}
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.display.BitmapData;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: CollectionElement
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 */
internal final class CollectionElement {

	public function CollectionElement(bmp:BitmapData, x:Number=0, y:Number=0) {
		super();
		this.bmp = bmp;
		this.x = x;
		this.y = y;
	}

	public var bmp:BitmapData;

	public var x:Number;

	public var y:Number;

	public function clone():CollectionElement {
		return new CollectionElement( this.bmp.clone(), this.x, this.y );
	}

}