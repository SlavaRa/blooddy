////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.character {

	import by.blooddy.core.database.Data;
	import by.blooddy.core.database.DataContainer;
	import by.blooddy.core.utils.HashArray;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					29.07.2009 21:16:56
	 */
	public class CharacterCollectionData extends DataContainer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function CharacterCollectionData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _hash:HashArray = new HashArray();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getCharacterByID(id:uint):CharacterData {
			return this._hash[ id ];
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected override function addChild_before(child:Data):void {
			if ( child is CharacterData ) {
				var character:CharacterData = child as CharacterData;
				if ( this._hash[ character.id ] ) throw new ArgumentError();
				this._hash[ character.id ] = child;
			}
		}

		protected override function removeChild_before(child:Data):void {
			if ( child is CharacterData ) {
				delete this._hash[ ( child as CharacterData ).id ];
			}
		}

	}

}