package by.blooddy.gui.managers {

	public interface IFocusElement {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  focusManager
		//----------------------------------

		function get focusManager():IFocusManager;

		/**
		 * Если включен focusEnabled, порядковый номер в
		 * порядке переключения фокуса.
		 */
		function get tabIndex():int;
		function set tabIndex(value:int):void;

		function get tabEnabled():Boolean;
		function set tabEnabled(value:Boolean):void; 

		function get enabled():Boolean;
		function set enabled(value:Boolean):void;

	}

}