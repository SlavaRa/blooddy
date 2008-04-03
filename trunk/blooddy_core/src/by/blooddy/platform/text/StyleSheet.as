////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.text {

	import by.blooddy.platform.events.StyleSheetEvent;

	import by.blooddy.platform.utils.StringUtils;

	import flash.text.StyleSheet;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Транслируется, когда происходит изменение стиля.
	 * 
	 * @eventType				platform.events.StyleSheetEvent.STYLE_CHANGED
	 */
	[Event(name="styleChanged", type="platform.events.StyleSheetEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					stylesheet, css
	 * 
	 * @see						flash.text.StyleSheet
	 */
	public class StyleSheet extends flash.text.StyleSheet {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @param	styleObject		Объект стиля.
		 * 
		 * @return					Возврщает объект в CSS-формате.
		 * 
		 * @see						#getStyle();
		 */
		public static function styleToCSS(styleObject:Object):String {
			const result:Array = new Array();
			const toLower:Function = function(text:String, ...args):String {
				return "-"+text.toLowerCase();
			}
			for (var key:String in styleObject) {
				result.push( key.replace( /[A-Z]/g, toLower ) + ": " + styleObject[key] );
			}
			return result.join("; ");
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function StyleSheet() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Overridden methods: flash.text.StyleSheet
		//
		//--------------------------------------------------------------------------

		/**
		 * Парсит CSS-стиль эдентично flash.text.StyleSheet.parseCSS().
		 * Кроме того, он транслирует событие StyleSheetEvent.STYLE_CHANGED.
		 * 
		 * @event	styleChanged	platform.events.StyleSheetEvent
		 * 
		 * @see						flash.text.StyleSheet#parseCSS()
		 * 
		 * @keyword					stylesheet.parsecss, parsecss, css
		 */
		public override function parseCSS(CSSText:String):void {
			const styleSheet:flash.text.StyleSheet = new flash.text.StyleSheet();

			const replace:Function = function(text:String, name:String, ...args):String {
				return text.replace(name, StringUtils.trim(name).replace(/\s+/g, ">"));
			}

			CSSText = CSSText.replace(/\s*([^,{}]+)\s*(,|{[^{}]*})\s*/g, replace);

			styleSheet.parseCSS(CSSText);

			this.overrideStyleSheet(styleSheet);
		}

		/**
		 * Очищает стиль, как и flash.text.StyleSheet.clear().
		 * Кроме того, он транслирует событие StyleSheetEvent.STYLE_CHANGED.
		 * 
		 * @event	styleChanged	platform.events.StyleSheetEvent
		 * 
		 * @see						flash.text.StyleSheet#clear()
		 * 
		 * @keyword					stylesheet.clear, clear
		 */
		public override function clear():void {
			const styleNames:Array = this.styleNames;
			super.clear();
			this.dispatchEvent(new StyleSheetEvent(StyleSheetEvent.STYLE_CHANGED, false, false, styleNames));
		}

		/**
		 * Метот совпадает с обычным методом flash.text.StyleSheet.setStyle().
		 * Отличие в том, что вместо полной замены свойства происходит его дополнение/замена,
		 * а так же транслируется событие StyleSheetEvent.STYLE_CHANGED.
		 * 
		 * @param	styleName		Имя стиля.
		 * @param	styleObject		Свойства стиля.
		 * 
		 * @event	styleChanged	platform.events.StyleSheetEvent
		 * 
		 * @see						flash.text.StyleSheet#setStyle()
		 * 
		 * @keyword					stylesheet.setstyle, setstyle, css
		 */
		public override function setStyle(styleName:String, styleObject:Object):void {
			this._setStyle(styleName, styleObject);
			this.dispatchEvent(new StyleSheetEvent(StyleSheetEvent.STYLE_CHANGED, false, false, new Array(styleName)));
		}

		/**
		 * Метод возвращает стиль, как и flash.text.StyleSheet.getStyle().
		 * Едиснтсвенное отличие в том, что у возвращаемого объекта, есть свойство
		 * toString, который возвращет объект в CSS-формате.
		 * 
		 * @param	styleName		Имя стиля.
		 * 
		 * @return					Возвращает стиль.
		 * 
		 * @keyword					stylesheet.getstyle, getstyle
		 * 
		 * @see						#styleToCSS();
		 * @see						flash.text.StyleSheet#getStyle()
		 */
		public override function getStyle(styleName:String):Object {
			styleName = styleName.replace(/ /g,'>');
			const styleObject:Object = super.getStyle(styleName);
			styleObject.toString = function():String {
				return styleToCSS(this);
			}
			styleObject.setPropertyIsEnumerable("toString", false);
			return styleObject;
		}

		/**
		 * @return					Возвращает всю таблицу стилей в CSS-формате.
		 * 
		 * @keyword					stylesheet.tostring, css
		 */
		public override function toString():String {
			const result:Array = new Array();
			// полуим список стилей
			const styleNames:Array = this.styleNames;
			// пробежим по всем стилям и совметим их
			for each (var name:String in styleNames) {
				result.push(name+" { "+this.getStyle(name)+" }");
			}
			return result.join("\n");
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Перезаписывает стили новыми. После транслирует событие StyleSheetEvent.STYLE_CHANGED.
		 * 
		 * @event	styleChanged	platform.events.StyleSheetEvent
		 * 
		 * @keyword					stylesheet.overridestylesheet, overridestylesheet, stylesheet
		 */
		public function overrideStyleSheet(styleSheet:flash.text.StyleSheet):void {
			// полуим список стилей
			const styleNames:Array = styleSheet.styleNames;
			// пробежим по всем стилям и совметим их
			for each (var name:String in styleNames) {
				this._setStyle(name, styleSheet.getStyle(name));
			}
			this.dispatchEvent(new StyleSheetEvent(StyleSheetEvent.STYLE_CHANGED, false, false, styleSheet.styleNames));
		}

		/**
		 * Клонирует таблицу стилей.
		 * 
		 * @return					Новую таблицу стилей.
		 * 
		 * @keyword					stylesheet.clone, clone
		 */
		public function clone():by.blooddy.platform.text.StyleSheet {
			const styleSheet:by.blooddy.platform.text.StyleSheet = new by.blooddy.platform.text.StyleSheet();
			styleSheet.overrideStyleSheet(this);
			return styleSheet;
		}
		
		/**
		 * Возвращает список стилей внутри себя.
		 * 
		 * @return					Массив с именами стилей.
		 * 
		 */
		public override function get styleNames():Array {
			const styleNames:Array = new Array();
			for each (var styleName:String in super.styleNames) {
				styleNames.push(styleName.replace(/>/g," "));
			}
			return styleNames;
		}
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function _setStyle(styleName:String, styleObject:Object):void {
			const oldStyleObject:Object = this.getStyle(styleName) || new Object();
			for (var i:String in styleObject) {
				oldStyleObject[i] = styleObject[i];
			}
			super.setStyle(styleName.replace(/ /g,'>'), oldStyleObject);
		}


	}

}