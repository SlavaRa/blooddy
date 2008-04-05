package by.blooddy.gui.display.controls {

	import by.blooddy.gui.display.IUITextField;
	import by.blooddy.gui.errors.PositionError;
	import by.blooddy.gui.errors.SizeError;
	import by.blooddy.gui.events.UIControlEvent;
	import by.blooddy.gui.utils.UIControlInfo;
	import by.blooddy.platform.events.isIntrinsicEvent;
	import by.blooddy.platform.utils.ObjectInfo;
	import by.blooddy.platform.utils.deferredCall;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.text.TextFormat;

	//--------------------------------------
	//  Styles
	//--------------------------------------

	[Style(name="themeColor", type="uint", format="Color", inherit="yes")]

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @inheritDoc
	 */
	[Event(name="scroll", type="flash.events.Event", deprecatedMessage="событие не используется")]

	/**
	 * @inheritDoc
	 */
	[Event(name="textInput", type="flash.events.TextEvent", deprecatedMessage="событие не используется")]

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude(kind="property", name="alwaysShowSelection")]
	[Exclude(kind="property", name="background")]
	[Exclude(kind="property", name="backgroundColor")]
	[Exclude(kind="property", name="border")]
	[Exclude(kind="property", name="borderColor")]
	[Exclude(kind="property", name="displayAsPassword")]
	[Exclude(kind="property", name="doubleClickEnabled")]
	[Exclude(kind="property", name="focusRect")]
	[Exclude(kind="property", name="maxChars")]
	[Exclude(kind="property", name="mouseEnabled")]
	[Exclude(kind="property", name="mouseWheelEnabled")]
	[Exclude(kind="property", name="restrict")]
	[Exclude(kind="property", name="scrollH")]
	[Exclude(kind="property", name="scrollV")]
	[Exclude(kind="property", name="selectable")]
	[Exclude(kind="property", name="tabEnabled")]
	[Exclude(kind="property", name="tabIndex")]
	[Exclude(kind="property", name="type")]
	[Exclude(kind="property", name="useRichTextClipboard")]
	[Exclude(kind="property", name="selectedText")]
	[Exclude(kind="property", name="selectionBeginIndex")]
	[Exclude(kind="property", name="selectionEndIndex")]

	[Exclude(kind="method", name="setSelection")]
	[Exclude(kind="method", name="replaceSelectedText")]

	[Exclude(kind="event", name="scroll")]
	[Exclude(kind="event", name="textInput")]

	//--------------------------------------
	//  Other metadata
	//--------------------------------------

	[DefaultProperty("text")]
	[DefaultBindingProperty(source="text", destination="text")]
//	[IconFile("Label.png")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					label
	 */
	public class Label extends TextField implements IUITextField {

		public function Label() {
			super();

			this._info = UIControlInfo.getInfo( this );

			// класс абстрактный
			if ( this._info.hasMetadata("AbstractControl", ObjectInfo.META_SELF) ) {
				throw new ArgumentError();
			}

			super.addEventListener(Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MAX_VALUE);
			super.addEventListener(Event.REMOVED_FROM_STAGE, this.handler_removedFromStage, false, int.MAX_VALUE);

		}

		/**
		 * @private
		 */
		private var _info:UIControlInfo;

		/**
		 */
		protected final function get info():UIControlInfo {
			return this._info;
		}

		//--------------------------------------
		//  mouse declaration
		//--------------------------------------

		//--------------------------------------
		//  graphics declaration
		//--------------------------------------

		CONFIG::debug {

			/**
			 * @private
			 */
			private var _showPreview:Boolean = false;

			public function get showPreview():Boolean {
				return this._showPreview;
			}

			/**
			 * @private
			 */
			public function set showPreview(value:Boolean):void {
				if ( this._showPreview == value ) return;
				this._showPreview = value;
				if ( this._showPreview ) {
					this.redrawPreview();
				} else {
//					super.graphics.clear();
				}
			}

			/**
			 * @private
			 */
			private function redrawPreview():void {
//				const bounds:Rectangle = this.getControlBounds( this );
//				with ( super.graphics ) {
//					clear();
//					lineStyle(1, 0xFFFFFF, 1, true, LineScaleMode.NONE);
//					beginFill(0xFFFFFF, 0.3);
//					drawRect( bounds.x, bounds.y, bounds.width, bounds.height );
//					endFill();
//				}
			}

		}

		//------------------------------------------------
		//  text declaration
		//------------------------------------------------
	
		//--------------------------------------
		//  text
		//--------------------------------------

		/**
		 * @private
		 */
		private var _html:Boolean = false;

		[Bindable("change")]
		[Inspectable(category="Text", enumeration="true,false", defaultValue="false")]
		/**
		 */
		public function get html():Boolean {
			return this._html;
		}

		/**
		 * @private
		 */
		public function set html(value:Boolean):void {
			if (this._html == value) return;
			this._html = value;
			this.setText( this._html ? super.text : super.htmlText )
		}

		[Bindable("change")]
		[Inspectable(category="Text")]
		[CollapseWhiteSpace]
		/**
		 */
		public override function get text():String {
			return ( this._html ? super.htmlText : super.text );
		}

		/**
		 * @private
		 */
		public override function set text(value:String):void {
			this.setText( value );
		}

		private function setText(text:String):void {
			var changed:Boolean = false;
			if ( this._html ) {
				if ( super.htmlText == text ) {
					super.htmlText = text;
					changed = true;
				}
			} else {
				if ( super.text == text ) {
					super.text = text;
					changed = true;
				}
			}
			if (changed) super.dispatchEvent( new Event(Event.CHANGE) );
		}

		//------------------------------------------------
		//  
		//------------------------------------------------
	
		//--------------------------------------
		//  layout
		//--------------------------------------

		/**
		 * @inheritDoc
		 */
		public function get layout():DisplayObjectContainer {
			return super.parent;
		}

		//--------------------------------------
		//  center
		//--------------------------------------	

		/**
		 * @private
		 */
		private var _center:Point = new Point();

		[Bindable("centerChange")]
		[Inspectable(category="Position")]
		/**
		 * @inheritDoc
		 */
		public function get center():Point {
			return this._center;
		}

		/**
		 * @private
		 */
		public function set center(p:Point):void {
			var change:Boolean = false;
			if ( p.x != this._center.x && !isNaN(p.x) ) {
				this._center.x = p.x;
				change = true;
			}
			if ( p.y != this._center.y && !isNaN(p.y) ) {
				this._center.y = p.y;
				change = true;
			}
			if (change) {
				CONFIG::debug {
					if (this._showPreview) this.redrawPreview();
				}
				super.dispatchEvent( new UIControlEvent(UIControlEvent.CENTER_CHANGE) );
			}
		}

		//------------------------------------------------
		//  position declaration
		//------------------------------------------------
	
		//--------------------------------------
		//  x
		//--------------------------------------
	
		/**
		 * @private
		 */
		private var _x:Number = 0;

		[Bindable("move")]
		[Inspectable(category="Position")]
		[PercentProxy("xPercent")]
		/**
		 * @inheritDoc
		 */
		public override function get x():Number {
			return this._x;
		}

		/**
		 * @private
		 */
		public override function set x(value:Number):void {
		if (this._x == value && !isNaN(x)) return;
			this.setPosition(value, this._y);
		}

		[Bindable("move")]
		[Inspectable(category="Position")]
		/**
		 * @inheritDoc
		 */
		public function get xPercent():Number {
			if (!this.layout) throw new PositionError();
			return this._x / this.layout.width * 100;
		}

		/**
		 * @private
		 */
		public function set xPercent(value:Number):void {
			if (!this.layout) throw new PositionError();
			this.setPosition( value / 100 * this.layout.width, this._y );
		}

		[Bindable("move")]
		/**
		 */
		protected final function get $x():Number {
			return super.x;
		}

		//--------------------------------------
		//  y
		//--------------------------------------
	
		/**
		 * @private
		 */
		private var _y:Number = 0;

		[Bindable("move")]
		[Inspectable(category="Position")]
		[PercentProxy("yPercent")]
		/**
		 * @inheritDoc
		 */
		public override function get y():Number {
			return this._y;
		}

		/**
		 * @private
		 */
		public override function set y(value:Number):void {
			if (this._y == value && !isNaN(y)) return;
			this.setPosition(this._x, value);
		}

		[Bindable("move")]
		[Inspectable(category="Position")]
		/**
		 * @inheritDoc
		 */
		public function get yPercent():Number {
			if (!this.layout) throw new PositionError();
			return this._y / this.layout.height * 100;
		}

		/**
		 * @private
		 */
		public function set yPercent(value:Number):void {
			if (!this.layout) throw new PositionError();
			this.setPosition( this._x, value / 100 * this.layout.height );
		}

		[Bindable("move")]
		/**
		 */
		protected final function get $y():Number {
			return super.y;
		}

		//--------------------------------------
		//  move
		//--------------------------------------
	
		/**
		 * @inheritDoc
		 */
		public function setPosition(x:Number, y:Number):void {
			var change:Boolean = false;
			if ( this._x != x && !isNaN(x) ) {
				this._x = x;
				super.x = Math.round( this._x );
				change = true;
			}
			if ( this._y != y && !isNaN(y) ) {
				this._y = y;
				super.y = Math.round( this._y );
				change = true;
			}
			if (change) {
				super.dispatchEvent( new UIControlEvent(UIControlEvent.MOVE) );
			}
		}

		[Deprecated(message="метод устарел", replacement="setPosition")]
		/**
		 * @inheritDoc
		 */
		public function move(x:Number, y:Number):void {
			this.setPosition(x, y);
		}

   		//------------------------------------------------
		//  size declaration
		//------------------------------------------------
	
		//--------------------------------------
		//  width
		//--------------------------------------
	
		/**
		 * @private
		 */
		private var _startWidth:Number = 0;

		/**
		 * @private
		 */
		private var _width:Number = 0;

		[Bindable("resize")]
		[Inspectable(category="Size")]
		[PercentProxy("widthPercent")]
		/**
		 * @inheritDoc
		 */
		public override function get width():Number {
			return this._width;
		}

		/**
		 * @private
		 */
		public override function set width(value:Number):void {
			if (this._width == value) return;
			this.setSize(value, this._height);
		}

		[Bindable("resize")]
		[Inspectable(category="Size")]
		/**
		 * @inheritDoc
		 */
		public function get widthPercent():Number {
			if (!this.layout) throw new SizeError();
			return this._width / this.layout.width * 100;
		}

		/**
		 * @private
		 */
		public function set widthPercent(value:Number):void {
			if (!this.layout) throw new SizeError();
			this.setSize( value / 100 * this.layout.width, this._height );
		}

		[Bindable("resize")]
		/**
		 */
		protected function get $width():Number {
			return super.width;
		}

		//--------------------------------------
		//  height
		//--------------------------------------
	
		/**
		 * @private
		 */
		private var _startHeight:Number = 0;

		/**
		 * @private
		 */
		private var _height:Number;

		[Bindable("resize")]
		[Inspectable(category="Size")]
		/**
		 * @inheritDoc
		 */
		public override function get height():Number {
			return this._height;
		}

		/**
		 * @private
		 */
		public override function set height(value:Number):void {
			if (this._height == value) return;
			this.setSize(this._width, value);
		}

		[Bindable("resize")]
		[Inspectable(category="Size")]
		/**
		 * @inheritDoc
		 */
		public function get heightPercent():Number {
			if (!this.layout) throw new SizeError();
			return this._height / this.layout.height * 100;
		}

		/**
		 * @private
		 */
		public function set heightPercent(value:Number):void {
			if (!this.layout) throw new SizeError();
			this.setSize( this._width, value / 100 * this.layout.height );
		}

		/**
		 */
		protected function get $height():Number {
			return super.height;
		}

		//--------------------------------------
		//  scaleX
		//--------------------------------------
	
		/**
		 * @private
		 */
		private var _scaleX:Number = 1;

		[Bindable("resize")]
		[Inspectable(category="Size", defaultValue="1.0")]
		/**
		 * @inheritDoc
		 */
		public override function get scaleX():Number {
			return this._scaleX;
		}

		/**
		 * @private
		 */
		public override function set scaleX(value:Number):void {
			if (this._scaleX == value) return;
			this.setSize( this._startWidth * value, this._height );
		}

		//--------------------------------------
		//  scaleY
		//--------------------------------------
	
		/**
		 * @private
		 */
		private var _scaleY:Number = 1;

		[Bindable("resize")]
		[Inspectable(category="Size", defaultValue="1.0")]
		/**
		 * @inheritDoc
		 */
		public override function get scaleY():Number {
			return this._scaleY;
		}

		/**
		 * @private
		 */
		public override function set scaleY(value:Number):void {
			if (this._scaleY == value) return;
			this.setSize( this._width, this._startHeight * value )
		}

		//--------------------------------------
		//  resize
		//--------------------------------------
	
		/**
		 * @inheritDoc
		 */
		public function setSize(width:Number, height:Number):void {
			var change:Boolean = false;
			const oldWidth:Number = this._width;
			if (oldWidth != width && !isNaN(width)) {
				this._width = width;
				this._scaleX = this._width / this._startWidth;
				change = true;
			}
			const oldHeight:Number = this._width;
			if (oldHeight != height && !isNaN(height)) {
				this._height = height;
				this._scaleY = this._height / this._startHeight;
				change = true;
			}
			width = Math.round( this._width );
			height = Math.round( this._height );
			if (change) {
				CONFIG::debug {
					if (this._showPreview) this.redrawPreview();
				}
				super.dispatchEvent( new UIControlEvent(UIControlEvent.RESIZE) );
			}
		}

		[Deprecated(message="метод устарел", replacement="setSize")]
		/**
		 * @inheritDoc
		 */
		public function resize(width:Number, height:Number):void {
			this.setSize(width, height);
		}

		//--------------------------------------
		//  bounds
		//--------------------------------------

		/**
		 * @inheritDoc
		 */
		public override function getBounds(targetCoordinateSpace:DisplayObject):Rectangle {
			return this.getControlBounds( targetCoordinateSpace );
		}

		protected final function $getBounds(targetCoordinateSpace:DisplayObject):Rectangle {
			return super.getBounds( targetCoordinateSpace );
		}

		/**
		 * @inheritDoc
		 */
		public override function getRect(targetCoordinateSpace:DisplayObject):Rectangle {
			return this.getControlBounds( targetCoordinateSpace );
		}

		protected final function $getRect(targetCoordinateSpace:DisplayObject):Rectangle {
			return super.getRect( targetCoordinateSpace );
		}

		/**
		 * @private
		 */
		private function getControlBounds(targetCoordinateSpace:DisplayObject):Rectangle {
			const p:Point = new Point();
			const result:Rectangle = new Rectangle();
			result.left = -this._center.x;
			result.top = -this._center.y;
			result.width = this._width;
			result.height = this._height;
			if ( targetCoordinateSpace !== this ) {
				result.topLeft = targetCoordinateSpace.globalToLocal( super.localToGlobal( result.topLeft ) );
				result.bottomRight = targetCoordinateSpace.globalToLocal( super.localToGlobal( result.bottomRight ) );
			}
			return result;
		}

		//------------------------------------------------
		//  livepreview declaration
		//------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function get isLivePreview():Boolean {
			var C:Class;
			if ( super.parent ) {
				// flash
				C = getDefinitionByName("fl.livepreview::LivePreviewParent") as Class;
				if ( C && super.parent is C ) return true;
				// flex
				C = getDefinitionByName("mx.core::UIComponentGlobals") as Class;
				if ( C && "designMode" in C && C.designMode ) return true;
			}
			return false;
		}

		//------------------------------------------------
		//  events declaration
		//------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public override function dispatchEvent(event:Event):Boolean {
			if ( isIntrinsicEvent( this, event ) ) return true; // throw new IllegalOperationError();
			else return super.dispatchEvent( event );
		}

		/**
		 */
		protected final function $dispatchEvent(event:Event):Boolean {
			return super.dispatchEvent( event );
		}

		//------------------------------------------------
		//  toString declaration
		//------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public override function toString():String {
			var parent:DisplayObject = this;
			const result:Array = new Array();
			do {
				if (parent.name) result.unshift( parent.name );
				else result.unshift( ( parent as Object ).toLocaleString() );
			} while ( parent = parent.parent );
			return result.join(".");
		}

		//------------------------------------------------
		//  redraw declaration
		//------------------------------------------------

		/**
		 */
		public final function invalidate(redrawType:uint, deferredRedraw:Boolean=true):void {
			if (deferredRedraw) {
				this._redrawType |= redrawType; 
				deferredCall( this.redraw_prepare, null, this, Event.ENTER_FRAME );
			} else {
				this.redraw( redrawType );
			}
		}

		/**
		 * @private
		 */
		private var _redrawType:uint = 0;

		/**
		 * @private
		 */
		private function redraw_prepare():void {
			var type:uint = this._redrawType;
			this._redrawType = 0;
			this.redraw( type );
		}

		/**
		 */
		protected function redraw(redrawType:uint=0):void {
		}

		//------------------------------------------------
		//  stage events declaration
		//------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
		}

		//------------------------------------------------
		//  stage events declaration
		//------------------------------------------------

		[Deprecated(message="свойство устарело", replacement="flash.text.TextField.text")]
		/**
		 * @inheritDoc
		 * 
		 * @default	false
		 */
		public override function get htmlText():String {
			return ( this._html ? super.htmlText : "" );
		}

		/**
		 * @private
		 */
		public override function set htmlText(value:String):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство устарело", replacement="flash.text.TextFormat.color")]
		/**
		 */
		public override function get textColor():uint {
			return parseInt( super.defaultTextFormat.color.toString(), 10 );
		}

		/**
		 * @private
		 */
		public override function set textColor(value:uint):void {
			var format:TextFormat = super.defaultTextFormat;
			format.color = value;
			super.defaultTextFormat = format;
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 * 
		 * @default	false
		 */
		public override function set alwaysShowSelection(value:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 * 
		 * @default	false
		 */
		public override function set background(value:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 */
		public override function set backgroundColor(value:uint):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 * 
		 * @default	false
		 */
		public override function set border(value:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 */
		public override function set borderColor(value:uint):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 * 
		 * @default	false
		 */
		public override function set displayAsPassword(value:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 * 
		 * @default	false
		 */
		public override function set doubleClickEnabled(enabled:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 */
		public override function set focusRect(focusRect:Object):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 */
		public override function set maxChars(value:int):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 * 
		 * @default	false
		 */
		public override function set mouseEnabled(enabled:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 * 
		 * @default	false
		 */
		public override function set mouseWheelEnabled(value:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 */
		public override function set restrict(value:String):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 */
		public override function set scrollH(value:int):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 */
		public override function set scrollV(value:int):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 * 
		 * @default	false
		 */
		public override function set selectable(value:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 * 
		 * @default	false
		 */
		public override function set tabEnabled(enabled:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 */
		public override function set tabIndex(index:int):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 * 
		 * @default	dynamic
		 */
		public override function set type(value:String):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 */
		public override function set useRichTextClipboard(value:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 */
		public override function get selectedText():String {
			return super.selectedText;
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 */
		public override function get selectionBeginIndex():int {
			throw new IllegalOperationError();
		}

		[Deprecated(message="свойство не используется")]
		/**
		 * @inheritDoc
		 */
		public override function get selectionEndIndex():int {
			throw new IllegalOperationError();
		}

		[Deprecated(message="метод не используется")]
		/**
		 * @inheritDoc
		 */
		public override function setSelection(beginIndex:int, endIndex:int):void {
			throw new IllegalOperationError();
		}

		[Deprecated(message="метод не используется")]
		/**
		 * @inheritDoc
		 */
		public override function replaceSelectedText(value:String):void {
			throw new IllegalOperationError();
		}

	}

}