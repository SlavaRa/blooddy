////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.display {
	
	import by.blooddy.core.controllers.IBaseController;
	import by.blooddy.core.controllers.IController;
	import by.blooddy.core.data.DataBase;
	import by.blooddy.core.utils.IAbstractRemoter;
	import by.blooddy.gui.events.ComponentEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

	[ExcludeClass]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					07.04.2010 20:14:57
	 */
	public class NativeComponentController extends EventDispatcher implements IController, IAbstractRemoter {
		
		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		internal namespace $internal_c;

		use namespace $internal_c;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function NativeComponentController() {
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
		private var _constructed:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  componentInfo
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _componentInfo:ComponentInfo;
		
		public function get componentInfo():ComponentInfo {
			return this._componentInfo;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  baseController
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _baseController:IBaseController;
		
		/**
		 * @inheritDoc
		 */
		public function get baseController():IBaseController {
			return this._baseController;
		}
		
		//----------------------------------
		//  dataBase
		//----------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get dataBase():DataBase {
			return this._baseController.dataBase;
		}
		
		//----------------------------------
		//  sharedObject
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _sharedObject:Object;
		
		/**
		 * @inheritDoc
		 */
		public function get sharedObject():Object {
			return this._sharedObject;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function call(commandName:String, ... parameters):* {
			parameters.unshift( commandName );
			this._baseController.call.apply( null, parameters );
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		protected virtual function construct():void {
		}
		
		protected virtual function destruct():void {
		}
		
		//--------------------------------------------------------------------------
		//
		//  Namespace methonds
		//
		//--------------------------------------------------------------------------

		$internal_c final function init(info:ComponentInfo, controller:IBaseController=null):void {
			this._componentInfo = info;

			if ( controller ) {
				this._baseController = controller;
				this._sharedObject = controller.sharedObject[ 'component_' + info.name ];
			}
			if ( !this._sharedObject ) controller.sharedObject[ 'component_' + info.name ] = this._sharedObject = new Object();
			
			info.component.addEventListener( ComponentEvent.COMPONENT_CONSTRUCT, this.handler_componentConstruct, false, int.MAX_VALUE, true );
			info.component.addEventListener( ComponentEvent.COMPONENT_DESTRUCT, this.handler_componentDestruct, false, int.MAX_VALUE, true );
			if ( info.component.constructed ) {
				info.component.addEventListener( Event.FRAME_CONSTRUCTED, this.handler_frameConstructed );
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
		private function handler_frameConstructed(event:Event):void {
			this._componentInfo.component.removeEventListener( Event.FRAME_CONSTRUCTED, this.handler_frameConstructed );
			if ( !this._constructed && this._componentInfo.component.constructed ) {
				this._constructed = true;
				this.construct();
			}
		}
		
		/**
		 * @private
		 */
		private function handler_componentConstruct(event:Event):void {
			if ( !this._constructed ) {
				this._constructed = true;
				this.construct();
			}
		}
		
		/**
		 * @private
		 */
		private function handler_componentDestruct(event:Event):void {
			if ( this._constructed ) {
				this._constructed = false;
				this.destruct();
			}
		}
		
	}
	
}