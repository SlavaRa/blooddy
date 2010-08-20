////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.style {

	import by.blooddy.code.css.definition.CSSRule;
	import by.blooddy.code.css.definition.selectors.AttributeSelector;
	import by.blooddy.code.css.definition.selectors.CSSSelector;
	import by.blooddy.code.css.definition.selectors.ChildSelector;
	import by.blooddy.code.css.definition.selectors.ClassSelector;
	import by.blooddy.code.css.definition.selectors.DescendantSelector;
	import by.blooddy.code.css.definition.selectors.IDSelector;
	import by.blooddy.code.css.definition.selectors.PseudoSelector;
	import by.blooddy.code.css.definition.selectors.TagSelector;
	import by.blooddy.code.css.definition.values.CSSValue;
	import by.blooddy.code.css.definition.values.CollectionValue;
	import by.blooddy.code.css.definition.values.PercentValue;
	import by.blooddy.core.utils.ClassAlias;
	import by.blooddy.gui.display.state.IStatable;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					15.05.2010 16:46:29
	 */
	public class StyleApplyer {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function filterSelector(from:Vector.<CSSRule>, to:Vector.<CSSRule>, target:DisplayObject):void {
			for each ( var rule:CSSRule in from ) {
				if ( isSelector( rule.selector, target ) ) {
					to.push( rule );
				}
			}
		}
		
		/**
		 * @private
		 */
		private static function isSelector(selector:CSSSelector, target:DisplayObject):Boolean {
			var s:AttributeSelector = selector.selector;
			do {
				switch ( true ) {
					case s is IDSelector:
						if ( ( s as IDSelector ).value != target.name ) return false;
						break;
					case s is TagSelector:
						var c:Class = ClassAlias.getClass( ( s as TagSelector ).value );
						if ( !c || !( target is c ) ) return false;
						break;
					case s is ClassSelector:
						if ( !( target is IStyleable ) || ( target as IStyleable ).styleClass != ( s as ClassSelector ).value ) return false;
						break;
					case s is PseudoSelector:
						if ( !( target is IStatable ) || ( target as IStatable ).state != ( s as PseudoSelector ).value ) return false;
						break;
				}
			} while ( s = s.selector );
			switch ( true ) {
				case selector is DescendantSelector:
					selector = ( selector as DescendantSelector ).parent;
					while ( target = target.parent ) {
						if ( isSelector( selector, target ) ) {
							return true;
						}
					}
					return false;
				case selector is ChildSelector:
					if ( !target.parent ) return false;
					return isSelector( ( selector as DescendantSelector ).parent, target.parent );
			}
			return true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function StyleApplyer() {
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
		private const _hash_target:Dictionary =	new Dictionary( true );

		/**
		 * @private
		 */
		private const _hash_id:Object =			new Object();

		/**
		 * @private
		 */
		private const _hash_tag:Object =		new Object();

		/**
		 * @private
		 */
		private const _hash_class:Object =		new Object();

		/**
		 * @private
		 */
		private const _hash_pseudo:Object =		new Object();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function addStyleListener(target:DisplayObject):void {
			if ( target in this._hash_target ) return;
			// проверяем нашего папу
			var p:DisplayObject = target;
			while ( p = p.parent ) {
				if ( p in this._hash_target ) {
					throw new ArgumentError();
				}
			}
			// проверяем наших детей
			for ( var o:Object in this._hash_target ) {
				if (
					o is DisplayObjectContainer &&
					( o as DisplayObjectContainer ).contains( target )
				) {
					throw new ArgumentError();
				}
			}
			// всё ок
			this._hash_target[ target ] = true;
			target.addEventListener( Event.ADDED, this.handler_added, false, int.MIN_VALUE, true );
			this.apply( target );
		}

		public function removeStyleListener(target:DisplayObject):void {
			if ( !( target in this._hash_target ) ) return;
			delete this._hash_target[ target ];
			target.removeEventListener( Event.ADDED, this.handler_added );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function apply(target:DisplayObject):void {
			// собираем список правил
			var rules:Vector.<CSSRule> = new Vector.<CSSRule>();
			var tmp:Vector.<CSSRule>;
			// id
			tmp = this._hash_id[ target.name ];
			if ( tmp ) filterSelector( tmp, rules, target );
			// tag
			var c:Class;
			var n:String;
			for ( n in this._hash_tag ) {
				c = ClassAlias.getClass( n );
				if ( target is c ) {
					filterSelector( this._hash_tag[ n ], rules, target );
				}
			}
			// class
			if ( target is IStyleable ) {
				tmp = this._hash_class[ ( target as IStyleable ).styleClass ];
				if ( tmp ) filterSelector( tmp, rules, target );
			}

			// pseudo
			if ( target is IStatable ) {
				tmp = this._hash_pseudo[ ( target as IStatable ).state ];
				if ( tmp ) filterSelector( tmp, rules, target );
			}

			// сделаем из правил один большое declaration
			var declarations:Object = new Object();
			var value:CSSValue;
			for each ( var rule:CSSRule in rules ) {
				
				for ( n in rule.declarations ) {
					
					value = rule.declarations[ n ];
					if ( value is CollectionValue ) {
						
					} else if ( value is PercentValue ) {
						
					}
					
				}
				
			}

			// childs
			if ( target is DisplayObjectContainer ) {
				var cont:DisplayObjectContainer = target as DisplayObjectContainer;
				var l:uint = cont.numChildren;
				var child:DisplayObject;
				for ( var i:uint = 0; i<l; i++ ) {
					child = cont.getChildAt( i );
					if ( child ) this.apply( child );
				}
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
		private function handler_added(event:Event):void {
			if ( event.target in this._hash_target ) return;
			this.apply( event.target as DisplayObject );
		}

	}

}