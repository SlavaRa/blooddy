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

		public override function contains(target:AttributeSelector):Boolean {
			return	target is TagSelector && (
						this.value == target.value ||
						TypeInfo.getInfo( ClassAlias.getClass( this.value ) ).hasType( ClassAlias.getClass( target.value ) )
					) && (
						!target.selector ||
						( this.selector && this.selector.contains( target.selector ) )
					);
		}

		/*
		 *   ___
		 * AABBBCCC
		 */
		public override function getSpecificity():uint {
			var s:uint;
			if ( this.value in _HASH ) {
				s = _HASH[ this.value ];
			} else {
				_HASH[ this.value ] = s = 1 + TypeInfo.getInfo( ClassAlias.getClass( this.value ) ).getTypes().length;
			}
			if ( this.selector ) {
				return this.selector.getSpecificity() + s;
			}
			return s;
		}

		public override function toString():String {
			return this.value + ( this.selector || '' );
		}

	}
	
}