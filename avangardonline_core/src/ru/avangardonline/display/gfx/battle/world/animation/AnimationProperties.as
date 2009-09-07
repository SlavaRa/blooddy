////////////////////////////////////////////////////////////////////////////////
//
//  © 2004—2008 TimeZero LLC.
//
////////////////////////////////////////////////////////////////////////////////

package com.timezero.game.database.animation {

	import com.timezero.platform.serializers.tiny.TinyObject;

	[Externalizable('id', 'length', 'repeatCount', 'effectID')]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public final class AnimationProperties extends TinyObject {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function AnimationProperties(id:uint=0) {
			super();
			this.id = id;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		[ExternalProperty(type="UInt8")]
		public var id:uint;

		[ExternalProperty(type="UInt8")]
		public var length:uint = 1;

		[ExternalProperty(type="UInt8")]
		public var repeatCount:uint;

		[ExternalProperty(type="UInt8")]
		public var effectID:uint;

		//[ExternalProperty(type="Boolean")]
		public var stopOnEnd:Boolean;

		public function clone():AnimationProperties {
			var result:AnimationProperties = new AnimationProperties( this.id );
			result.length =			this.length;
			result.repeatCount =	this.repeatCount;
			result.effectID =		this.effectID;
			result.stopOnEnd =		this.stopOnEnd;
			return result;
		}

	}

}