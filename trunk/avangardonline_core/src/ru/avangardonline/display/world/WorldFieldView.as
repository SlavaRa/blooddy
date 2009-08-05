////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.world {

	import by.blooddy.core.display.StageObserver;
	import by.blooddy.core.display.resource.MainResourceSprite;
	
	import flash.events.Event;
	
	import ru.avangardonline.database.world.WorldFieldData;
	import ru.avangardonline.events.database.world.WorldDataEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.08.2009 21:32:04
	 */
	public class WorldFieldView extends MainResourceSprite {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function WorldFieldView(data:WorldFieldData) {
			super();
			this._data = data;
			super.addEventListener( Event.ADDED_TO_STAGE,		this.render,	false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE,	this.clear,		false, int.MAX_VALUE, true );
			var observer:StageObserver = new StageObserver( this );
			observer.registerEventListener( data, WorldDataEvent.WIDTH_CHANGE, this.render );
			observer.registerEventListener( data, WorldDataEvent.HEIGHT_CHANGE, this.render );
		}

		public function destruct():void {
			by.blooddy.core.display.destruct( this );
			this._data = null;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  data
		//----------------------------------

		/**
		 * @private
		 */
		private var _data:WorldFieldData;

		public function get data():WorldFieldData {
			return this._data;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected function render(event:Event=null):Boolean {
			if ( !super.stage ) return false;
			
			var width:uint = this._data.width;
			var height:uint = this._data.height;

			var xMin:int = -width / 2;
			var xMax:int = xMin + width;

			var yMin:int = 0;
			var yMax:int = height;

			var cell:BattleFieldCellView;

			var x:int;
			var y:int;

			for ( y=yMin; y<yMax; y++ ) {
				for ( x=xMin; x<xMax; x++ ) {
					cell = new BattleFieldCellView();
					cell.x = x * WorldView.CELL_WIDTH;
					cell.y = y * WorldView.CELL_WIDTH;
					super.addChild( cell );
				}
			}

			return true;
		}

		/**
		 * @private
		 */
		protected function clear(event:Event=null):Boolean {
			return true;
		}

	}

}

import flash.display.Shape;
import flash.display.PixelSnapping;
import flash.display.LineScaleMode;
import ru.avangardonline.display.world.WorldView;

internal final class BattleFieldCellView extends Shape {

	/**
	 * @private
	 */
	private static const _PROTO:Shape = new Shape();

	/*static*/ {
		_PROTO.graphics.lineStyle( 3, 0xFFFFFF, 1, false, LineScaleMode.NORMAL );
		_PROTO.graphics.beginFill( 0xFFFFFF, 0.1 );
		_PROTO.graphics.drawRect( -WorldView.CELL_WIDTH / 2, -WorldView.CELL_HEIGHT / 2, WorldView.CELL_WIDTH, WorldView.CELL_HEIGHT );
		_PROTO.graphics.endFill();
	}

	public function BattleFieldCellView() {
		super();
		super.graphics.copyFrom( _PROTO.graphics );
	}

}