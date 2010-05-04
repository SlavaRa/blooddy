////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css.definition.selectors {

	import by.blooddy.core.utils.ClassAlias;
	import by.blooddy.core.meta.TypeInfo;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					14.03.2010 17:29:18
	 */
	public class TagSelector extends AttributeSelector {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _HASH:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function TagSelector(type:String, selector:AttributeSelector=null) {
			super( type, selector );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function contains(selector:AttributeSelector):Boolean {
			return	selector is TagSelector && (
						this.value == selector.value ||
						TypeInfo.getInfo( ClassAlias.getClass( this.value ) ).hasType( ClassAlias.getClass( this.value ) )
					) && (
						!selector.selector ||
						( this.selector && this.selector.contains( selector ) )
					);
		}

		/*
		 *   ____
		 * AABBBBCC
		 */
		public override function getSpecificity():uint {
			var s:uint;
			if ( this.value in _HASH ) {
				s = _HASH[ this.value ];
			} else {
				var i:TypeInfo = TypeInfo.getInfo( ClassAlias.getClass( this.value ) );
				_HASH[ this.value ] = s = 1 + i.getSuperclasses().length + i.getInterfaces().length;
			}
			if ( this.selector ) {
				var result:uint = this.selector.getSpecificity();
				var v:uint = ( ( result & 0x00FFFF00 ) >> 8 ) + s;
				return ( result & 0xFF0000FF ) | ( v << 8 );
			}
			return s << 8;
		}

		public override function toString():String {
			return this.value + ( this.selector || '' );
		}

	}
	
}