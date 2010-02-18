////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events.display.resource {
	
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.events.Event;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class ResourceEvent extends Event {
		
		//--------------------------------------------------------------------------
		//
		//  Constants
		//
		//--------------------------------------------------------------------------

		public static const GET_RESOURCE:String =		'getResource';
		
		public static const TRASH_RESOURCE:String =		'trashResource';
		
		public static const LOCK_BUNDLE:String =		'lockBundle';
		
		public static const UNLOCK_BUNDLE:String =		'unlockBundle';
		
		public static const ADDED_TO_MANAGER:String =		'addedToMain';
		
		public static const REMOVED_FROM_MANAGER:String =	'removedFromMain';
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ResourceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, bundleName:String=null, resourceName:String=null) {
			super( type, bubbles, cancelable );
			this.bundleName = bundleName;
			this.resourceName = resourceName;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var bundleName:String;
		
		public var resourceName:String;
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function clone():Event {
			return new ResourceEvent( super.type, super.bubbles, super.cancelable, this.bundleName, this.resourceName );
		}
		
		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable', 'bundleName', 'resourceName' );
		}
		
	}

}