////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.display.component {

	import by.blooddy.gui.controller.ComponentController;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					08.04.2010 18:41:19
	 */
	public final class ComponentInfo {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function ComponentInfo(name:String, component:Component, controller:ComponentController, parameters:Object) {
			super();
			this._name = name;
			this._component = component;
			this._controller = controller;
			this._parameters = parameters;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  component
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _name:String;
		
		public function get name():String {
			return this._name;
		}
		
		//----------------------------------
		//  component
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _component:Component;
		
		public function get component():Component {
			return this._component;
		}
		
		//----------------------------------
		//  controller
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _controller:ComponentController;
		
		public function get controller():ComponentController {
			return this._controller;
		}
		
		//----------------------------------
		//  parameters
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _parameters:Object;
		
		public function get parameters():Object {
			var parameters:Object = new Object();
			for ( var i:String in this._parameters ) {
				parameters[ i ] = this._parameters[ i ];
			}
			return parameters;
		}

	}
	
}