////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display.resource {

	import by.blooddy.core.errors.getErrorMessage;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.managers.ResourceManager;
	import by.blooddy.core.utils.AutoTimer;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
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
		//  Classvariables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _TIMER:AutoTimer = new AutoTimer( 30E3 );

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
		private function handler_addedToStage(event:ResourceEvent):void {
			_TIMER.addEventListener( TimerEvent.TIMER, this.handler_timer );
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:ResourceEvent):void {
			_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
		}

		/**
		 * @private
		 */
		private function handler_timer(event:TimerEvent):void {
			var time:Number = getTimer() - 30E3;
			var usage:ResourceUsage;
			for ( var bundleName:String in this._resourceUsages ) {
				usage = this._resourceUsages[ bundleName ] as ResourceUsage;
				if ( usage.count <= 0 && usage.lockCount <= 0 && usage.lastUse <= time ) {
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
			if ( !usage || usage.count <= 0 ) throw new ArgumentError( getErrorMessage( 5101 ), 5101 );
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
			usage.lockCount++;
		}

		/**
		 * @private
		 */
		private function handler_unlockResource(event:ResourceEvent):void {
			var bundleName:String = event.bundleName;
			var usage:ResourceUsage = this._resourceUsages[ bundleName ] as ResourceUsage;
			if ( !usage || usage.lockCount <= 0 ) throw new ArgumentError( getErrorMessage( 5101 ), 5101 );
			usage.lockCount--;
		}
	}

}

/**
 * @private
 */
internal final class ResourceUsage {
	
	public function ResourceUsage() {
		super();
	}
	
	public var count:uint;
	
	public var lastUse:Number;
	
	public var lockCount:int;

}