////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.display {
	
	import by.blooddy.core.blooddy;
	import by.blooddy.core.display.resource.LoadableResourceSprite;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.utils.ClassAlias;
	import by.blooddy.gui.events.ComponentEvent;
	
	import flash.display.DisplayObject;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;

	//--------------------------------------
	//  Aliases
	//--------------------------------------
	
	ClassAlias.registerNamespaceAlias( blooddy, Component );

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	[Event( name="componentConstuct", type="by.blooddy.gui.events.ComponentEvent" )]
	[Event( name="componentDestruct", type="by.blooddy.gui.events.ComponentEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					07.04.2010 20:16:02
	 */
	public class Component extends LoadableResourceSprite {
		
		//--------------------------------------------------------------------------
		//
		//  Namepsaces
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
		public function Component() {
			super();
			super.mouseEnabled = true;
			trace( 'component: ' + getQualifiedClassName( this ) );
			super.addEventListener( Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MIN_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE, this.handler_removedFromStage, false, int.MIN_VALUE, true );
			super.addEventListener( ResourceEvent.ADDED_TO_MANAGER, this.handler_addedToManager, false, int.MIN_VALUE, true );
			super.addEventListener( ResourceEvent.REMOVED_FROM_MANAGER, this.handler_removedFromManager, false, int.MIN_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _fixed:Boolean;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _constructed:Boolean = false;

		public function get constructed():Boolean {
			return this._constructed;
		}
		
		public override function set name(value:String):void {
			if ( this._fixed ) {
				throw new IllegalOperationError();
			} else {
				super.name = name;
			}
		}

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
		
		//----------------------------------
		//  container
		//----------------------------------

		/**
		 * @private
		 */
		private var _container:ComponentContainer;
		
		public function get container():ComponentContainer {
			return this._container;
		}
		
		//----------------------------------
		//  lock
		//----------------------------------

		/**
		 * @private
		 */
		private var _lock:Boolean = false;
		
		public function get lock():Boolean {
			return this._lock;
		}

		public function set lock(value:Boolean):void {
			if ( this._lock == value ) return;
			this._lock = value;
			if ( value ) {
				if ( super.stage ) {
					super.stage.addEventListener( Event.RESIZE, this.drawLock );
					this.drawLock();
				}
			} else {
				super.stage.removeEventListener( Event.RESIZE, this.drawLock );
				super.graphics.clear();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function close():void {
			if ( this._container ) {
				this._container.removeComponent( this._componentInfo );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Namespace methods
		//
		//--------------------------------------------------------------------------

		$internal_c final function init(componentInfo:ComponentInfo, name:String=null):void {
			this._componentInfo = componentInfo;
			if ( name ) {
				this._fixed = true;
				super.name = name;
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function drawLock(event:Event=null):void {
			with ( super.graphics ) {
				clear();
				beginFill( 0xFF0000, 0 );
				drawRect( 0, 0, super.stage.stageWidth, super.stage.stageHeight );
				endFill();
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
		private function handler_addedToStage(event:Event):void {
			var parent:DisplayObject = this;
			while ( ( parent = parent.parent ) && !( parent is ComponentContainer ) ) {};
			this._container = parent as ComponentContainer;
			if ( this._lock ) {
				super.stage.addEventListener( Event.RESIZE, this.drawLock );
				this.drawLock();
			}
		}
		
		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			this._container = null;
			if ( this._lock ) {
				super.stage.removeEventListener( Event.RESIZE, this.drawLock );
			}
		}
		
		/**
		 * @private
		 */
		private function handler_addedToManager(event:ResourceEvent):void {
			this._constructed = true;
			super.dispatchEvent( new ComponentEvent( ComponentEvent.COMPONENT_CONSTRUCT, false, false, this ) );
		}

		/**
		 * @private
		 */
		private function handler_removedFromManager(event:ResourceEvent):void {
			this._constructed = false;
			super.dispatchEvent( new ComponentEvent( ComponentEvent.COMPONENT_DESTRUCT, false, false, this ) );
		}
		
	}
	
}