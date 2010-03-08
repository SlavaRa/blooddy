////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.meta {

	import by.blooddy.core.utils.ClassUtils;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.03.2010 23:44:05
	 */
	public final class TypeInfo extends DefinitionInfo {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------
		
		use namespace $protected_info;

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function getInfo(o:Object):TypeInfo {
			var c:Class;
			if ( o is Class ) {
				c = o as Class;
			} else {
				c = o.constructor;
				if ( !c ) {
					c = ClassUtils.getClass( o );
					if ( !c ) return null;
				}
			}
			var result:TypeInfo = _HASH[ c ];
			if ( !result ) {
				_privateCall = true;
				_HASH[ c ] = result = new TypeInfo();
				result.parseClass( c );
				_privateCall = false;
			}
			return result;
		}

		public static function getInfoByName(o:*):TypeInfo {
			var c:Class;
			try {
				c = getDefinitionByName( o ) as Class;
			} catch ( e:Error ) {
			}
			if ( c ) {
				return getInfo( c );
			}
			return null;
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
		public function TypeInfo() {
			super();
			if ( !_privateCall ) throw new IllegalOperationError();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  superClasses
		//----------------------------------

		/**
		 * @private
		 */
		private const _superclasses_hash:Object = new Object();
		
		/**
		 * @private
		 */
		private const _superclasses_list:Vector.<QName> = new Vector.<QName>();
		
		//----------------------------------
		//  interfaces
		//----------------------------------
		
		/**
		 * @private
		 */
		private const _interfaces_hash:Object = new Object();
		
		/**
		 * @private
		 */
		private var _interfaces_list:Vector.<QName>;
		
		/**
		 * @private
		 */
		private const _interfaces_list_local:Vector.<QName> = new Vector.<QName>();
		
		//----------------------------------
		//  members
		//----------------------------------
		
		/**
		 * @private
		 */
		private const _members_hash:Object = new Object();
		
		/**
		 * @private
		 */
		private var _members_list:Vector.<MemberInfo>;
		
		/**
		 * @private
		 */
		private const _members_list_local:Vector.<MemberInfo> = new Vector.<MemberInfo>();
		
		//----------------------------------
		//  properties
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _properties_list:Vector.<PropertyInfo>;
		
		/**
		 * @private
		 */
		private const _properties_list_local:Vector.<PropertyInfo> = new Vector.<PropertyInfo>();
		
		//----------------------------------
		//  methods
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _methods_list:Vector.<MethodInfo>;
		
		/**
		 * @private
		 */
		private const _methods_list_local:Vector.<MethodInfo> = new Vector.<MethodInfo>();
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public function get parent():TypeInfo {
			return this._parent as TypeInfo;
		}

		/**
		 * @private
		 */
		private const _constructor:ConstructorInfo = new ConstructorInfo();
		
		public function get constructor():ConstructorInfo {
			return this._constructor;
		}

		/**
		 * @private
		 */
		private var _source:String;

		public function get source():String {
			return this._source;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  superClasses
		//----------------------------------
		
		public function hasSuperclass(o:*):Boolean {
			var n:String;
			if ( o is Class ) {
				n = getQualifiedClassName( o );
			} else if ( o is QName ) {
				n = o.toString();
			} else if ( o is String ) {
				n = o;
				// нормализуем
				if ( n.lastIndexOf( '::' ) < 0 ) {
					var i:int = n.lastIndexOf( '.' );
					if ( i > 0 ) {
						n = n.substr( 0, i ) + '::' + n.substr( i + 1 );
					}
				}
			} else {
				throw new ArgumentError();
			}
			return n in this._superclasses_hash;
		}
		
		public function getSuperclasses():Vector.<QName> {
			return this._superclasses_list.slice();
		}
		
		//----------------------------------
		//  interfaces
		//----------------------------------
		
		public function hasInterface(o:*):Boolean {
			var n:String;
			if ( o is Class ) {
				n = getQualifiedClassName( o );
			} else if ( o is QName ) {
				n = o.toString();
			} else if ( o is String ) {
				n = o;
				// нормализуем
				if ( n.lastIndexOf( '::' ) < 0 ) {
					var i:int = n.lastIndexOf( '.' );
					if ( i > 0 ) {
						n = n.substr( 0, i ) + '::' + n.substr( i + 1 );
					}
				}
			} else {
				throw new ArgumentError();
			}
			return n in this._interfaces_hash;
		}
		
		public function getInterfaces(all:Boolean=true):Vector.<QName> {
			if ( all ) {
				return this._interfaces_list.slice();
			} else {
				return this._interfaces_list_local.slice();
			}
		}
		
		//----------------------------------
		//  members
		//----------------------------------

		public function hasMember(name:*):Boolean {
			return String( name ) in this._members_hash;
		}

		public function getMembers(all:Boolean=true):Vector.<MemberInfo> {
			if ( all ) {
				return this._members_list.slice();
			} else {
				return this._members_list_local.slice();
			}
		}

		public function getMember(name:*):MemberInfo {
			if ( !name ) throw new ArgumentError();
			return this._members_hash[ String( name ) ];
		}
		
		//----------------------------------
		//  properties
		//----------------------------------
		
		public function getProperties(all:Boolean=true):Vector.<PropertyInfo> {
			if ( all ) {
				return this._properties_list.slice();
			} else {
				return this._properties_list_local.slice();
			}
		}
		
		//----------------------------------
		//  methods
		//----------------------------------
		
		public function getMethods(all:Boolean=true):Vector.<MethodInfo> {
			if ( all ) {
				return this._methods_list.slice();
			} else {
				return this._methods_list_local.slice();
			}
		}

		/**
		 * @private
		 */
		public override function toXML():XML {
			var xml:XML = super.toXML();
			xml.addNamespace( ns_rdfs );
			xml.addNamespace( ns_dc );
			xml.addNamespace( ns_as3 );

			xml.@ns_rdf::about = '#' + encodeURI( this._name.toString() );

			var resource:XML;
			var seq:XML;
			var x:XML;
			var i:uint, l:uint;

			// type
			x = <type>type</type>;
			x.setNamespace( ns_dc );
			xml.appendChild( x );

			// source
			if ( this._source ) {
				x = <source />;
				x.appendChild( this._source );
				x.setNamespace( ns_dc );
				xml.appendChild( x );
			}

			// superClasses
			l = this._superclasses_list.length;
			if ( l > 0 ) {
				resource = <extendsClass />
				resource.setNamespace( ns_as3 );

				seq = <Seq />
				seq.setNamespace( ns_rdf );
				
				for ( i=0; i<l; i++ ) {
					x = <li />
					x.setNamespace( ns_rdf );
					x.@ns_rdf::resource = '#' + encodeURI( this._superclasses_list[ i ].toString() );

					seq.appendChild( x );
				}

				resource.appendChild( seq );

				xml.appendChild( resource );
			}

			// interfaces
			l = this._interfaces_list_local.length;
			if ( l > 0 ) {
				resource = <implementsInterface />
				resource.setNamespace( ns_as3 );
				
				seq = <Bag />
				seq.setNamespace( ns_rdf );
				
				for ( i=0; i<l; i++ ) {
					x = <li />
					x.setNamespace( ns_rdf );
					x.@ns_rdf::resource = '#' + encodeURI( this._interfaces_list_local[ i ].toString() );
					
					seq.appendChild( x );
				}
				
				resource.appendChild( seq );
				
				xml.appendChild( resource );
			}

			// constructor
			if ( l > 0 ) {
				resource = this._constructor.toXML();
				if ( resource.hasComplexContent() ) {
					xml.appendChild( resource );
				}
			}

			// properties
			if ( this._members_list_local.length > 0 ) {
				resource = <members />
				resource.setNamespace( ns_as3 );
				resource.@ns_rdf::parseType = 'Collection';
				for each ( var m:MemberInfo in this._members_list_local ) {
					resource.appendChild( m.toXML() );
				}
				xml.appendChild( resource );
			}

			return xml;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function parseClass(c:Class):void {
			this.parseXML( describeType( c ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected_info override function parseXML(xml:XML):void {
			xml = xml.factory[ 0 ]; // дергаем factory
			this._name = parseType( xml.@type.toString() ); // выдёргиваем имя
			var list:XMLList, x:XML;
			var n:String;
			var q:QName;
			// superclasses
			// собираем суперклассы
			list = xml.extendsClass;
			for each ( x in list ) {
				n = x.@type.toString();
				this._superclasses_hash[ n ] = true;
				this._superclasses_list.push( parseType( n ) );
			}
			// parent
			// надо найти нашего папу
			var parent:TypeInfo;
			if ( this._superclasses_list.length > 0 ) {
				var o:Class;
				var i:uint = 0;
				do {
					try {
						o = getDefinitionByName( this._superclasses_list[ i ].toString() ) as Class;
					} catch ( e:Error ) { // промежуточный класс может быть неоступен из области видимости, мы его проустим
					}
				} while ( !o && ++i < this._superclasses_list.length );
				if ( o ) {
					this._parent = parent = getInfo( o ); // папочка найден
				}
			}
			// interfaces
			// собираем список интерфейсов на основании списка нашего папы
			list = xml.implementsInterface;
			this._interfaces_list = ( parent ? parent._interfaces_list.slice() : new Vector.<QName>() ); // копируем 
			for each ( x in list ) {
				n = x.@type.toString();
				if ( parent && !( n in parent._interfaces_hash ) ) { // добавляем только недостающие
					q = parseType( n );
					this._interfaces_list_local.push( q );
					this._interfaces_list.push( q );
				}
				this._interfaces_hash[ n ] = true;
			}
			// metadata
			// запускаем дефолтный парсер
			super.parseXML( xml );
			// members
			// надо распарсить всех наших многочленов
			var name:String = this._name.toString();
			var dn:String;
			this._members_list = ( parent ? parent._members_list.slice() : new Vector.<MemberInfo>() ); // копируем список
			// properties
			this._properties_list = ( parent ? parent._properties_list.slice() : new Vector.<PropertyInfo>() ); // копируем список
			var p:PropertyInfo, pp:PropertyInfo;
			list = xml.variable + xml.constant + xml.accessor; // выдёргиваем все свойства
			for each ( x in list ) {
				n = getName( x ).toString();
				if ( parent && n in parent._members_hash ) { // ищем свойство у родителя
					pp = parent._members_hash[ n ] as PropertyInfo;
				} else {
					pp = null;
				}
				dn = x.@declaredBy.toString();
				if ( !dn || dn == name ) { // это свойство объявленно у нас
					p = new PropertyInfo();
					p._owner = this;
					p._parent = pp;
					p.parseXML( x );
					if ( pp && pp._metadata == p._metadata && pp.access == p.access ) { // наше свойство неотличается от ролительского
						p = pp; // переиспользуем: нечего создавать лишние связи
					}
				} else {
					p = pp;
				}
				if ( p !== pp ) { // добавляем только наши свойства
					this._members_list_local.push ( p );
					this._members_list.push( p );
					this._properties_list_local.push( p );
					this._properties_list.push( p );
				}
				this._members_hash[ n ] = p;
			}
			// methods
			this._methods_list = ( parent ? parent._methods_list.slice() : new Vector.<MethodInfo>() ); // копируем список
			var m:MethodInfo, mm:MethodInfo;
			list = xml.method;
			for each ( x in list ) {
				n = getName( x ).toString();
				if ( parent && n in parent._members_hash ) { // ищем метод у папы
					mm = parent._members_hash[ n ] as MethodInfo;
				} else {
					mm = null;
				}
				dn = x.@declaredBy.toString();
				if ( !dn || dn == name ) { // метод объявлен у нас
					m = new MethodInfo();
					m._owner = this;
					m._parent = mm;
					m.parseXML( x );
					if ( mm && mm._metadata == m._metadata ) { // метод ничем не отличается от родительского
						m = mm;
					}
				} else {
					m = mm;
				}
				if ( m !== mm ) { // добавляем в списки только наших
					this._members_list_local.push ( m );
					this._members_list.push( m );
					this._methods_list_local.push( m );
					this._methods_list.push( m );
				}
				this._members_hash[ n ] = m;
			}
			// constructor
			// распишем конструктор
			list = xml.constructor;
			if ( list.length() > 0 ) {
				this._constructor.parseXML( list[ 0 ] );
			}
			// source
			list = xml.metadata.( @name == '__go_to_definition_help' );
			if ( list.length() > 0 ) {
				list = list[ 0 ].arg.( @key == 'file' );
				if ( list.length() > 0 ) {
					this._source = list[ 0 ].@value.toString();
				}
			}
		}

	}

}