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
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.03.2010 23:44:05
	 */
	public class TypeInfo extends DefinitionInfo {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------
		
		use namespace $protected_inf;

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
		
		/**
		 * @private
		 */
		private const _members_hash:Object = new Object();
		
		/**
		 * @private
		 */
		private const _members_list:Vector.<MemberInfo> = new Vector.<MemberInfo>();
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _parent:TypeInfo;
		
		public function get parent():TypeInfo {
			return this._parent;
		}

		/**
		 * @private
		 */
		private const _superClasses:Vector.<QName> = new Vector.<QName>();

		public function get superClasses():Vector.<QName> {
			return this._superClasses.slice();
		}
		
		/**
		 * @private
		 */
		private const _interfaces:Vector.<QName> = new Vector.<QName>();

		public function get interfaces():Vector.<QName> {
			return this._interfaces;
		}

		/**
		 * @private
		 */
		private const _constructor:ConstructorInfo = new ConstructorInfo();
		
		public function get constructor():ConstructorInfo {
			return this._constructor;
		}

		public function get members():Vector.<MemberInfo> {
			return this._members_list.slice();
		}
		
		/**
		 * @private
		 */
		private const _properties:Vector.<PropertyInfo> = new Vector.<PropertyInfo>();
		
		public function get properties():Vector.<PropertyInfo> {
			return this._properties.slice();
		}
		
		/**
		 * @private
		 */
		private const _methods:Vector.<MethodInfo> = new Vector.<MethodInfo>();
		
		public function get methods():Vector.<MethodInfo> {
			return this._methods.slice();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getMember(name:*):MemberInfo {
			if ( !name ) throw new ArgumentError();
			return this._members_hash[ name ];
		}

		public override function toXML():XML {
			var xml:XML = super.toXML();
			xml.addNamespace( ns_as3 );
			xml.addNamespace( ns_dc );

			xml.@ns_rdf::about = typeURI( this._name );

			var resource:XML;
			var seq:XML;
			var x:XML;
			var i:uint, l:uint;

			// type
			x = <type>type</type>;
			x.setNamespace( ns_dc );
			xml.appendChild( x );
			
			// superClasses
			l = this._superClasses.length;
			if ( l > 0 ) {
				resource = <extendsClass />
				resource.setNamespace( ns_as3 );

				seq = <Seq />
				seq.setNamespace( ns_rdf );
				
				for ( i=0; i<l; i++ ) {
					x = <li />
					x.setNamespace( ns_rdf );
					x.@ns_rdf::resource = typeURI( this._superClasses[ i ] );

					seq.appendChild( x );
				}

				resource.appendChild( seq );

				xml.appendChild( resource );
			}

			// interfaces
			l = this._interfaces.length;
			if ( l > 0 ) {
				resource = <implementsInterface />
				resource.setNamespace( ns_as3 );
				
				seq = <Bag />
				seq.setNamespace( ns_rdf );
				
				for ( i=0; i<l; i++ ) {
					x = <li />
					x.setNamespace( ns_rdf );
					x.@ns_rdf::resource = typeURI( this._interfaces[ i ] );
					
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
			if ( this._members_list.length > 0 ) {
				resource = <members />
				resource.setNamespace( ns_as3 );
				resource.@ns_rdf::parseType = 'Collection';
				for each ( var m:MemberInfo in this._members_list ) {
					if ( this._name == m.owner.name ) {
						resource.appendChild( m.toXML() );
					}
				}
				xml.appendChild( resource );
			}


			return xml;
		}
/*

<?xml version="1.0" encoding="UTF-8" ?>
<rdf:RDF xml:lang="ru"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:as3="http://adobe.com/AS3/2006/builtin#"
>
<rdf:Description rdf:about="by.blooddy.core.display.resource::MainResourceSprite">

</rdf:Description>

*/
		
private var x:XML = <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
   <rdf:Description rdf:about="" xmlns:shared="http://timezero.com/library/shared/">
    <shared:library rdf:parseType="Resource">
      <shared:domain rdf:resource="lib/graphics/user/shared/weapon/man/dizarm.swf"/>
      <shared:definition>
        <rdf:Bag>
          <rdf:li>x0000</rdf:li>
          <rdf:li>x001o</rdf:li>
          <rdf:li>x003c</rdf:li>
          <rdf:li>x0050</rdf:li>
        </rdf:Bag>
      </shared:definition>
    </shared:library>
  </rdf:Description>
</rdf:RDF>
		
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

		$protected_inf override function parseXML(xml:XML):void {
			//trace( xml );
			super.parseXML( xml );
			this._name = parseType( xml.@name.toString() );
			xml = xml.factory[ 0 ];
			var list:XMLList, x:XML;
			// superclasses
			list = xml.extendsClass;
			for each ( x in list ) {
				this._superClasses.push( parseType( x.@type.toString() ) );
			}
			// interfaces
			list = xml.implementsInterface;
			for each ( x in list ) {
				this._interfaces.push( parseType( x.@type.toString() ) );
			}
			// parent
			if ( this._superClasses.length > 0 ) {
				var o:Class;
				try {
					o = getDefinitionByName( this._superClasses[ 0 ].toString() ) as Class;
				} catch ( e:Error ) {
				}
				if ( o ) {
					this._parent = getInfo( o );
				}
			}
			// members
			var name:String = this._name.toString();
			var n:String;
			// properties
			var p:PropertyInfo;
			list = xml.variable + xml.constant + xml.accessor;
			for each ( x in list ) {
				n = x.@declaredBy.toString();
				if ( !n || n == name ) {
					p = new PropertyInfo();
					p._owner = this;
					p.parseXML( x );
				} else {
					n = x.@uri.toString();
					p = this._parent._members_hash[ ( n ? n + '::' : '' ) + x.@name.toString() ];
				}
				this._members_hash[ p._name.toString() ] = p;
				this._members_list.push( p );
				this._properties.push( p );
			}
			// methods
			var m:MethodInfo;
			list = xml.method;
			for each ( x in list ) {
				n = x.@declaredBy.toString();
				if ( !n || n == name ) {
					m = new MethodInfo();
					m._owner = this;
					m.parseXML( x );
				} else {
					n = x.@uri.toString();
					m = this._parent._members_hash[ ( n ? n + '::' : '' ) + x.@name.toString() ];
				}
				this._members_hash[ m._name.toString() ] = m;
				this._members_list.push( m );
				this._methods.push( m );
			}
			// constructor
			list = xml.constructor;
			if ( list.length() > 0 ) {
				this._constructor.parseXML( list[ 0 ] );
			}
		}

	}

}