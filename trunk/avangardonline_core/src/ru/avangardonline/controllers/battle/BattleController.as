////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.controllers.battle {

	import by.blooddy.core.controllers.AbstractController;
	import by.blooddy.core.controllers.IBaseController;
	import by.blooddy.core.database.Data;
	import by.blooddy.core.database.DataBase;
	import by.blooddy.core.utils.IAbstractRemoter;
	import by.blooddy.core.utils.time.Time;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	
	import ru.avangardonline.database.battle.BattleData;
	import ru.avangardonline.database.battle.world.BattleWorldData;
	import ru.avangardonline.display.gfx.battle.world.BattleWorldView;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class BattleController extends AbstractController {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleController(controller:IBaseController, time:Time, remoter:IAbstractRemoter, container:DisplayObjectContainer) {
			super( controller );

			this._time = time;
			this._container = container;

			var dataBase:DataBase = controller.dataBase;
			var battle:BattleData;
			var child:Data = dataBase.getChildByName( 'battleData' );
			if ( child ) {
				if ( child is BattleData ) battle = child as BattleData;
				else dataBase.removeChild( child );
			}
			if ( !battle ) {
				battle = new BattleData( time );
				dataBase.addChild( battle );
			}

			this._data = battle.world;
			this._view = new BattleWorldView( this._data );
			this._view.addEventListener( Event.ADDED_TO_STAGE,		this.handler_addedToStage,		false, int.MAX_VALUE, true );
			this._view.addEventListener( Event.REMOVED_FROM_STAGE,	this.handler_removedToStage,	false, int.MAX_VALUE, true );

			this._container.addChild( this._view );

			if ( this._view.stage ) {
				this.updateStageSize();
			}

		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _y:Number = 0;

		/**
		 * @private
		 */
		private var _data:BattleWorldData;

		/**
		 * @private
		 */
		private var _view:BattleWorldView;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  time
		//----------------------------------

		/**
		 * @private
		 */
		private var _time:Time;

		public function get time():Time {
			return this._time;
		}

		//----------------------------------
		//  container
		//----------------------------------

		/**
		 * @private
		 */
		private var _container:DisplayObjectContainer;

		public function get container():DisplayObjectContainer {
			return this._container;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function update3D(event:Event=null):void {
			var x:int = - this._view.mouseX;
			var y:int = ( this._view.mouseY > 0 ? - this._view.mouseY * 2 : 0 );
			var projection:PerspectiveProjection = new PerspectiveProjection();
			projection.fieldOfView = 80;
			projection.projectionCenter = new Point( x, y );
			this._view.transform.perspectiveProjection = projection;
		}

		/**
		 * @private
		 */
		private function updateStageSize(event:Event=null):void {
			this._view.x = this._view.stage.stageWidth / 2;
			this._view.y = this._view.stage.stageHeight / 2;
			this.update3D( event );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {
			this._view.stage.addEventListener( Event.RESIZE, this.updateStageSize );
			this._view.stage.addEventListener( MouseEvent.MOUSE_MOVE, this.update3D );
			this.updateStageSize( event );
		}

		/**
		 * @private
		 */
		private function handler_removedToStage(event:Event):void {
			this._view.stage.removeEventListener( Event.RESIZE, this.updateStageSize );
			this._view.stage.removeEventListener( MouseEvent.MOUSE_MOVE, this.update3D );
		}

	}

}