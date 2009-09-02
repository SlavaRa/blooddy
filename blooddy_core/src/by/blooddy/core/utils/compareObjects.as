////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public function compareObjects(o1:Object, o2:Object):Boolean {
		if ( o1 === o2 ) return true;
		if ( o1 == o2 ) return true;

		if ( !o1 || !o2 ) return false;
		if ( o1.constructor !== o2.constructor ) return false;

		if ( o1 is IEquable ) {
			return ( o1 as IEquable ).equals( o2 );
		} else if ( o2 is IEquable ) {
			return ( o2 as IEquable ).equals( o1 );
		}

		// проверим нединамические свойства
		var arr:Array = ObjectInfo.getInfo( o1 ).getMembers( ObjectInfo.MEMBER_PROPERTIES ); // получили встроенные свойства
		var prop:ObjectInfo;
		var name:QName;
		for each ( prop in arr ) {
			name = prop.name;
			if ( o1[ name ] != o2[ name ] ) return false;
		}

		// стались динамические свойства
		var i:Object;
		for ( i in o1 ) {
			if ( !( i in o2 ) ) return false;
			else if ( o1[ i ] != o2[ i ] ) return false;
		}

		for ( i in o2 ) {
			if ( !( i in o2 ) ) return false;
		}

		return true;
	}

}