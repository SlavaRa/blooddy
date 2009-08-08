////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.database {

	import by.blooddy.core.errors.getErrorMessage;
	import by.blooddy.core.events.database.DataBaseEvent;
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedSuperclassName;

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
			var c:Class = ( this as Object ).constructor;
			if (
				c === DataBaseNativeEvent ||
				(
					c !== DataBaseEvent &&
					getDefinitionByName( getQualifiedSuperclassName( this ) ) === DataBaseNativeEvent
				)
			) {
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
		internal var $stopped:Boolean = false;

		/**
		 * @private
		 */
		internal var $canceled:Boolean = false;

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
		internal var $target:Object;

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
		internal var $eventPhase:uint;

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
		public override function formatToString(className:String, ...arguments):String {
			if ( !className ) className = ClassUtils.getClassName( this );
			arguments.unshift( className );
			return super.formatToString.apply( this, arguments );
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

	}

}