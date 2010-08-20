////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.style.meta {

	import by.blooddy.core.meta.MemberInfo;
	import by.blooddy.core.meta.PropertyInfo;
	import by.blooddy.core.meta.TypeInfo;
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					25.05.2010 0:21:43
	 */
	public class StyleInfo {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function getInfo(o:Object):StyleInfo {
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
			var result:StyleInfo = _HASH[ c ];
			if ( !result ) {
				_privateCall = true;
				_HASH[ c ] = result = new StyleInfo();
				result.parseType( TypeInfo.getInfo( c ) );
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
		public function StyleInfo() {
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
		private const _collectionValues:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function parseType(type:TypeInfo):void {
			
			// обрабатываем свойства
			var meta:XMLList = type.getMetadata();

			var hash:Object = new Object();

			var list:XMLList;
			var xml:XML;
			var n:String;

			for each ( xml in meta.( @name == 'Exclude' && arg.( @key == 'kind' && @value == 'property' ).length() > 0 ).arg.( @key == 'name' ).@value ) {
				hash[ xml ] = true;
			}

			for each ( var prop:PropertyInfo in type.getProperties( false ) ) {
				list = prop.getMetadata().( @name == 'StyleType' );
				
			}

			var member:MemberInfo;
			var properties:Vector.<PropertyInfo>;
			for each ( xml in meta.( @name == 'StyleValue' ) ) {
				list = xml.arg.( @key == 'name' ).@value;
				if ( list.length() > 0 && !( list[ 0 ] in this._collectionValues ) ) {
					this._collectionValues[ list[ 0 ] ] = properties = new Vector.<PropertyInfo>();
					for each ( xml in xml.arg.( @key == '' ).@value ) {
						member = type.getMember( xml.toString() );
						if ( member is PropertyInfo ) {
							properties.push( member as PropertyInfo );
						}
					}
				}
			}
		}

	}
	
}