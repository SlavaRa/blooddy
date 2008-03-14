////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 BlooDHounD.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.events {

	import by.blooddy.platform.utils.ClassUtils;

	import flash.events.Event;

	public class VectorEvent extends Event {

		public static const VECTOR_CHANGED:String = "vectorChanged";

		public function VectorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}

		public override function clone():Event {
			return new VectorEvent(super.type, super.bubbles, super.cancelable);
		}

		public override function toString():String {
			return super.formatToString(ClassUtils.getClassName(this), "type", "bubbles", "cancelable");
		}

	}

}