////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.managers.resource.IResourceBundle;
	import by.blooddy.core.managers.resource.ResourceManager;
	import by.blooddy.core.utils.DefinitionFinder;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * Загружает свф и воспринимает его как ресурсы.
	 * Если загружается не свф, то обижаемся на него и просим убираться во свояси.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					resourceloader, resource, loader
	 */
	public class ResourceLoader extends HeuristicLoader implements IResourceBundle {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function ResourceLoader(request:URLRequest=null, loaderContext:LoaderContext=null) {
			super( request, loaderContext );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _resourceHash:Object = new Object();

		/**
		 * @private
		 */
		private var _definitions:DefinitionFinder;

		//--------------------------------------------------------------------------
		//
		//  Implements properties: IResourceBundle
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function get name():String {
			return super.url;
		}

		/**
		 * @inheritDoc
		 */
		public function get empty():Boolean {
			return !super.loaded;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IResourceBundle
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function getResource(name:String):* {
			if ( !name ) {
				return super.content;
			} else if ( name in this._resourceHash ) { // пытаемся найти в кэше
				return this._resourceHash[ name ];
			} else if ( super.loaderInfo && super.loaderInfo.applicationDomain && super.loaderInfo.applicationDomain.hasDefinition( name ) ) { // пытаемся найти в домене
				return this._resourceHash[ name ] = super.loaderInfo.applicationDomain.getDefinition( name );
			} else if ( super.content && name in super.content ) { // пытаемся найти в контэнте
				return super.content[ name ];
			} else { // закэшируем пустоту :(
				this._resourceHash[ name ] = null;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function hasResource(name:String):Boolean {
			return (
				super.loaded && (
					( name in this._resourceHash ) || // пытаемся найти в кэше
					( !name && super.content ) ||
					( super.loaderInfo && super.loaderInfo.applicationDomain && super.loaderInfo.applicationDomain.hasDefinition( name ) ) || // пытаемся найти в домене
					( super.content && name in super.content ) // пытаемся найти в контэнте
				)
			);
		}

		/**
		 * @inheritDoc
		 */
		public function getResources():Array {
			if ( super.contentType == MIME.FLASH ) {
				if ( !this._definitions ) {
					if ( super.loaderInfo ) this._definitions = new DefinitionFinder( super.loaderInfo.bytes );
				}
				return this._definitions.getDefinitionNames();
			}
			return new Array();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: HeuristicLoader
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function unload():void {
			super.unload();
			this.$unload();
		}

		/**
		 * @private
		 */
		public override function close():void {
			super.close();
			this.$unload();
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function $unload():void {
			for ( var name:String in this._resourceHash ) {
				delete this._resourceHash[ name ];
			}
		}

	}

}