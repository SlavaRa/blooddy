package by.blooddy.gui.display {

	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;

	public interface IUITextField extends IUIControl {

		function get antiAliasType():String;
		function set antiAliasType(value:String):void;

		function get autoSize():String;
		function set autoSize(value:String):void;

		function get condenseWhite():Boolean;
		function set condenseWhite(value:Boolean):void;

		function get defaultTextFormat():TextFormat;
		function set defaultTextFormat(value:TextFormat):void;

		function get embedFonts():Boolean;
		function set embedFonts(value:Boolean):void;

		function get gridFitType():String;
		function set gridFitType(value:String):void;

		function get text():String;
		function set text(value:String):void;

		function get htmlText():String;
		function set htmlText(value:String):void;

		function get multiline():Boolean;
		function set multiline(value:Boolean):void;

		function get numLines():int;

		function get sharpness():Number;
		function set sharpness(value:Number):void;

		function get styleSheet():StyleSheet;
		function set styleSheet(value:StyleSheet):void;

		[Deprecated(message="свойство устарело", replacement="defaultTextFormat.color")]
		function get textColor():uint;
		function set textColor(value:uint):void;

		function get textWidth():Number;

		function get textHeight():Number;

		function get thickness():Number;
		function set thickness(value:Number):void;

		function get wordWrap():Boolean;
		function set wordWrap(value:Boolean):void;

		function appendText(newText:String):void;

		function getCharBoundaries(charIndex:int):Rectangle;

		function getCharIndexAtPoint(x:Number, y:Number):int;

		function getFirstCharInParagraph(charIndex:int):int;

		function getImageReference(id:String):DisplayObject;

		function getLineIndexAtPoint(x:Number, y:Number):int;

		function getLineIndexOfChar(charIndex:int):int;

		function getLineLength(lineIndex:int):int;

		function getLineMetrics(lineIndex:int):TextLineMetrics;

		function getLineOffset(lineIndex:int):int;

		function getLineText(lineIndex:int):String;

		function getParagraphLength(charIndex:int):int;

		function getTextFormat(beginIndex:int=-1, endIndex:int=-1):TextFormat;
		function setTextFormat(format:TextFormat, beginIndex:int = -1, endIndex:int = -1):void;

		function replaceText(beginIndex:int, endIndex:int, newText:String):void;

	}

}