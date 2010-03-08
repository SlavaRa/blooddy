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
	 * @created					07.03.2010 0:02:53
	 */
	public function describeTypeRDF(...args):XML {
		var list:Vector.<TypeInfo> = new Vector.<TypeInfo>();
		for each ( var o:Object in args ) {
			updateHash( new Dictionary(), list, TypeInfo.getInfo( o ) );
		}

		var result:XML = <RDF />;
		result.setNamespace( AbstractInfo.ns_rdf );
		result.addNamespace( AbstractInfo.ns_rdfs );
		result.addNamespace( AbstractInfo.ns_dc );
		result.addNamespace( AbstractInfo.ns_as3 );
		
		for each ( var info:TypeInfo in list ) {
			result.appendChild( info.toXML() );
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

	list.push( info );
	hash[ info ] = true;

	var names:Vector.<QName> = new Vector.<QName>();

	var t:ITypedInfo;

	// superClasses
	names = names.concat( info.getSuperclasses() );
	// interfaces
	names = names.concat( info.getInterfaces() );
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
		if ( !info || info in hash ) continue;
		updateHash( hash, list, info );
	}
}