////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;

	/**
	 * Класс знования инфы о классе.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					objectinfo, object, info
	 */
	public class ObjectInfo {

		public static const META_ALL:uint = 0;

		public static const META_FIRST:uint = 1;

		public static const META_SELF:uint = 2;

		public static const MEMBER_METHODS:uint = 1;

		public static const MEMBER_PROPERTIES:uint = 2;

		public static const MEMBER_ALL:uint = MEMBER_PROPERTIES | MEMBER_METHODS;

		public static function getInfo(target:Object):ObjectInfo {
			var c:Class;
			if (!target) {
				return null;
			} else if (target is Class) {
				c = target as Class;
			} else {
				c = target.constructor as Class;
			}
			var info:ObjectInfo = _HASH[c];
			if (!info) {
				info = new ObjectInfo();
				info.parseXML( describeType( c ) );
				_HASH[c] = info;
			}
			return info;
		}
		
		public static function clearInfo(target:Object):void {
			var c:Class;
			if (!target) {
				return;
			} else if (target is Class) {
				c = target as Class;
			} else {
				c = target.constructor as Class;
			}
			var info:ObjectInfo = _HASH[c];
			if (info) delete _HASH[c];				
		}
		
		private static const _HASH:Dictionary = new Dictionary( true );

		public function ObjectInfo() {
			super();
		}

		private var _meta:XMLList = new XMLList();

		private const _properties:Object = new Object();

		private const _methods:Object = new Object();

		public function get localName():String {
			return this._name.localName;
		}

		public function get namespace():Namespace {
			return this._name.uri;
		}

		private var _name:QName;

		public function get name():QName {
			return this._name;
		}

		private var _parent:ObjectInfo;

		public function get parent():ObjectInfo {
			if (!this._parent && this._superclasses.length>0) {
				this._parent = getInfo( getDefinitionByName( this._superclasses[0] as String ) );
			}
			return this._parent;
		}

		private var _type:QName;

		public function get type():QName {
			return this._type;
		}

		public function hasMember(name:Object, pattern:uint=0):Boolean {
			var n:String;
			if ( name is QName ) n = ( name as QName ).toString();
			else if ( name is String ) n = name as String;
			else return false;
			if (n in this._properties || n in this._methods) return true;
			else if (pattern!=META_SELF && this._superclasses.length>0) return this.parent.hasMember( n );
			return false;
		}

		public function getMember(name:String, pattern:uint=0):ObjectInfo {
			var n:String;
			if ( name is QName ) n = ( name as QName ).toString();
			else if ( name is String ) n = name as String;
			else return null;
			if ( n in this._properties ) {
				return this._properties[n] as ObjectInfo;
			} else if ( n in this._methods ) {
				return this._methods[n] as ObjectInfo;
			} else if ( pattern!=META_SELF && this._superclasses.length>0 ) {
				return this.parent.getMember( n );
			}
			return null;
		}

		[ArrayElementType("by.blooddy.core.utils.ObjectInfo")]
		public function getMembers(type:uint=7, pattern:uint=0):Array {
			var hash:HashArray = new HashArray();
			this.$addMembers(hash, type, pattern);
			return hash.toArray();
		}

		private function $addMembers(hash:HashArray, type:uint=7, pattern:uint=0):void {
			var name:String;
			if ( type & MEMBER_PROPERTIES ) {
				for (name in this._properties) {
					if ( !( name in hash ) ) hash[name] = this._properties[name];
				}
			}
			if ( type & MEMBER_METHODS ) {
				for (name in this._properties) {
					if ( !( name in hash ) ) hash[name] = this._methods[name];
				}
			}
			if (pattern == META_ALL && this._superclasses.length>0) {
            	this.parent.$addMembers(hash, type, pattern);
            }
		}

		public function hasMetadata(name:String, pattern:uint=0):Boolean {
			return this.getMetadata(name, pattern).length()>0;
		}

		public function getMetadata(name:String, pattern:uint=0):XMLList {
			var result:XMLList = this._meta.(@name==name).copy();
			if ( ( pattern==META_ALL || ( pattern==META_FIRST && result.length()<=0 ) ) && this._superclasses.length>0 ) result += this.parent.getMetadata(name);
			return result;
		}

		private var _superclasses:Array = new Array();

		private static const _CLASS_NAME_PATTERN:RegExp = /\.(?=[^\.]+$)/;

		public function hasSuperclass(c:Object):Boolean {
			var name:String;
			if ( c is Class ) {
				return (c as Class).prototype.isPrototypeOf(
					getDefinitionByName( this._name.toString() ).prototype
				);			
			}

			if ( c is String ) {
				name = c as String;
				if ( name.lastIndexOf("::") < 0 ) {
					name = name.replace( _CLASS_NAME_PATTERN, "::" );
				}
			} else throw new ArgumentError();
			return this._name.toString() == name || this._superclasses.indexOf(name)>=0;
		}

		public function getSuperclasses():Array {
			return this._superclasses.slice();
		}

		private var _interfaces:Array = new Array();

		public function hasInterface(c:Object):Boolean {
			var name:String;
			if (c is Class) name = getQualifiedClassName( c );
			else if (c is String) {
				name = c as String;
				if (name.lastIndexOf("::")<0) {
					name = name.replace( _CLASS_NAME_PATTERN, "::");
				}
			}
			else throw new ArgumentError();
			return this._interfaces.indexOf(name)>=0
		}

		public function getInterfaces():Array {
			return this._interfaces.slice();
		}

		private function parseXML(description:XML):void {
			description = description.factory[0];
			var type:Array = description.@type.toString().split("::");
			if (type.length<2) {
				this._name = new QName( new Namespace( "" ), type[0] );
			} else {
				this._name = new QName( new Namespace( type[0] ), type[1] );
			}
			this._type = new QName( new Namespace( "" ), "Class" );
			var xml:XML, list:XMLList, n:String, info:ObjectInfo;
			this._meta = description.metadata.copy();
			list = description.*.( ( n = name().toString() ) && ( n=="variable" || n=="constant" || n=="accessor" ) );
			for each (xml in list) {
				n = xml.@declaredBy.toString();
				if (!n || n==this._name.toString()) { // наше творение
					info = new ObjectInfo();
					info._name = new QName( new Namespace( xml.@uri.toString() ), xml.@name.toString() );
					info._meta = xml.metadata.copy();
					type = xml.@type.toString().split("::");
					if (type.length<2) {
						info._type = new QName( new Namespace( "" ), type[0] );
					} else {
						info._type = new QName( new Namespace( type[0] ), type[1] );
					}
					this._properties[ info._name.toString() ] = info;
				}
			}
			list = description.method;
			for each (xml in list) {
				n = xml.@declaredBy.toString();
				if (!n || n==this._name.toString()) { // наше творение
					info = new ObjectInfo();
					info._name = new QName( new Namespace( xml.@uri.toString() ), xml.@name.toString() );
					info._meta = xml.metadata.copy();
					info._type = new QName( new Namespace( "" ), "Function" );
					this._methods[ info._name.toString() ] = info;
				}
			}
			list = description.extendsClass.@type;
			for each (xml in list) {
				this._superclasses.push( xml.toString() );
			}
			list = description.implementsInterface.@type;
			for each (xml in list) {
				this._interfaces.push( xml.toString() );
			}
		}

	}

}