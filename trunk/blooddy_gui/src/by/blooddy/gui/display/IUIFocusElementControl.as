package by.blooddy.gui.display {

	import flash.display.Sprite;

	public interface IUIFocusElementControl extends IUIFocusElement {

		function get useHandCursor():Boolean;
		function set useHandCursor(value:Boolean):void; 

		function get hitArea():Sprite;
		function set hitArea(value:Sprite):void;

	}

}