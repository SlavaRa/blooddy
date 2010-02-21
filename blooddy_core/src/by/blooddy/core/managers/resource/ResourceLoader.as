////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.resource {

	import by.blooddy.core.net.HeuristicLoader;
	import by.blooddy.core.net.LoaderContext;
	import by.blooddy.core.net.MIME;
	import by.blooddy.core.utils.DefinitionFinder;
	
	import flash.display.BitmapData;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.getQualifiedClassName;

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
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _NAME_BITMAP_DATA:String = getQualifiedClassName( BitmapData );
		
		/**
		 * @private
		 */
		private static const _NAME_SOUND:String = getQualifiedClassName( Sound );
		
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
		private const _hash:Object = new Object();

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

			} else if ( name in this._hash ) { // пытаемся найти в кэше

				return this._hash[ name ];

			} else {

				var resource:*;
				var domain:ApplicationDomain = ( super.loaderInfo ? super.loaderInfo.applicationDomain : null );

				if ( domain && domain.hasDefinition( name ) ) { // пытаемся найти в домене

					resource = domain.getDefinition( name );

					if ( resource is Class ) {
						
						var resourceClass:Class = resource as Class;
						
						if (
							BitmapData.prototype.isPrototypeOf( resourceClass.prototype ) ||
							domain.getDefinition( _NAME_BITMAP_DATA ).prototype.isPrototypeOf( resourceClass.prototype )
						) {

							resource = new resourceClass( 0, 0 );
							
						} else if ( 
							Sound.prototype.isPrototypeOf( resourceClass.prototype ) ||
							domain.getDefinition( _NAME_SOUND ).prototype.isPrototypeOf( resourceClass.prototype )
						) {
							
							resource = new resourceClass();
							
						}
						
					}				

				} else if ( super.content && name in super.content ) { // пытаемся найти в контэнте

					resource = super.content[ name ];

				}

				this._hash[ name ] = resource;

				return resource;
				
			}

		}

		/**
		 * @inheritDoc
		 */
		public function hasResource(name:String):Boolean {
			return (
				( name in this._hash ) || // пытаемся найти в кэше
				( !name && super.content ) ||
				( super.loaderInfo && super.loaderInfo.applicationDomain && super.loaderInfo.applicationDomain.hasDefinition( name ) ) || // пытаемся найти в домене
				( super.content && name in super.content ) // пытаемся найти в контэнте
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
			this.clear();
			super.unload();
		}

		/**
		 * @private
		 */
		public override function close():void {
			this.clear();
			super.close();
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function clear():void {
			var resource:*;
			for ( var name:String in this._hash ) {
				resource = this._hash[ name ];
				if ( resource is BitmapData ) {
					( resource as BitmapData ).dispose();
				}
				delete this._hash[ name ];
			}
		}

	}

}