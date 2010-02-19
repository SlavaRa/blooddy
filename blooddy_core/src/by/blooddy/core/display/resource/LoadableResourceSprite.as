////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display.resource {

	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.net.ILoadable;
	import by.blooddy.core.net.LoaderDispatcher;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Feb 18, 2010 1:43:19 PM
	 */
	public class LoadableResourceSprite extends ResourceSprite {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function LoadableResourceSprite() {
			super();
			super.addEventListener( ResourceEvent.ADDED_TO_MANAGER,		this.handler_addedToManager,		false, int.MAX_VALUE, true );
			super.addEventListener( ResourceEvent.REMOVED_FROM_MANAGER,	this.handler_removedFromManager,	false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _loader:ILoadable;

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected final function invalidate():void {
			this.clear();
			var resources:Array = this.getResourceBundles();
			var loader:ILoadable;
			if ( this._loader ) {

				this._loader.removeEventListener( Event.COMPLETE, this.handler_complete );
				this._loader.removeEventListener( IOErrorEvent.IO_ERROR, this.handler_complete );
				this._loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, this.handler_complete );

			}
			if ( resources.length == 1 ) {
				
				loader = super.loadResourceBundle( resources[ 0 ] );
				this._loader = ( loader.loaded ? null : loader );
				
			} else {

				var loaderDispatcher:LoaderDispatcher = this._loader as LoaderDispatcher;
				if ( loaderDispatcher ) {
					loaderDispatcher.close();
					loaderDispatcher = null;
				}
				this._loader = null;

				for each ( var bundleName:String in resources ) {
					loader = super.loadResourceBundle( bundleName );
					if ( !loader.loaded ) {
						if ( loaderDispatcher ) {
		
							loaderDispatcher.addLoaderListener( loader );
		
						} else if ( this._loader ) {
		
							if ( this._loader !== loader ) {

								loaderDispatcher = new LoaderDispatcher();
								loaderDispatcher.addLoaderListener( this._loader );
								loaderDispatcher.addLoaderListener( loader );
								this._loader = loaderDispatcher;
		
							}
		
						} else {
		
							this._loader = loader;
		
						}
					}
				}

			}
			if ( this._loader ) {

				this._loader.addEventListener( Event.COMPLETE, this.handler_complete );
				if ( !( this._loader is LoaderDispatcher ) ) {
					this._loader.addEventListener( IOErrorEvent.IO_ERROR, this.handler_complete );
					this._loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, this.handler_complete );
				}
				this.preload( this._loader );

			} else {

				this.render();

			}
		}

		protected function getResourceBundles():Array {
			return null;
		}

		protected function preload(loader:ILoadable):Boolean {
			return true;
		}
		
		protected function render():Boolean {
			return true;
		}

		protected function clear():Boolean {
			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedToManager(event:ResourceEvent):void {
			this.invalidate();
		}
		
		/**
		 * @private
		 */
		private function handler_removedFromManager(event:ResourceEvent):void {
			this.clear();
		}

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			if ( event.target === this._loader ) {
				this.invalidate();
			}
		}

	}

}