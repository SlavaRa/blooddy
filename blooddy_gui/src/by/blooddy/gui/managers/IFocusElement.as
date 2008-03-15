package by.blooddy.gui.managers {

	import flash.display.Sprite;
	import flash.ui.ContextMenu;

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

		function get doubleClickEnabled():Boolean;
		function set doubleClickEnabled(value:Boolean):void; 

		function get mouseEnabled():Boolean;
		function set mouseEnabled(value:Boolean):void;

		function get hitArea():Sprite;
		function set hitArea(value:Sprite):void;

		function get useHandCursor():Boolean;
		function set useHandCursor(value:Boolean):void; 

 		function get contextMenu():ContextMenu;

	}

}