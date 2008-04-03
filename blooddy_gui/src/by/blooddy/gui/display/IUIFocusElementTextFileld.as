package by.blooddy.gui.display {

	public interface IUIFocusElementTextFileld extends IUITextField, IUIFocusElement {

		function get alwaysShowSelection():Boolean;
		function set alwaysShowSelection(value:Boolean):void;

		function get maxChars():int;
		function set maxChars(value:int):void;

		function get mouseWheelEnabled():Boolean;
		function set mouseWheelEnabled(value:Boolean):void;

		function get restrict():String;
		function set restrict(value:String):void;

		function get selectable():Boolean;
		function set selectable(value:Boolean):void;

		function get selectionBeginIndex():int;

		function get selectionEndIndex():int;

		function get selectedText():String;

		function get type():String;
		function set type(value:String):void;

		function get useRichTextClipboard():Boolean;
		function set useRichTextClipboard(value:Boolean):void;


		function replaceSelectedText(value:String):void;

		function setSelection(beginIndex:int, endIndex:int):void;

	}

}