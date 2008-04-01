package by.blooddy.gui.display {

	import by.blooddy.gui.managers.IFocusElement;
	
	import flash.ui.ContextMenu;

	public interface IUIFocusElement extends IUIControl, IFocusElement {

		function get doubleClickEnabled():Boolean;
		function set doubleClickEnabled(value:Boolean):void; 

		function get mouseEnabled():Boolean;
		function set mouseEnabled(value:Boolean):void;

 		function get contextMenu():ContextMenu;

		function get dragble():Boolean;
		function set dragble(value:Boolean):void;

	}

}