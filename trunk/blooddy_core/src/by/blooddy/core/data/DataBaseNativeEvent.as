////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data {

	import by.blooddy.core.errors.getErrorMessage;
	import by.blooddy.core.events.data.DataBaseEvent;
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.events.Event;

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="namespace", name="$internal_data" )]

	[Exclude( kind="property", name="$stopped" )]
	[Exclude( kind="property", name="$canceled" )]
	[Exclude( kind="property", name="$target" )]
	[Exclude( kind="property", name="$eventPhase" )]

	[ExcludeClass]
	/**
	 * @private
	 * Класс прослойка для создания события бублинга.
	 * Происходит переопределения target и eventPhase, для создания
	 * всплывающих событи.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class DataBaseNativeEvent extends Event {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		internal namespace $internal_data;

		use namespace $internal_data;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Constructor.
		 * 
		 * @param	type
		 * @param	bubbles
		 * @param	cancelable
		 */
		public function DataBaseNativeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super( type, bubbles, cancelable );
			if ( !( this is DataBaseEvent ) ) {
				throw new ArgumentError( getErrorMessage( 2012, this ), 2012 );
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
		$internal_data var $stopped:Boolean = false;

		/**
		 * @private
		 */
		$internal_data var $canceled:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: Event
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  target
		//----------------------------------

		/**
		 * @private
		 */
		$internal_data var $target:Object;

		/**
		 * @private
		 * Сцылка на таргет.
		 */
		public override function get target():Object {
			return this.$target || super.target;
		}

		//----------------------------------
		//  eventPhase
		//----------------------------------

		/**
		 * @private
		 */
		$internal_data var $eventPhase:uint;

		/**
		 * @private
		 * Фаза.
		 */
		public override function get eventPhase():uint {
			return this.$eventPhase || super.eventPhase;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: Event
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function formatToString(className:String, ...args):String {
			if ( !className ) className = ClassUtils.getClassName( this );
			args.unshift( className );
			return super.formatToString.apply( this, args );
		}

		/**
		 * @private
		 */
		public override function stopImmediatePropagation():void {
			super.stopImmediatePropagation();
			this.$stopped = true;
		}

		/**
		 * @private
		 */
		public override function stopPropagation():void {
			this.$stopped = true;
		}

		/**
		 * @private
		 */
		public override function preventDefault():void {
			if ( super.cancelable ) this.$canceled = true;
		}

		/**
		 * @private
		 */
		public override function isDefaultPrevented():Boolean {
			return this.$canceled;
		}

		/**
		 * @private
		 */
		public override function clone():Event {
			var c:Class = ( this as Object ).constructor as Class;
			return new c( super.type, super.bubbles, super.cancelable );
		}
		
		/**
		 * @private
		 */
		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable' );
		}
		
	}

}