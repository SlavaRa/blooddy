////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.display {

	import flash.events.Event;
	import flash.events.IEventDispatcher;

	import flash.utils.Dictionary;

	import flash.display.DisplayObject;

	public class StageObserver {

		public function StageObserver(target:DisplayObject) {
			super();
			this._target = target;
			this._target.addEventListener(Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MAX_VALUE);
			this._target.addEventListener(Event.REMOVED_FROM_STAGE, this.handler_removedFromStage, false, int.MAX_VALUE);
		}

		private var _target:DisplayObject;

		private	const _listeners:Array = new Array();

		public function registerEventListener(target:IEventDispatcher, type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			var item:StageObserverItem;
			for each (item in this._listeners) {
				if (
					item.target === target &&
					item.type == type &&
					item.listener === listener &&
					item.useCapture == useCapture
				) {
					if (item.priority != priority || item.useWeakReference != useWeakReference) {
						item.priority = priority;
						item.useWeakReference = useWeakReference;
						if (this._target.stage) item.activate();
					}
					return;
				}
			}
			item = new StageObserverItem(target, type, listener, useCapture, priority, useWeakReference);
			this._listeners.push( item );
			if (this._target.stage) item.activate();
		}

		public function unregisterEventListener(target:IEventDispatcher, type:String, listener:Function, useCapture:Boolean=false):void {
			if (this._target.stage) {
				target.removeEventListener(type, listener, useCapture);
			}
			var item:StageObserverItem;
			for (var i:String in this._listeners) {
				item = this._listeners[i] as StageObserverItem;
				if (
					item.target === target &&
					item.type == type &&
					item.listener === listener &&
					item.useCapture == useCapture
				) {
					this._listeners.splice( i as uint, 1 );
				}
			}
		}

		private function handler_addedToStage(event:Event):void {
			for (var i:uint=0; i<this._listeners.length; i++) {
				( this._listeners[i] as StageObserverItem ).activate();
			}
		}

		private function handler_removedFromStage(event:Event):void {
			for (var i:uint=0; i<this._listeners.length; i++) {
				( this._listeners[i] as StageObserverItem ).deactivate();
			}
		}

	}

}

import flash.events.IEventDispatcher;

internal final class StageObserverItem {

	public function StageObserverItem(target:IEventDispatcher, type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false) {
		super();
		this.target = target;
		this.type = type;
		this.listener = listener;
		this.useCapture = useCapture;
		this.priority = priority;
		this.useWeakReference = useWeakReference;
	}

	public var target:IEventDispatcher;
	public var type:String;
	public var listener:Function;
	public var useCapture:Boolean;
	public var priority:int;
	public var useWeakReference:Boolean;

	public function activate():void {
		this.target.addEventListener(this.type, this.listener, this.useCapture, this.priority, this.useWeakReference);
	}

	public function deactivate():void {
		this.target.removeEventListener(this.type, this.listener, this.useCapture);
	}

}