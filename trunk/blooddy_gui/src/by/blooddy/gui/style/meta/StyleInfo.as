////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.style.meta {

	import by.blooddy.code.css.definition.values.NumberValue;
	import by.blooddy.core.meta.MemberInfo;
	import by.blooddy.core.meta.PropertyInfo;
	import by.blooddy.core.meta.TypeInfo;
	import by.blooddy.core.utils.ClassAlias;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.gui.style.StyleType;

	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					25.05.2010 0:21:43
	 */
	public class StyleInfo {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function getInfo(o:Object):StyleInfo {
			var c:Class = ClassUtils.getClass( o );
			if ( !c ) return null;
			var result:StyleInfo = _HASH[ c ];
			if ( !result ) {
				_privateCall = true;
				_HASH[ c ] = result = new StyleInfo();
				result.parseType( TypeInfo.getInfo( c ) );
				_privateCall = false;
			}
			return result;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static var _privateCall:Boolean = false;
		
		/**
		 * @private
		 */
		private static const _HASH:Dictionary = new Dictionary( true );
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function StyleInfo() {
			super();
			if ( !_privateCall ) throw new IllegalOperationError();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _styles:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getStyle(name:*):AbstractStyle {
			return this._styles[ name ];
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function parseType(type:TypeInfo):void {

			var n:String;

			var parent:StyleInfo;
			if ( type.parent ) {
				parent = getInfo( type.parent.target );
				for ( n in parent._styles ) {
					this._styles[ n ] = parent._styles[ n ];
				}
			}

			var list:XMLList;
			var xml:XML;
			var m:MemberInfo;
			var a:AbstractStyle;
			var s:SimpleStyle;
			var c:CollectionStyle;
			var name:String;
			
			// обрабатываем свойства
			var metaT:XMLList = type.getMetadata( true );
			var metaP:XMLList;
			var arg:XMLList;

			// выкидываем все exclude
			for each ( xml in metaT.( @name == 'Exclude' ) ) {
				arg = xml.arg;
				if ( arg.( @key == 'kind' && ( n = @value, n == 'property' || n == 'style' ) ).length() > 0 ) {
					// ставим именно null, так как Exclude может быть прописан у класса предка
					n = arg.( @key == 'name' ).@value;
					if ( n ) this._styles[ n ] = null;
				}
			}

			var t:Class;
			
			for each ( var prop:PropertyInfo in type.getProperties( false ) ) {

				name = prop.name.toString();
				if ( name in this._styles ) continue; // exclude

				metaP = prop.getMetadata();
				if ( metaP.length() > 0 ) metaP = null;

				t = null;

				if ( metaP ) {

					// если указать хоть какой-нить environment, то он явно не для нажего gui
					list = metaP.( @name == 'Inspectable' );
					if ( list.length() > 0 ) {
						arg = list[ 0 ].arg;
						if ( arg.length() > 0 ) {
							if ( arg.( @key == 'environment' && @value != '' ).length() > 0 ) {
								this._styles[ name ] = null;
								continue;
							}
						} else {
							arg = null;
						}
					} else {
						arg = null;
					}

					// указан кастомный тип
					list = metaP.( @name == 'StyleType' );
					if ( list.length() > 0 ) {
						list = list[ 0 ].arg.( @key == '' );
						if ( list.length() > 0 ) {
							t = StyleType.getValueByType( list[ 0 ].@value );
						}
					}

					if ( !t && arg ) { // посмотрим в Inspectable поле type
						list = arg.( @key == 'type' );
						if ( list.length() > 0 ) {
							n = list[ 0 ].@value;
							if ( n == 'Font Name' ) n = 'string'; // исключение
							t = StyleType.getValueByType( n );
						}
					}
					
				}

				if ( !t ) { // тип не указан
					t = StyleType.getClassByQName( prop.type );
				}

				if ( t ) {
					
					s = new SimpleStyle();
					s.type = t;
					
					if ( metaP && t === NumberValue ) { // нумбер полей может быть указанно PercentProxy
						list = metaP.( @name == 'PercentProxy' );
						if ( list.length() > 0 ) {
							list = list[ 0 ].arg.( @key == '' );
							if ( list.length() > 0 ) {
								n = list[ 0 ].@value;
								// проверям что там number
								if ( n in this._styles && this._styles[ n ] is SimpleStyle ) {
									t = this._styles[ n ].type;
								} else {
									prop = type.getMember( n ) as PropertyInfo;
									if ( prop ) {
										t = StyleType.getClassByQName( prop.type );
									}
								}
								if ( t === NumberValue ) {
									s.proxy = n;
									this._styles[ n ] = null;
								}
							}
						}
					}

					this._styles[ name ] = s;

				}

			}

			// создаём комплексные стили
			for each ( xml in metaT.( @name == 'ProxyStyle' ) ) {
				arg = xml.arg;
				list = arg.( @key == 'name' );
				if ( list.length() > 0 ) {
					name = list[ 0 ].@value;
					if ( !name || name in this._styles ) continue;

					if ( !type.hasMember( n ) ) { // нельзя перекрывать свойства стилями

						list = arg.( @key == '' ).@value;
						if ( list.length() > 0 ) {

							c = new CollectionStyle();
							for each ( xml in list ) {
								c.styles.push( xml );
							}
							if ( c.styles.length > 0 ) {
								this._styles[ n ] = c;
							}

						}

					}
				}
			}

		}

	}
	
}