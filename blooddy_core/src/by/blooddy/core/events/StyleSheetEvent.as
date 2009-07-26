////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events {

	import by.blooddy.core.utils.ClassUtils;

	import flash.events.Event;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					stylesheetevent, stylesheet, event
	 * 
	 * @see						by.blooddy.core.text.StyleSheet
	 */
	public class StyleSheetEvent extends Event {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @eventType			styleChanged
		 */
		public static const STYLE_CHANGED:String = "styleChanged";

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	type			The event type; indicates the action that caused the event.
		 * @param	bubbles			Specifies whether the event can bubble up the display list hierarchy.
		 * @param	cancelable		Specifies whether the behavior associated with the event can be prevented.
		 * @param	styleNames		Изменённые стили.
		 * 
		 * @see						by.blooddy.core.text.StyleSheet#styleNames
		 */
		public function StyleSheetEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, styleNames:Array=null) {
			super(type, bubbles, cancelable);
			this.styleNames = styleNames;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  styleNames
		//----------------------------------

		[ArrayElementType("String")]
		/**
		 * Изменённые стили.
		 * 
		 * @keyword					stylesheetevent.styleNames, styleNames
		 * 
		 * @see						by.blooddy.core.text.StyleSheet#styleNames
		 */
		public var styleNames:Array;

		//--------------------------------------------------------------------------
		//
		//  Overridden methods: Event
		//
		//--------------------------------------------------------------------------

	    /**
	     * @private
	     */
		public override function clone():Event {
			return new StyleSheetEvent(this.type, this.bubbles, this.cancelable, this.styleNames);
		}

	    /**
	     * @private
	     */
		public override function toString():String {
			return super.formatToString(ClassUtils.getClassName(this), "type", "bubbles", "cancelable", "styleNames");
		}

	}

}