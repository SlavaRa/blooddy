package by.blooddy.gui.display {

	import flash.events.IEventDispatcher;

	public interface ILivePreview extends IEventDispatcher {

		function get isLivePreview():Boolean;

		function setSize(width:Number, height:Number):void;

		[Deprecated(message="метод устарел", replacement="setPosition")]
		/**
		 */
		function resize(width:Number, height:Number):void;

		function setPosition(x:Number, y:Number):void;

		[Deprecated(message="метод устарел", replacement="setPosition")]
		/**
		 */
		function move(x:Number, y:Number):void;

	}

}