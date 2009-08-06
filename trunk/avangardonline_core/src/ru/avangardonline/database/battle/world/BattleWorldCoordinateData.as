////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle.world {

	import by.blooddy.core.events.time.TimeEvent;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	import by.blooddy.core.utils.time.Time;
	
	import flash.events.Event;
	
	import ru.avangardonline.events.database.world.BattleWorldCoordinateDataEvent;
	import ru.avangardonline.events.database.world.BattleWorldDataEvent;

	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event(name="movingStart", type="com.timezero.game.events.database.world.CoordinateDataEvent")]
	[Event(name="movingStop", type="com.timezero.game.events.database.world.CoordinateDataEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * @created					06.08.2009 21:19:36
	 */
	public class BattleWorldCoordinateData extends BattleWorldAssetData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function BattleWorldCoordinateData() {
			super();
			super.addEventListener( BattleWorldDataEvent.ADDED_TO_WORLD,		this.handler_addedToWorld,		false, int.MAX_VALUE, true );
			super.addEventListener( BattleWorldDataEvent.REMOVED_FROM_WORLD,	this.handler_removedFromWorld,	false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _time:Time;
/*
		private var _rangeSync:Boolean = false;

		private var _time_start:Number;

		private var _time_range:Number;

		private var _x_start:Number;

		private var _x_range:Number;

		private var _y_start:Number;

		private var _y_range:Number;

		private var _dx:int;

		private var _dy:int;
*/
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  x
		//----------------------------------

		/**
		 * @private
		 */
		private var _moving:Boolean = false;

		public function get moving():Boolean {
			return this._moving;
		}

		//----------------------------------
		//  x
		//----------------------------------

		/**
		 * @private
		 */
		private var _direction:Number = 360 * Math.random();

		public function get direction():Number {
			return this._direction;
		}

		//----------------------------------
		//  speed
		//----------------------------------

		/**
		 * @private
		 */
		private var _speed:Number = 0;

		public function get speed():Number {
			return this._speed;
		}

		//----------------------------------
		//  x
		//----------------------------------

		/**
		 * @private
		 */
		private var _x:Number;

		public function get x():Number {
			return this._x;
		}

		/**
		 * @private
		 */
		public function set x(value:Number):void {
			this.stop();
			if ( this._x == value ) return;
			this._x = value;
			super.dispatchEvent( new BattleWorldCoordinateDataEvent( BattleWorldCoordinateDataEvent.COORDINATE_CHANGE, true ) );
		}

		//----------------------------------
		//  y
		//----------------------------------

		/**
		 * @private
		 */
		private var _y:Number;

		public function get y():Number {
			return this._y;
		}

		/**
		 * @private
		 */
		public function set y(value:Number):void {
			this.stop();
			if ( this._y == value ) return;
			this._y = value;
			super.dispatchEvent( new BattleWorldCoordinateDataEvent( BattleWorldCoordinateDataEvent.COORDINATE_CHANGE, true ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
/*
		public override function setValues(x:Number, y:Number, sectorID:uint, spaceID:uint, locID:uint=0):void {
			this.stop();
			super.setValues( x, y, sectorID, spaceID, locID );
		}
*/
		public override function toLocaleString():String {
			return	'[' + ClassUtils.getClassName( this ) +
						 ' x=' +	this._x +
						', y=' +	this._y + 
					']';
		}

		public function moveTo(x:Number, y:Number, time:Number):void {
			if ( !this._time ) throw new ArgumentError();

			// подписываемся на собтиео бновления
			this._time.addEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.handler_timeRelativityChange );

			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.update, false, int.MAX_VALUE );

			this._moving = true;

			//this.setStartCoordinate( this, timer.getRelativeTime() )
			//const events:Array = this.init(); // аЗаАаПб�б�аКаАаЕаМ аПаЕб�аВб�аЙ аПб�аОаБаЕаГ б�аО б�аБаОб�аОаМ аЕаВаЕаНб�аОаВ

			super.dispatchEvent( new BattleWorldCoordinateDataEvent( BattleWorldCoordinateDataEvent.MOVING_START ) );

//			while ( events.length ) super.$dispatchEvent( events.shift() as Event );

		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function stop():void {
			if ( this._moving ) {
				this._speed = 0;
				this._moving = false;
				enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.update );
				this._time.removeEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.handler_timeRelativityChange );
				super.dispatchEvent( new BattleWorldCoordinateDataEvent( BattleWorldCoordinateDataEvent.MOVING_STOP ) );
			}
		}
/*
		private function init():Array {
			const result:Array = new Array();

			const timer:GameTimer = GameTimer.global;
			const currentTime:Number = timer.getRelativeTime();

			var lastPoint:CheckPointData;
			if ( this._checkPoints && this._checkPoints.length>0 ) { // б�б�-б�аО аЕб�б�б�. аНаАаДаО аПб�аОаВаЕб�аИб�б� аНаА б�б�б�аАб�аЕаВб�аЕб�б�б�
				var lastTime:Number = 0;
				while ( this._checkPoints.length > 0 && ( this._checkPoints[0] as CheckPointData ).time <= currentTime ) {
					lastPoint = this._checkPoints.shift() as CheckPointData;
					lastTime = lastPoint.time;
				}
				if ( lastPoint ) {
					var changed:Boolean = ( this._sectorID != lastPoint.sectorID || this._spaceID != lastPoint.spaceID );
					this.setStartCoordinate( lastPoint, lastTime );
					if ( changed ) {
						result.push( new CoordinateDataEvent( CoordinateDataEvent.COORDINATE_SECTOR_CHANGE ) );
					}
				}

			}

			if ( this._checkPoints && this._checkPoints.length > 0 && this._sector_start ) {

				var point:CheckPointData = this._checkPoints[0] as CheckPointData;

				if ( point is DynamicCheckPointData ) { // б�аЕаКаПаОаИаНб� аДаИаНаАаМаИб�аЕб�аКаИаЙ, б�аО аЕаГаО аКаОаОб�аДаИаНаАб�б� аМаОаГб�б� аМаЕаНб�б�б�б�б�
					if ( ( point as DynamicCheckPointData ).target._speed < this._speed ) {
						this.setStartCoordinate( this, this._time );
					}
				}

				if ( !this._rangeSync ) { // аДаИаАаПаАаЗаОаНб� аИаЗаМаЕаНаИаЛаИб�б�

					const coord:CoordinateData = this._sector_start.getRelativeCoordinate( point );
					if ( !coord ) return result;

					this._x_range =		coord.x -		this._x_start;
					this._y_range =		coord.y -		this._y_start;
					this._time_range =	point.time -	this._time_start;

					this._direction = ( Math.atan2( this._y_range, this._x_range ) ) * 180 / Math.PI % 360;
					if ( this._direction < 0 ) this._direction += 360;

					this._speed = Math.sqrt( this._x_range * this._x_range + this._y_range * this._y_range ) / ( this._time_range / 1E3 ) / 4;

					this._rangeSync = true;
				}

				var dt:Number = ( currentTime - this._time_start ) / this._time_range;

				var x:Number = this._x_start + this._x_range * dt;
				var y:Number = this._y_start + this._y_range * dt;

				var dx:int = 0;
				var dy:int = 0;

				var sectorWidth:uint = this._sector_start.width;
				var sectorHeight:Number = this._sector_start.height;

				if ( x < 0 ) {
					dx = -1;
					x += sectorWidth;
				} else if ( x >= sectorHeight ) {
					dx = 1;
					x -= sectorWidth;
				}

				if ( y < 0 ) {
					dy = -1;
					y += sectorHeight;
				} else if ( y >= sectorHeight ) {
					dy = 1;
					y -= sectorHeight;
				}

				this._x = x;
				this._y = y;
				this._time = currentTime;
				if ( this._dx != dx || dy != this._dy ) {
					this._dx = dx;
					this._dy = dy;
					var sectorID:uint = this._sector_start.getSectorByOffset( dx, dy );
					if ( this._sectorID != sectorID ) {
						this._sectorID = sectorID;
						result.push( new CoordinateDataEvent( CoordinateDataEvent.COORDINATE_SECTOR_CHANGE ) );
					}
				}

			} else {
				this._speed = 0;
				timer.removeEventListener( SystemTimerEvent.RELATIVE_SYNC, this.handler_relativeSync );
				enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.update );
				this._moving = false;
				result.push( new CoordinateDataEvent( CoordinateDataEvent.MOVING_STOP ) );
			}
			return result;
		}
*/

		private function update(event:Event=null):void {
/*			const timer:GameTimer = GameTimer.global;
			const currentTime:Number = timer.getRelativeTime();
			var lastPoint:CheckPointData;
			if ( this._checkPoints && this._checkPoints.length>0 ) { // б�б�-б�аО аЕб�б�б�. аНаАаДаО аПб�аОаВаЕб�аИб�б� аНаА б�б�б�аАб�аЕаВб�аЕб�б�б�
				var lastTime:Number = 0;
				while ( this._checkPoints.length > 0 && ( this._checkPoints[0] as CheckPointData ).time <= currentTime ) {
					lastPoint = this._checkPoints.shift() as CheckPointData;
					lastTime = lastPoint.time;
				}
				if ( lastPoint ) {
					const changed:Boolean = ( this._sectorID != lastPoint.sectorID || this._spaceID != lastPoint.spaceID );
					this.setStartCoordinate( lastPoint, lastTime );
					if ( changed ) super.$dispatchEvent( new CoordinateDataEvent( CoordinateDataEvent.COORDINATE_SECTOR_CHANGE ) );
				}

			}

			if ( this._checkPoints && this._checkPoints.length > 0 && this._sector_start ) {

				const point:CheckPointData = this._checkPoints[0] as CheckPointData;

				if ( point is DynamicCheckPointData ) { // б�аЕаКаПаОаИаНб� аДаИаНаАаМаИб�аЕб�аКаИаЙ, б�аО аЕаГаО аКаОаОб�аДаИаНаАб�б� аМаОаГб�б� аМаЕаНб�б�б�б�б�
					if ( ( point as DynamicCheckPointData ).target._speed < this._speed ) {
						this.setStartCoordinate( this, this._time );
					}
				}

				if ( !this._rangeSync ) { // аДаИаАаПаАаЗаОаНб� аИаЗаМаЕаНаИаЛаИб�б�

					var coord:CoordinateData = this._sector_start.getRelativeCoordinate( point );
					if ( !coord ) return;

					this._x_range =		coord.x -		this._x_start;
					this._y_range =		coord.y -		this._y_start;
					this._time_range =	point.time -	this._time_start;

					this._direction = Math.atan2( this._y_range, this._x_range ) * 180 / Math.PI % 360;
					if ( this._direction < 0 ) this._direction += 360;

					this._speed = Math.sqrt( this._x_range * this._x_range + this._y_range * this._y_range ) / ( this._time_range / 1E3 ) / 4;

					this._rangeSync = true;
					if ( this._checkPoints.length>0 ) super.$dispatchEvent( new CoordinateDataEvent( CoordinateDataEvent.MOVING_CHECKPOINT ) );
				}

				var dt:Number = ( currentTime - this._time_start ) / this._time_range;

				var x:Number = this._x_start + this._x_range * dt;
				var y:Number = this._y_start + this._y_range * dt;

				var dx:int = 0;
				var dy:int = 0;

				var sectorWidth:uint = this._sector_start.width;
				var sectorHeight:Number = this._sector_start.height;

				if ( x < 0 ) {
					dx = -1;
					x += sectorWidth;
				} else if ( x >= sectorHeight ) {
					dx = 1;
					x -= sectorWidth;
				}

				if ( y < 0 ) {
					dy = -1;
					y += sectorHeight;
				} else if ( y >= sectorHeight ) {
					dy = 1;
					y -= sectorHeight;
				}

				this._x = x;
				this._y = y;
				this._time = currentTime;
				if ( this._dx != dx || dy != this._dy ) {
					this._dx = dx;
					this._dy = dy;
					var sectorID:uint = this._sector_start.getSectorByOffset( dx, dy );
					if ( this._sectorID != sectorID ) {
						this._sectorID = sectorID;
						super.$dispatchEvent( new CoordinateDataEvent( CoordinateDataEvent.COORDINATE_SECTOR_CHANGE ) );
					}
				}

			} else {
				this._speed = 0;
				timer.removeEventListener( SystemTimerEvent.RELATIVE_SYNC, this.handler_relativeSync );
				enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.update );
				this._moving = false;
				super.$dispatchEvent( new CoordinateDataEvent( CoordinateDataEvent.MOVING_STOP ) );
			}*/
		}
/*
		private function setStartCoordinate(coordinate:CoordinateData, time:uint):void {
			this._x_start =
			this._x =				coordinate.x;

			this._y_start =
			this._y =				coordinate.y;

			this._sectorID_start =
			this._sectorID =		coordinate.sectorID;

			this._time_start =		time;
			this._dx =				0;
			this._dy =				0;

			this._sector_start =	super.sector;
			this._rangeSync =		false;
		}
*/
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedToWorld(event:BattleWorldDataEvent):void {
			this._time = super.world.time;
		}

		/**
		 * @private
		 */
		private function handler_removedFromWorld(event:BattleWorldDataEvent):void {
			this._time.removeEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.handler_timeRelativityChange );
			this._time = null;
		}

		/**
		 * @private
		 */
		private function handler_timeRelativityChange(event:TimeEvent):void {
//			this._time_start += event.delta;
//			if ( this._checkPoints && this._checkPoints.length>0 ) {
//				for each ( var point:CheckPointData in this._checkPoints ) {
//					point.time += event.delta;
//				}
//				this.update( event );
//			}
		}

	}

}