////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.serialization {

	import flash.utils.Dictionary;
	import flash.utils.describeType;

	[ExcludeClass]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					08.10.2010 2:05:14
	 */
	public class SerializationHelper {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _EMPTY_LIST:XMLList = new XMLList();
		
		/**
		 * @private
		 */
		private static const _HASH_CLASS:Dictionary = new Dictionary( true );

		/**
		 * @private
		 */
		private static const _HASH_INSTANCE:Dictionary = new Dictionary( true );
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function getPropertyNames(o:Object):XMLList {
			if ( typeof o != 'object' || !o ) Error.throwError( TypeError, 2007, 'o' );
			var isClass:Boolean = o is Class;
			var list:XMLList;
			var c:Object;
			if ( isClass ) {
				c = o as Class;
				list = _HASH_CLASS[ c ];
			} else {
				c = o.constructor as Class;
				list = _HASH_CLASS[ c ];
			}
			if ( !list ) {
				var n:String;
				list = describeType( o ).*.(
					n = name(),
					(
						(
							name() == 'accessor' &&
							@access.charAt( 0 ) == 'r'
						) ||
						n == 'variable' ||
						n == 'constant'
					) &&
					attribute( 'uri' ).length() <= 0 &&
					(
						list = metadata,
						list.length() <= 0 ||
						list.( @name == 'Transient' ).length() <= 0
					)
				).@name;
				if ( list.length() > 0 ) {
					list = list.copy();
				} else {
					list = _EMPTY_LIST;
				}
				if ( isClass ) {
					_HASH_CLASS[ c ] = list;
				} else {
					_HASH_INSTANCE[ c ] = list;
				}
			}
			return list.copy();
		}
		
	}
	
}