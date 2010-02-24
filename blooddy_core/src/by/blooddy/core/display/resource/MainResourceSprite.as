////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display.resource {

	import by.blooddy.core.errors.display.resource.ResourceError;
	import by.blooddy.core.events.display.resource.ResourceErrorEvent;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.managers.resource.ResourceManagerProxy;

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
			super.addEventListener( ResourceEvent.REMOVED_FROM_MANAGER,	this.handler_removedFromManager, false, int.MIN_VALUE, true ); // !!! MIN !!!
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _manager:ResourceManagerProxy = new ResourceManagerProxy();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public final function get resourceLiveTime():uint {
			return this._manager.resourceLiveTime;
		}

		/**
		 * @private
		 */
		public final function set resourceLiveTime(value:uint):void {
			this._manager.resourceLiveTime = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		rs_protected override function getResourceManager():ResourceManagerProxy {
			if ( super.stage ) {
				return this._manager;
			}
			return null;
		}

		rs_protected override function getDepth():int {
			return int.MAX_VALUE;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_removedFromManager(event:ResourceEvent):void {
			try {
				this._manager.clear();
			} catch ( e:ResourceError ) {
				super.dispatchEvent( new ResourceErrorEvent( ResourceErrorEvent.RESOURCE_ERROR, false, false, e.toString(), e.resources ) );
			}
		}

	}

}