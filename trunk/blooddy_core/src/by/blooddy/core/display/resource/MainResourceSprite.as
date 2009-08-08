////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display.resource {

	import by.blooddy.core.errors.getErrorMessage;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.managers.resource.ResourceManager;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class MainResourceSprite extends ResourceSprite {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function MainResourceSprite() {
			super();
			super.addEventListener( Event.ADDED_TO_STAGE,				this.handler_addedToStage,		false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE,			this.handler_removedFromStage,	false, int.MAX_VALUE, true );
			super.addEventListener( ResourceEvent.GET_RESOURCE,			this.handler_getResource,		false, int.MIN_VALUE, true );
			super.addEventListener( ResourceEvent.TRASH_RESOURCE,		this.handler_trashResource,		false, int.MIN_VALUE, true );
			super.addEventListener( ResourceEvent.LOCK_BUNDLE,			this.handler_lockResource,		false, int.MIN_VALUE, true );
			super.addEventListener( ResourceEvent.UNLOCK_BUNDLE,		this.handler_unlockResource,	false, int.MIN_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _resourceManager:ResourceManager = new ResourceManager();

		/**
		 * @private
		 */
		private const _resourceUsages:Object = new Object();
		
		/**
		 * @private
		 */
		private const _timer:Timer = new Timer( 15E3 );
	
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _resourceLiveTime:uint = 60E3;

		public final function get resourceLiveTime():uint {
			return this._resourceLiveTime;
		}

		/**
		 * @private
		 */
		public final function set resourceLiveTime(value:uint):void {
			if ( this._resourceLiveTime == value ) return;
			this._resourceLiveTime = value;
			this._timer.delay = this._resourceLiveTime / 4;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function $getResourceManager():ResourceManager {
			if ( super.stage ) {
				return this._resourceManager;
			}
			return null;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {
			this._timer.addEventListener( TimerEvent.TIMER, this.handler_timer );
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			this._timer.removeEventListener( TimerEvent.TIMER, this.handler_timer );
		}

		/**
		 * @private
		 */
		private function handler_timer(event:TimerEvent):void {
			var time:Number = getTimer() - this._resourceLiveTime;
			var usage:ResourceUsage;
			for ( var bundleName:String in this._resourceUsages ) {
				usage = this._resourceUsages[ bundleName ] as ResourceUsage;
				if ( usage.count <= 0 && usage.unlocked && usage.lastUse <= time ) {
					delete this._resourceUsages[ bundleName ];
					super.unloadResourceBundle( bundleName );
				}
			}
		}

		/**
		 * @private
		 */
		private function handler_getResource(event:ResourceEvent):void {
			var bundleName:String = event.bundleName;
			var usage:ResourceUsage = this._resourceUsages[ bundleName ] as ResourceUsage;
			if ( !usage ) this._resourceUsages[ bundleName ] = usage = new ResourceUsage();
			usage.count++;
		}

		/**
		 * @private
		 */
		private function handler_trashResource(event:ResourceEvent):void {
			var bundleName:String = event.bundleName;
			var usage:ResourceUsage = this._resourceUsages[ bundleName ] as ResourceUsage;
			if ( !usage || usage.count <= 0 ) throw new ArgumentError( 'Ресурс не был создан.', 5101 );
			usage.count--;
			if ( usage.count <= 0 ) usage.lastUse = getTimer();
		}

		/**
		 * @private
		 */
		private function handler_lockResource(event:ResourceEvent):void {
			var bundleName:String = event.bundleName;
			var usage:ResourceUsage = this._resourceUsages[ bundleName ] as ResourceUsage;
			if ( !usage ) this._resourceUsages[ bundleName ] = usage = new ResourceUsage();
			usage.lockers[ event.target ] = true;
		}

		/**
		 * @private
		 */
		private function handler_unlockResource(event:ResourceEvent):void {
			var bundleName:String = event.bundleName;
			var usage:ResourceUsage = this._resourceUsages[ bundleName ] as ResourceUsage;
			if ( !usage ) throw new ArgumentError( 'Ресурс не был создан.', 5101 );
			var lockers:Dictionary = usage.lockers;
			if ( !lockers[ event.target ] ) throw new ArgumentError( 'Ресурс не был заблокирован.', 5102 );
			delete usage.lockers[ event.target ];
			if ( usage.count <= 0 ) usage.lastUse = getTimer();
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.utils.Dictionary;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ResourceUsage
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class ResourceUsage {
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * Constructor
	 */
	public function ResourceUsage() {
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	public var count:uint;
	
	public var lastUse:Number;
	
	public const lockers:Dictionary = new Dictionary( true );

	public function get unlocked():Boolean {
		for each ( var b:Boolean in this.lockers ) {
			return false;
		}
		return true;
	}

}