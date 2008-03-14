////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 BlooDHounD.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.utils {

	/**
	 * @return					XML с описанием вызываемого метода.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public function getCallerInfo():XML {
		var instance:String = ( new Error() ).getStackTrace().match(PATTERN_STACK)[2];
		if (instance) {
			var result:Array = instance.match(PATTERN_INSTANCE);
			var xml:XML = <xml />;
			var node:XML;
			if (result[2]) { // есть класс
				xml.setName("type");
				xml.@name = result[2];
				xml.node = <node />
				node = xml.node[0];
			} else {
				node = xml;
			}
			// свойстово
			if (result[4])	node.setName("accessor");
			// метод
			else			node.setName("method");
			node.@name = result[5];
			return xml;
		}
		return null;
	}

}

/**
 * @private
 */
internal const PATTERN_STACK:RegExp = /(?<=^\sat\s).+?(?=\(\))/gm;

/**
 * @private
 */
internal const PATTERN_INSTANCE:RegExp = /^((.+?)\$?\/)?((get|set)\s)?(.+?)$/;