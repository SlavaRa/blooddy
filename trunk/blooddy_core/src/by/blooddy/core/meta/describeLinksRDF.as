////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.meta {

	import flash.utils.Dictionary;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					07.03.2010 21:37:43
	 */
	public function describeLinksRDF(...args):XML {
		var list:Vector.<TypeInfo> = new Vector.<TypeInfo>();
		var hash:Dictionary = new Dictionary();
		for each ( var o:Object in args ) {
			updateHash( hash, list, TypeInfo.getInfo( o ) );
		}

		const ns_rdf:Namespace = AbstractInfo.ns_rdf;
		const ns_dc:Namespace = AbstractInfo.ns_dc;
		const ns_as3:Namespace = AbstractInfo.ns_as3;
		
		var result:XML = <RDF />;
		result.setNamespace( ns_rdf );
		result.addNamespace( ns_dc );
		result.addNamespace( ns_as3 );

		var desc:XML;
		var x:XML;
		var seq:XML;
		var li:XML;
		
		for each ( var info:TypeInfo in list ) {
			// пробегаемся по списку и строим RDF
			desc = <Description />;
			desc.setNamespace( ns_rdf );
			desc.@ns_rdf::about = '#' + encodeURI( info.name.toString() );

			// title
			x = <title />;
			x.setNamespace( ns_dc );
			x.appendChild( info.name.toString() );
			desc.appendChild( x );
			
			// links
			x = <links />;
			x.setNamespace( ns_as3 );

			seq = <Bag />;
			seq.setNamespace( ns_rdf );

			list = hash[ info ];
			for each ( info in list ) {
				li = <li />;
				li.setNamespace( ns_rdf );
				li.@ns_rdf::resource = '#' + encodeURI( info.name.toString() );
				seq.appendChild( li );
			}

			x.appendChild( seq );
			
			desc.appendChild( x );

			result.appendChild( desc );
			
		}
		
		return result;
	}
	
}

import by.blooddy.core.meta.ITypedInfo;
import by.blooddy.core.meta.MethodInfo;
import by.blooddy.core.meta.TypeInfo;

import flash.utils.Dictionary;

/**
 * @private
 */
internal function updateHash(hash:Dictionary, list:Vector.<TypeInfo>, info:TypeInfo):void {
	
	var hash2:Dictionary = new Dictionary();
	var list2:Vector.<TypeInfo> = new Vector.<TypeInfo>();

	hash[ info ] = list2;
	list.push( info );
	
	
	var t:ITypedInfo;
	
	var names:Vector.<QName>;
	// interfaces
	names = info.getInterfaces( false );
	// superClass
	if ( info.parent ) {
		names.push( info.parent.name );
	}
	// properties
	for each ( t in info.getProperties( false ) ) {
		names.push( t.type );
	}
	// methods
	for each ( var m:MethodInfo in info.getMethods( false ) ) {
		names.push( m.returnType );
		for each ( t in m.getParameters() ) {
			names.push( t.type );
		}
	}
	// constructor
	for each ( t in info.constructor.getParameters() ) {
		names.push( t.type );
	}
	
	// вызываем апдэйтилку
	for each ( var n:QName in names ) {
		info = TypeInfo.getInfoByName( n );
		if ( !info || info in hash2 ) continue;
		hash2[ info ] = true;
		list2.push( info );
		if ( !info || info in hash ) continue;
		updateHash( hash, list, TypeInfo.getInfoByName( n ) );
	}
}