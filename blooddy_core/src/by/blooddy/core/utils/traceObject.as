////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.utils.Dictionary;

	public function traceObject(object:Object):void {
		trace("======== >> =====");
		trace( var_dump( new Dictionary(), object ) );
		trace("======== << =====");
	}

}

import flash.utils.ByteArray;
import by.blooddy.core.utils.ByteArrayUtils;
import by.blooddy.core.utils.ObjectInfo;
import flash.utils.Dictionary;

internal function var_dump(hash:Dictionary, o:Object, char:String="\t", prefix:String=""):String {
	var result:String;
	if ( !( o is Object ) ) {
		result = 'null';
	} else if (
		o is Number ||
		o is Boolean
	) {
		result = o.toString();
	} else if ( o is String ) {
		result = '"' + o + '"';
	} else if ( o in hash ) {
		result = "@link";
	} else {
		hash[ o ] = true; // ADD
		if ( o is ByteArray ) {
			result = '[[\n' +
				ByteArrayUtils.dump( o as ByteArray ) + '\n' +
				prefix + ']]';
		} else if (
			o is XML ||
			o is XMLList
		) {
			result = '<<\n' +
				o.toString() + '\n' +
				prefix + '>>';
		} else {
			var info:ObjectInfo = ObjectInfo.getInfo( o );
			result = ( o is Array ? '[' : '{' ) + '\n';
			var members:Array = info.getMembers( ObjectInfo.MEMBER_PROPERTIES );
			var key:*;
			var new_prefix:String = prefix + char;
			const props:Dictionary = new Dictionary();
			for each ( var member:ObjectInfo in members ) {
				key = member.name;
				props[ key ] = true;
				result += new_prefix + key + ' : ' + var_dump( hash, o[ key ], char, new_prefix ) + '\n';
			}
			for ( key in o ) {
				if ( !( key in props ) ) {
					result += new_prefix + key + ' : ' + var_dump( hash, o[ key ], char, new_prefix ) + '\n';
				}
			}
			result += prefix + ( o is Array ? ']' : '}' );
		}
	}
	return result;
}