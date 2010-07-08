////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.display.component {
	
	import by.blooddy.core.controllers.IBaseController;
	import by.blooddy.core.display.resource.MainResourceSprite;
	import by.blooddy.core.events.net.loading.LoaderEvent;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.gui.parser.component.ComponentParser;
	
	import flash.display.DisplayObject;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;

	// TODO: handler_removed

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------
	
	[Exclude( kind="method", name="addChild" )]
	[Exclude( kind="method", name="addChildAt" )]
	[Exclude( kind="method", name="removeChild" )]
	[Exclude( kind="method", name="removeChildAt" )]
	[Exclude( kind="method", name="getChildAt" )]
	[Exclude( kind="method", name="getChildIndex" )]
	[Exclude( kind="method", name="getChildByName" )]
	[Exclude( kind="method", name="setChildIndex" )]
	[Exclude( kind="method", name="swapChildren" )]
	[Exclude( kind="method", name="swapChildrenAt" )]
	[Exclude( kind="method", name="contains" )]
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					08.04.2010 14:47:51
	 */
	public class ComponentContainer extends MainResourceSprite {
		
		//--------------------------------------------------------------------------
		//
		//  Namepsaces
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const $ns_controller:Namespace = NativeComponentController[ '$internal_c' ];

		/**
		 * @private
		 */
		private static const $ns_component:Namespace = Component[ '$internal_c' ];

		use namespace $protected_rs;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function ComponentContainer(baseController:IBaseController=null) {
			super();
			this._baseController = baseController;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _components:Object = new Object();

		/**
		 * @private
		 */
		private var _source:Object = new Object();
		
		/**
		 * @private
		 */
		private var _queue:Dictionary = new Dictionary();
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _baseController:IBaseController;
		
		public function get baseController():IBaseController {
			return this._baseController;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function loadComponent(url:String, params:Object=null):void {
			if ( !super.hasManager() ) throw new ArgumentError();
			var loader:ILoadable = super.loadResourceBundle( url );
			if ( loader.complete ) {
				// TODO: inline
			} else {
				loader.addEventListener( Event.COMPLETE,	this.handler_loader_complete );
				loader.addEventListener( ErrorEvent.ERROR,	this.handler_loader_error );
				var asset:ComponentAsset = this._queue[ loader ];
				if ( !asset ) this._queue[ loader ] = asset = new ComponentAsset( url );
				asset.params.push( params );
			}
		}

		public function removeComponent(info:ComponentInfo):ComponentInfo {
			if ( !( info.name in this._components ) || ( this._components[ info.name ] !== info ) ) throw new ArgumentError();
			super.removeChild( info.component );
			delete this._components[ info.name ];
			return info;
		}
		
		public function removeComponentByID(id:String):ComponentInfo {
			return this.removeComponent( this._components[ id ] );
		}

		public function getComponentByID(id:String):ComponentInfo {
			return this._components[ id ];
		}
		
		public function hasComponent(name:String):Boolean {
			return name in this._components;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function addComponent(info:ComponentInfo):void {
			
			// TODO: перенести
			info.component.$ns_component::init( info, info.name );
			if ( info.controller ) {
				info.controller.$ns_controller::init( info, this._baseController );
			}
			
			if ( info.name in this._components ) {
				if ( this._components[ info.name ] !== info ) {
					throw new ArgumentError();
				}
			} else {
				this._components[ info.name ] = info;
				super.addChild( info.component );
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
		private function handler_loader_complete(event:Event):void {
			var asset:ComponentAsset = this._queue[ event.target ];
			this.handler_loader_error( event );

			var xml:XML = new XML( super.getResource( asset.url ) );
			if ( xml ) {

				var parser:ComponentParser = new ComponentParser( super.getResourceManager() );
				parser.addEventListener( Event.COMPLETE,			this.handler_parser_complete );
				parser.addEventListener( ErrorEvent.ERROR,			this.handler_parser_error );
				parser.addEventListener( LoaderEvent.LOADER_INIT,	this.handler_loaderInit );
				parser.parse( xml );
				this._queue[ parser ] = asset;

			} else {

				

			}
		}

		/**
		 * @private
		 */
		private function handler_loader_error(event:Event):void {
			var loader:ILoadable = event.target as ILoadable;
			loader.removeEventListener( Event.COMPLETE,		this.handler_loader_complete );
			loader.removeEventListener( ErrorEvent.ERROR,	this.handler_loader_error );
			delete this._queue[ event.target ];
		}

		/**
		 * @private
		 */
		private function handler_parser_complete(event:Event):void {
			var parser:ComponentParser = event.target as ComponentParser;
			var asset:ComponentAsset = this._queue[ event.target ];
			this.handler_parser_error( event );
		}

		/**
		 * @private
		 */
		private function handler_parser_error(event:Event):void {
			var parser:ComponentParser = event.target as ComponentParser;
			parser.removeEventListener( Event.COMPLETE,				this.handler_parser_complete );
			parser.removeEventListener( ErrorEvent.ERROR,			this.handler_parser_error );
			parser.removeEventListener( LoaderEvent.LOADER_INIT,	this.handler_loaderInit );
			delete this._queue[ parser ];
		}
		
		/**
		 * @private
		 */
		private function handler_loaderInit(event:LoaderEvent):void {
			super.dispatchEvent( new LoaderEvent( LoaderEvent.LOADER_INIT, true, false, event.loader ) );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overriden methods: MovieClip
		//
		//--------------------------------------------------------------------------
		
		[Deprecated( message="метод запрещён", replacement="addComponent" )]
		public override function addChild(child:DisplayObject):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'addChild' );
			return null;
		}
		
		[Deprecated( message="метод запрещён", replacement="addComponent" )]
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'addChildAt' );
			return null;
		}
		
		[Deprecated( message="метод запрещён", replacement="removeComponent" )]
		public override function removeChild(child:DisplayObject):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'removeChild' );
			return null;
		}
		
		[Deprecated( message="метод запрещён", replacement="removeComponent" )]
		public override function removeChildAt(index:int):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'removeChildAt' );
			return null;
		}
		
		[Deprecated( message="метод запрещён" )]
		public override function getChildAt(index:int):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'getChildAt' );
			return null;
		}
		
		[Deprecated( message="метод запрещён" )]
		public override function getChildIndex(child:DisplayObject):int {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'getChildIndex' );
			return -1;
		}
		
		[Deprecated( message="метод запрещён" )]
		public override function getChildByName(name:String):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'getChildByName' );
			return null;
		}
		
		[Deprecated( message="метод запрещён" )]
		public override function setChildIndex(child:DisplayObject, index:int):void {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'setChildIndex' );
		}
		
		[Deprecated( message="метод запрещён" )]
		public override function swapChildren(child1:DisplayObject, child2:DisplayObject):void {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'swapChildren' );
		}
		
		[Deprecated( message="метод запрещён" )]
		public override function swapChildrenAt(index1:int, index2:int):void {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'swapChildrenAt' );
		}
		
		[Deprecated( message="метод запрещён", replacement="hasComponent" )]
		public override function contains(child:DisplayObject):Boolean {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'contains' );
			return false;
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

/**
 * @private
 */
internal final class ComponentAsset {

	public function ComponentAsset(url:String) {
		super();
		this.url = url;
	}

	public var url:String;

	public const params:Array = new Array();

}