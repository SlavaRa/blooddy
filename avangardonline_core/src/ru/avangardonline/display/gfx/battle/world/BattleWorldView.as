////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.battle.world {

	import by.blooddy.core.display.StageObserver;
	import by.blooddy.core.display.destruct;
	import by.blooddy.core.display.resource.MainResourceSprite;
	import by.blooddy.core.events.database.DataBaseEvent;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import ru.avangardonline.database.battle.world.BattleWorldData;
	import ru.avangardonline.database.battle.world.BattleWorldElementData;
	import ru.avangardonline.display.gfx.character.CharacterView;
	import ru.avangardonline.events.database.world.BattleWorldCoordinateDataEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					04.08.2009 19:58:31
	 */
	public class BattleWorldView extends MainResourceSprite {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const CELL_WIDTH:uint = 55;

		public static const CELL_HEIGHT:uint = 55;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldView(data:BattleWorldData, factory:BattleWorldViewFactory) {
			super();
			this._data = data;
			this._factory = factory;
			this._field = new BattleWorldFieldView( data.field );
			this._field.rotationX = 90;
			super.addEventListener( ResourceEvent.ADDED_TO_RESOURCE_MANAGER,		this.render,	false, int.MAX_VALUE, true );
			super.addEventListener( ResourceEvent.REMOVED_FROM_RESOURCE_MANAGER,	this.clear,		false, int.MAX_VALUE, true );
			var observer:StageObserver = new StageObserver( this );
			observer.registerEventListener( data.elements, DataBaseEvent.ADDED,		this.handler_added );
			observer.registerEventListener( data.elements, DataBaseEvent.REMOVED,	this.handler_removed );
			observer.registerEventListener( data.elements, BattleWorldCoordinateDataEvent.COORDINATE_CHANGE, this.handler_coordinateChange );
			observer.registerEventListener( data.elements, BattleWorldCoordinateDataEvent.COORDINATE_CHANGE, this.handler_coordinateChange );
		}

		public function destruct():void {
			this._data = null;
			by.blooddy.core.display.destruct( this );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _elements:Dictionary = new Dictionary();

		/**
		 * @private
		 */
		private const _elements_sorted:Vector.<SortAsset> = new Vector.<SortAsset>();

		/**
		 * @private
		 */
		private const _elements_moved:Dictionary = new Dictionary();

		/**
		 * @private
		 */
		private var _elements_moved_count:uint = 0;

		/**
		 * @private
		 */
		private var _field:BattleWorldFieldView;

		/**
		 * @private
		 */
		private const _content:Sprite = new Sprite();

		/**
		 * @private
		 */
		private var _factory:BattleWorldViewFactory;

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
		private var _data:BattleWorldData;

		public function get data():BattleWorldData {
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

			super.addChild( this._field );
			super.addChild( this._content );

			var hash:Dictionary = new Dictionary();

			var characters:Vector.<BattleWorldElementData> = this._data.elements.getElements();
			for each ( var data:BattleWorldElementData in characters ) {
				this.addWorldElement( data );
				hash[ data ] = true;
			}

			for ( var o:Object in this._elements ) {
				if ( !( o in hash ) ) this.removeWorldElement( o as BattleWorldElementData );
			}

			return true;
		}

		/**
		 * @private
		 */
		protected function clear(event:Event=null):Boolean {
			for ( var o:Object in this._elements ) {
				this.removeWorldElement( o as BattleWorldElementData );
			}
			super.removeChild( this._content );
			super.removeChild( this._field );
			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function addWorldElement(data:BattleWorldElementData):void {
			if ( data in this._elements ) throw new ArgumentError();
			var view:BattleWorldElementView = this._factory.getElementView( data );
			if ( !view ) return;
			this._elements_sorted.push( new SortAsset( data ) );
			this._content.addChild( view );
			this._elements[ data ] = view;
			if ( data.coord.moving ) {
				this.moveStartElement( data );
			}
			this.updatePosition( data );
		}

		/**
		 * @private
		 */
		private function removeWorldElement(data:BattleWorldElementData):void {
			if ( !( data in this._elements) ) throw new ArgumentError();
			if ( data.coord.moving ) {
				this.moveStopElement( data );
			}
			var view:BattleWorldElementView = this._elements[ data ];
			if ( !view ) return;
			delete this._elements[ data ];
			this._elements_sorted.splice( this._content.getChildIndex( view ), 1 );
			this._content.removeChild( view );
		}

		/**
		 * @private
		 */
		private function moveStartElement(data:BattleWorldElementData):void {
			this._elements_moved[ data ] = true;
			if ( this._elements_moved_count <= 0 ) {
				enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			}
			this._elements_moved_count++;
		}

		/**
		 * @private
		 */
		private function moveStopElement(data:BattleWorldElementData):void {
			delete this._elements_moved[ data ];
			this._elements_moved_count--;
			if ( this._elements_moved_count <=0 ) {
				enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			}
		}

		/**
		 * @private
		 */
		private function updatePosition(data:BattleWorldElementData):void {
			var view:CharacterView = this._elements[ data ];
			view.x = data.coord.x * CELL_WIDTH;
			view.z = data.coord.y * CELL_HEIGHT;
			var i:uint = this._content.getChildIndex( view );
			var lastIndex:uint = i;
			var asset:SortAsset = this._elements_sorted[ i ];
			var sortRating:Number = -data.coord.y;
			if ( asset.sortRating != sortRating ) {
				this._elements_sorted.splice( i, 1 );
				asset.sortRating = sortRating;
				// найдём куда ставить и поставим
				i = this._elements_sorted.length;
				while ( i-- ) {
					if ( -this._elements_sorted[i].element.coord.y <= sortRating ) break;
				}
				i++;
				this._elements_sorted.splice( i, 0, asset );
				this._content.setChildIndex( view, i );
			}

		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_added(event:DataBaseEvent):void {
			if ( event.target is BattleWorldElementData ) {
				this.addWorldElement( event.target as BattleWorldElementData );
			}
		}

		/**
		 * @private
		 */
		private function handler_removed(event:DataBaseEvent):void {
			if ( event.target is BattleWorldElementData ) {
				this.removeWorldElement( event.target as BattleWorldElementData );
			}
		}

		/**
		 * @private
		 */
		private function handler_coordinateChange(event:BattleWorldCoordinateDataEvent):void {
			this.updatePosition( event.target as BattleWorldElementData );
		}

		/**
		 * @private
		 */
		private function handler_movingStart(event:BattleWorldCoordinateDataEvent):void {
			var data:BattleWorldElementData = event.target as BattleWorldElementData;
			this.moveStartElement( data );
			this.updatePosition( data );
		}

		/**
		 * @private
		 */
		private function handler_movingStop(event:BattleWorldCoordinateDataEvent):void {
			var data:BattleWorldElementData = event.target as BattleWorldElementData;
			this.moveStopElement( data );
			this.updatePosition( data );
		}

		/**
		 * @private
		 */
		private function handler_enterFrame(event:Event):void {
			var data:BattleWorldElementData;
			for ( var d:Object in this._elements_moved ) {
				this.updatePosition( d as BattleWorldElementData );
			}
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import ru.avangardonline.database.battle.world.BattleWorldElementData;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: SortAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class SortAsset {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor.
	 */
	public function SortAsset(element:BattleWorldElementData, sortRating:Number=NaN) {
		super();
		this.element = element;
		this.sortRating = sortRating;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	public var element:BattleWorldElementData;

	public var sortRating:Number;

}