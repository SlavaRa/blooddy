package by.blooddy.gui.display {

	import flash.display.IBitmapDrawable;
	import flash.events.IEventDispatcher;

	public interface ILivePreview extends IEventDispatcher, IBitmapDrawable {

		function get isLivePreview():Boolean;

		function setSize(width:Number, height:Number):void;

		function move(x:Number, y:Number):void;

	}

}