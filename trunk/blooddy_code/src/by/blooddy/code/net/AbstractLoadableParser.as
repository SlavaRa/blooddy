////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 q1
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.net {
	
	import by.blooddy.code.AbstractParser;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.net.loading.LoaderDispatcher;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import by.blooddy.core.net.loading.IProcessable;
	import flash.events.ErrorEvent;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	[Event( name="loaderInit", type="by.blooddy.core.events.net.loading.LoaderEvent" )]
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					28.04.2010 18:33:50
	 */
	public class AbstractLoadableParser extends AbstractParser {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function AbstractLoadableParser() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _loader:IProcessable; 

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		public override function get complete():Boolean {
			return !this._loader && super.complete;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected final function addLoader(loader:IProcessable):void {
			if ( loader.complete ) return;
			var loaderDispatcher:LoaderDispatcher = this._loader as LoaderDispatcher;
			if ( loaderDispatcher ) {
				loaderDispatcher.addLoaderListener( loader );
			} else if ( this._loader ) {
				this._loader.removeEventListener( Event.COMPLETE,	this.handler_complete );
				this._loader.removeEventListener( ErrorEvent.ERROR,	this.handler_complete );
				loaderDispatcher = new LoaderDispatcher();
				loaderDispatcher.addLoaderListener( this._loader );
				loaderDispatcher.addLoaderListener( loader );
				this._loader = loaderDispatcher;
				this._loader.addEventListener( Event.COMPLETE,		this.handler_complete, false, int.MIN_VALUE );
			} else {
				this._loader = loader;
				this._loader.addEventListener( Event.COMPLETE,		this.handler_complete, false, int.MIN_VALUE );
				this._loader.addEventListener( ErrorEvent.ERROR,	this.handler_complete, false, int.MIN_VALUE );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			this._loader.removeEventListener( Event.COMPLETE,						this.handler_complete );
			this._loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_complete );
			this._loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_complete );
			this._loader = null;
			if ( super.complete ) {
				super.dispatchEvent( new Event( Event.COMPLETE ) );
			}
		}

	}
	
}