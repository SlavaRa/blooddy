////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display.resource {

	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.managers.process.IProgressProcessable;
	import by.blooddy.core.managers.process.IProgressable;
	import by.blooddy.core.managers.process.ProgressDispatcher;
	import by.blooddy.core.net.loading.ILoadable;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
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
			super.addEventListener( ResourceEvent.ADDED_TO_MAIN,		this.handler_addedToMain,		false, int.MIN_VALUE, true );
			super.addEventListener( ResourceEvent.REMOVED_FROM_MAIN,	this.handler_removedFromMain,	false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _loader:IProgressProcessable;

		/**
		 * @private
		 */
		private var _isDrawed:Boolean = false;

		/**
		 * @private
		 */
		private var _hasStage:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected final function invalidate():void {

			if ( !super.hasManager() ) return;

			if ( this._loader ) {

				this.clearLoader();

			} else if ( this._isDrawed ) {

				this._isDrawed = false;
				this.clear();

			}

			var resources:Array = this.getResourceBundles();
			var loader:ILoadable;
			if ( resources ) {
				if ( resources.length == 1 ) {

					if ( resources[ 0 ] ) {
						loader = super.loadResourceBundle( resources[ 0 ] );
						if ( !loader.complete ) {
							this._loader = loader;
						}
					}
					
				} else {
	
					var loaderDispatcher:ProgressDispatcher;
	
					for each ( var bundleName:String in resources ) {
						if ( bundleName ) {
							loader = super.loadResourceBundle( bundleName );
							if ( !loader.complete ) {
								if ( loaderDispatcher ) {
				
									loaderDispatcher.addProcess( loader );
				
								} else if ( this._loader ) {
				
									if ( this._loader !== loader ) {
		
										loaderDispatcher = new ProgressDispatcher();
										loaderDispatcher.addProcess( this._loader );
										loaderDispatcher.addProcess( loader );
										this._loader = loaderDispatcher;
				
									}
				
								} else {
				
									this._loader = loader;
				
								}
							}
						}
					}
	
				}
			}
			if ( this._loader ) {

				this._loader.addEventListener( Event.COMPLETE, this.handler_complete );
				if ( !( this._loader is ProgressDispatcher ) ) {
					this._loader.addEventListener( ErrorEvent.ERROR, this.handler_complete );
				}
				this.preload( this._loader as IProgressable );

			} else if ( this._hasStage ) {

				this._isDrawed = true;
				this.draw();

			}

		}

		protected function getResourceBundles():Array {
			return null;
		}

		protected function preload(loader:IProgressable):Boolean {
			return true;
		}
		
		protected function draw():Boolean {
			return super.hasManager();
		}

		protected function clear():Boolean {
			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function clearLoader():void {
			if ( this._loader is ProgressDispatcher ) {
				( this._loader as ProgressDispatcher ).clear();
			} else {
				this._loader.removeEventListener( ErrorEvent.ERROR, this.handler_complete );
			}
			this._loader.removeEventListener( Event.COMPLETE, this.handler_complete );
			this._loader = null;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedToMain(event:ResourceEvent):void {
			this._hasStage = true;
			super.addEventListener( Event.REMOVED_FROM_STAGE,	this.handler_removedFromStage );
			super.addEventListener( Event.ADDED_TO_STAGE,		this.handler_addedToStage );
			this.invalidate();
		}
		
		/**
		 * @private
		 */
		private function handler_removedFromMain(event:ResourceEvent):void {
			super.removeEventListener( Event.REMOVED_FROM_STAGE,	this.handler_removedFromStage );
			super.removeEventListener( Event.ADDED_TO_STAGE,		this.handler_addedToStage );
			if ( this._loader ) {
				this.clearLoader();
			} else if ( this._isDrawed ) {
				this._isDrawed = false;
				this.clear();
			}
		}

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {
			this._hasStage = true;
			this.invalidate();
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			this._hasStage = false;
		}
		
		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			this.clearLoader();
			if ( this._hasStage ) {
				this._isDrawed = true;
				this.draw();
			}
		}

	}

}