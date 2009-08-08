package by.blooddy.core.managers.remote {

	import flash.events.IEventDispatcher;

	public interface IRemoteModule extends IEventDispatcher {

		function get id():String;

		function clear():void;

	}

}