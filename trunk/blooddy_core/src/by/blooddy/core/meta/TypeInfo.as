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
	import flash.system.Capabilities;
	
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
		//  types
		//----------------------------------
		
		/**
		 * @private
		 */
		private const _hash_types:Object = new Object();
		
		/**
		 * @private
		 */
		private var _list_types:Vector.<QName>;
		
		//----------------------------------
		//  superclasses
		//----------------------------------

		/**
		 * @private
		 */
		private const _hash_superclasses:Object = new Object();
		
		/**
		 * @private
		 */
		private const _list_superclasses:Vector.<QName> = new Vector.<QName>();
		
		//----------------------------------
		//  interfaces
		//----------------------------------

		/**
		 * @private
		 */
		private const _hash_interfaces:Object = new Object();
		
		/**
		 * @private
		 */
		private var _list_interfaces:Vector.<QName>;
		
		/**
		 * @private
		 */
		private const _list_interfaces_local:Vector.<QName> = new Vector.<QName>();
		
		//----------------------------------
		//  members
		//----------------------------------
		
		/**
		 * @private
		 */
		private const _hash_members:Object = new Object();
		
		/**
		 * @private
		 */
		private var _list_members:Vector.<MemberInfo>;
		
		/**
		 * @private
		 */
		private const _list_members_local:Vector.<MemberInfo> = new Vector.<MemberInfo>();
		
		//----------------------------------
		//  properties
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _list_properties:Vector.<PropertyInfo>;
		
		/**
		 * @private
		 */
		private const _list_properties_local:Vector.<PropertyInfo> = new Vector.<PropertyInfo>();
		
		//----------------------------------
		//  methods
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _list_methods:Vector.<MethodInfo>;
		
		/**
		 * @private
		 */
		private const _list_methods_local:Vector.<MethodInfo> = new Vector.<MethodInfo>();
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _target:Class;

		/**
		 * @private
		 */
		private var _targetPrototype:Object;
		
		public function get target():Class {
			return this._target;
		}

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
		//  types
		//----------------------------------
		
		public function hasType(o:*):Boolean {
			if ( o is Class ) {
				return o.prototype.isPrototypeOf( this._targetPrototype );
			} else if ( o is TypeInfo ) {
				return ( o as TypeInfo )._targetPrototype.isPrototypeOf( this._targetPrototype );
			} else {
				var n:String;
				if ( o is QName ) {
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
				return n in this._hash_types;
			}
		}
		
		public function getTypes():Vector.<QName> {
			return this._list_types.slice();
		}
		
		//----------------------------------
		//  superclasses
		//----------------------------------
		
		public function hasSuperclass(o:*):Boolean {
			if ( o is Class ) {
				return o.prototype.isPrototypeOf( this._targetPrototype );
			} else if ( o is TypeInfo ) {
				return ( o as TypeInfo )._targetPrototype.isPrototypeOf( this._targetPrototype );
			} else {
				var n:String;
				if ( o is QName ) {
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
				return n in this._hash_superclasses;
			}
		}
		
		public function getSuperclasses():Vector.<QName> {
			return this._list_superclasses.slice();
		}

		//----------------------------------
		//  interfaces
		//----------------------------------

		public function hasInterface(o:*):Boolean {
			if ( o is Class ) {
				return o.prototype.isPrototypeOf( this._targetPrototype );
			} else if ( o is TypeInfo ) {
				return ( o as TypeInfo )._targetPrototype.isPrototypeOf( this._targetPrototype );
			} else {
				var n:String;
				if ( o is QName ) {
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
				return n in this._hash_interfaces;
			}
		}

		public function getInterfaces(all:Boolean=true):Vector.<QName> {
			if ( all ) {
				return this._list_interfaces.slice();
			} else {
				return this._list_interfaces_local.slice();
			}
		}

		//----------------------------------
		//  members
		//----------------------------------

		public function hasMember(name:*):Boolean {
			return String( name ) in this._hash_members;
		}

		public function getMembers(all:Boolean=true):Vector.<MemberInfo> {
			if ( all ) {
				return this._list_members.slice();
			} else {
				return this._list_members_local.slice();
			}
		}

		public function getMember(name:*):MemberInfo {
			if ( !name ) throw new ArgumentError();
			return this._hash_members[ String( name ) ];
		}
		
		//----------------------------------
		//  properties
		//----------------------------------
		
		public function getProperties(all:Boolean=true):Vector.<PropertyInfo> {
			if ( all ) {
				return this._list_properties.slice();
			} else {
				return this._list_properties_local.slice();
			}
		}
		
		//----------------------------------
		//  methods
		//----------------------------------
		
		public function getMethods(all:Boolean=true):Vector.<MethodInfo> {
			if ( all ) {
				return this._list_methods.slice();
			} else {
				return this._list_methods_local.slice();
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
			l = this._list_superclasses.length;
			if ( l > 0 ) {
				resource = <extendsClass />
				resource.setNamespace( ns_as3 );

				seq = <Seq />
				seq.setNamespace( ns_rdf );
				
				for ( i=0; i<l; i++ ) {
					x = <li />
					x.setNamespace( ns_rdf );
					x.@ns_rdf::resource = '#' + encodeURI( this._list_superclasses[ i ].toString() );

					seq.appendChild( x );
				}

				resource.appendChild( seq );

				xml.appendChild( resource );
			}

			// interfaces
			l = this._list_interfaces_local.length;
			if ( l > 0 ) {
				resource = <implementsInterface />
				resource.setNamespace( ns_as3 );
				
				seq = <Bag />
				seq.setNamespace( ns_rdf );
				
				for ( i=0; i<l; i++ ) {
					x = <li />
					x.setNamespace( ns_rdf );
					x.@ns_rdf::resource = '#' + encodeURI( this._list_interfaces_local[ i ].toString() );
					
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
			if ( this._list_members_local.length > 0 ) {
				resource = <members />
				resource.setNamespace( ns_as3 );
				resource.@ns_rdf::parseType = 'Collection';
				for each ( var m:MemberInfo in this._list_members_local ) {
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
			this._target = c;
			this._targetPrototype = c.prototype;
			this.parseXML( describeType( c ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected_info override function parseXML(xml:XML):void {

			// весь код написанный в этом методе очень запутанный
			// сложные конструкции используются с целью сэкономить память
			// и исключиь дополнительную обработку
			
			xml = xml.factory[ 0 ]; // дергаем factory

			// name
			this._name = parseType( xml.@type.toString() ); // выдёргиваем имя

			var list:XMLList, x:XML;
			var n:String;
			var i:int;

			// superclasses
			// собираем суперклассы
			list = xml.extendsClass;
			for each ( x in list ) {
				n = x.@type.toString();
				this._hash_types[ n ] = true;
				this._hash_superclasses[ n ] = true;
				this._list_superclasses.push( parseType( n ) );
			}

			// parent
			// надо найти нашего папу
			var parent:TypeInfo;
			if ( this._list_superclasses.length > 0 ) {
				var o:Class;
				i = 0;
				do {
					try {
						o = getDefinitionByName( this._list_superclasses[ i ].toString() ) as Class;
					} catch ( e:Error ) { // промежуточный класс может быть неоступен из области видимости, мы его проустим
					}
				} while ( !o && ++i < this._list_superclasses.length );
				if ( o ) {
					this._parent = parent = getInfo( o ); // папочка найден
				}
			}

			// interfaces
			// собираем список интерфейсов на основании списка нашего папы
			list = xml.implementsInterface;
			if ( parent ) {

				for each ( x in list ) {
					n = x.@type.toString();
					if ( !( n in parent._hash_interfaces ) ) { // добавляем только "наши" интерфейсы
						this._list_interfaces_local.push( parseType( n ) );
					}
					this._hash_types[ n ] = true;
					this._hash_interfaces[ n ] = true;
				}

				// общий список интерфейсов
				// если локальный список пуст, то берём родительский список
				// иначе пытаемся склеить, если родительский не пуст
				this._list_interfaces = (
					this._list_interfaces_local.length <= 0
					?	parent._list_interfaces
					:	( parent._list_interfaces.length <= 0
						?	this._list_interfaces_local
						:	this._list_interfaces_local.concat( parent._list_interfaces )
					)
				);

			} else {

				for each ( x in list ) {
					n = x.@type.toString();
					this._list_interfaces_local.push( parseType( n ) );
					this._hash_types[ n ] = true;
					this._hash_interfaces[ n ] = true;
				}

				this._list_interfaces = this._list_interfaces_local;

			}

			// types
			this._list_types = (
				this._list_interfaces.length <= 0
				?	this._list_superclasses
				:	( this._list_superclasses.length <= 0
					?	this._list_interfaces
					:	this._list_interfaces.concat( this._list_superclasses )
					)
			);

			// metadata
			// запускаем дефолтный парсер
			super.parseXML( xml );

			// members
			// надо распарсить всех наших многочленов
			var name:String = this._name.toString();
			var dn:String;

			// properties
			var p:PropertyInfo;		// окальное свойство
			var pp:PropertyInfo;	// родительское свойство
			list = xml.variable + xml.constant + xml.accessor; // выдёргиваем все свойства
			for each ( x in list ) {
				n = parseName( x ).toString();	// имя свойства
				if ( parent && n in parent._hash_members ) { // ищем свойство у родителя
					pp = parent._hash_members[ n ] as PropertyInfo;
				} else {
					pp = null;
				}
				dn = x.@declaredBy.toString();
				if ( !dn || dn == name ) { // это свойство объявленно/переопределнно у нас
					p = new PropertyInfo();
					p.parseXML( x );
					// если наше свойство неотличается от ролительского
					// то используем родительское свойство
					if ( pp && pp._metadata == p._metadata && pp.access == p.access ) {
						p = pp; // переиспользуем: нечего создавать лишние связи
					} else {
						p._owner = this;
						p._parent = pp;
					}
				} else {
					p = pp;
				}
				if ( p !== pp ) { // добавляем только наши свойства
					if ( pp ) {
						if ( !this._list_properties ) {
							this._list_properties = parent._list_properties.slice();
							this._list_members = parent._list_members.slice();
						}
						i = this._list_properties.lastIndexOf( pp );
						this._list_properties.splice( i, 1 );
						i = this._list_members.lastIndexOf( pp );
						this._list_members.splice( i, 1 );
					}
					this._list_properties_local.push( p );
					this._list_members_local.push( p );
				}
				this._hash_members[ n ] = p;
			}
			this._list_properties = (
				this._list_properties
				?	this._list_properties_local.concat( this._list_properties )
				:	( parent && parent._list_properties.length > 0
					?	this._list_properties_local.concat( parent._list_properties )
					:	this._list_properties_local
					)
			);

			// methods
			var m:MethodInfo, mm:MethodInfo;
			list = xml.method;
			for each ( x in list ) {
				n = parseName( x ).toString();
				if ( parent && n in parent._hash_members ) { // ищем метод у папы
					mm = parent._hash_members[ n ] as MethodInfo;
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
					if ( mm ) {
						if ( !this._list_methods ) this._list_methods = parent._list_methods.slice();
						i = this._list_methods.lastIndexOf( mm );
						this._list_methods.splice( i, 1 );
						if ( !this._list_members ) this._list_members = parent._list_members.slice();
						i = this._list_members.lastIndexOf( mm );
						this._list_members.splice( i, 1 );
					}
					this._list_methods_local.push( m );
					this._list_members_local.push( m );
				}
				this._hash_members[ n ] = m;
			}
			this._list_methods = (
				this._list_methods
				?	this._list_methods_local.concat( this._list_methods )
				:	( parent && parent._list_methods.length > 0
					?	this._list_methods_local.concat( parent._list_methods )
					:	this._list_methods_local
					)
			);

			// members
			this._list_members = (
				this._list_members
					?	this._list_members_local.concat( this._list_members )
					:	( parent && parent._list_members.length > 0
						?	this._list_members_local.concat( parent._list_members )
						:	this._list_members_local
						)
			);

			// constructor
			// распишем конструктор
			list = xml.constructor;
			if ( list.length() > 0 ) {
				this._constructor.parseXML( list[ 0 ] );
			}

			if ( Capabilities.isDebugger ) {
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

}