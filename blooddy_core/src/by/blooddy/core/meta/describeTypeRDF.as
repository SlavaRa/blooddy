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
		var result:XML;
		var hash:Dictionary = new Dictionary();
		for each ( var o:Object in args ) {
			updateHash( hash, TypeInfo.getInfo( o ) );
		}
		return result;
	}
	
}

import flash.utils.Dictionary;
import by.blooddy.core.meta.TypeInfo;

internal function updateHash(hash:Dictionary, o:TypeInfo):void {


	
}