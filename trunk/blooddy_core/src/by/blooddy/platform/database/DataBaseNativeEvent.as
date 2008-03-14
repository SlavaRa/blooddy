////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 BlooDHounD.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.database {

	import by.blooddy.platform.errors.ErrorsManager;

	import by.blooddy.platform.utils.ClassUtils;
	import flash.utils.getQualifiedSuperclassName;
	import flash.utils.getDefinitionByName;

	import by.blooddy.platform.events.DataBaseEvent;
	import flash.events.Event;

	//[ExcludeClass]
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
			super(type, bubbles, cancelable);
			var c:Class = ( this as Object ).constructor;
			if (
				c === DataBaseNativeEvent ||
				(
					c !== DataBaseEvent &&
					getDefinitionByName( getQualifiedSuperclassName( this ) ) === DataBaseNativeEvent
				)
			) {
				throw new ArgumentError( ErrorsManager.getErrorMessage(2012), 2012 );
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
		internal var stopped:Boolean = false;

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
			if (!className) className = ClassUtils.getClassName(this);
			(arguments as Array).unshift( className );
			return super.formatToString.apply(this, arguments);
		}

		/**
		 * @private
		 */
		public override function stopImmediatePropagation():void {
			if (!super.cancelable) return;
			super.stopImmediatePropagation();
			this.stopped = true;
		}

	}

}