////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import by.blooddy.core.errors.getErrorMessage;
	
	import flash.errors.IllegalOperationError;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude(kind="event",	name="timerComplete")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class AutoTimer extends Timer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructior
		 */
		public function AutoTimer(delay:Number) {
			super( delay );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties
		//
		//--------------------------------------------------------------------------

		public override function set delay(value:Number):void {
			throw new IllegalOperationError( getErrorMessage( 2071 ), 2071 );
		}

		[Deprecated(message="свойство не используется")]
		public override function set repeatCount(value:int):void {
			throw new IllegalOperationError( getErrorMessage( 2071 ), 2071 );
		}

		[Deprecated(message="метод запрещён. включается автоматически.", replacement="addEventListener")]
		public override function start():void {
			throw new IllegalOperationError( getErrorMessage( 2071 ), 2071 );
		}

		[Deprecated(message="метод запрещён. выключается автоматически.", replacement="removeEventListener")]
		public override function stop():void {
			throw new IllegalOperationError( getErrorMessage( 2071 ), 2071 );
		}

		[Deprecated(message="метод не использщуется")]
		public override function reset():void {
			throw new IllegalOperationError( getErrorMessage( 2071 ), 2071 );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			super.addEventListener( type, listener, useCapture, priority, useWeakReference );
			if ( type == TimerEvent.TIMER ) {
				if ( !super.running ) {
					super.start();
				}
			}
		}

		public override function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			super.removeEventListener( type, listener, useCapture );
			if ( type == TimerEvent.TIMER ) {
				if ( super.running && !super.hasEventListener( type ) ) {
					super.stop();
				}
			}
		}

	}

}