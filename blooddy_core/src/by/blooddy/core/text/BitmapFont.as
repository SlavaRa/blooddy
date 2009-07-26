////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.text {

	import by.blooddy.core.utils.ClassUtils;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.Font;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Флаха инициализировалась.
	 * 
	 * @eventType			flash.events.Event.INIT
	 */
	[Event(name="init", type="flash.events.Event")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class BitmapFont extends EventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 * Constructor
		 */
		public function BitmapFont(fontName:String, loaderContext:BitmapFontLoaderContext=null) {
			super();
			this._fontName = fontName;
			this._loaderContext = loaderContext;
		}

		//--------------------------------------------------------------------------
		//
		//  Variblies
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  loaderContext
		//----------------------------------

		/**
		 * @private
		 */
		private var _loaderContext:BitmapFontLoaderContext;

		/**
		 * A LoaderContext object to use to control loading of the content.
		 * This is an advanced property. 
		 * Most of the time you can use the trustContent property.
		 * 
		 * @default					null
		 * 
		 * @keyword					loader.loadercontext, loadercontext
		 * 
		 * @see						flash.system.LoaderContext
		 * @see						flash.system.ApplicationDomain
		 * @see						flash.system.SecurityDomain
		 */
		public function get loaderContext():BitmapFontLoaderContext {
			return this._loaderContext;
		}

		/**
		 * @private
		 */
		public function set loaderContext(value:BitmapFontLoaderContext):void {
			if (this._loaderContext === value) return;
			this._loaderContext = value;
		}

		//----------------------------------
		//  fontName
		//----------------------------------

		/**
		 * @private
		 */
		private var _fontName:String;

		public function get fontName():String {
			return this._fontName;
		}

		//--------------------------------------------------------------------------
		//
		//  Overiden methods: EventDispatcher
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function loadBitmap(bitmapData:BitmapData):void {
			bitmapData;
		}

		public function dispose():void {
		}

		public function hasGlyphs(str:String):Boolean {
			return false;
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return '[' + ClassUtils.getClassName(this) + ' fontName="'+this._fontName + '"]';
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------


	}

}