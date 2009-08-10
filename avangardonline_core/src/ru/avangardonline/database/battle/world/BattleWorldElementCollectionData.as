////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.database.battle.world {

	import by.blooddy.core.database.Data;
	import by.blooddy.core.utils.HashArray;
	
	import ru.avangardonline.database.character.CharacterData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					29.07.2009 21:16:56
	 */
	public class BattleWorldElementCollectionData extends BattleWorldAssetDataContainer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldElementCollectionData() {
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

		/**
		 * @private
		 */
		private const _list:Vector.<BattleWorldElementData> = new Vector.<BattleWorldElementData>();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function clone():Data {
			var result:BattleWorldElementCollectionData = new BattleWorldElementCollectionData();
			result.copyFrom( this );
			return result;
		}

		public function copyFrom(data:Data):void {
			var target:BattleWorldElementCollectionData = data as BattleWorldElementCollectionData
			if ( !target ) throw new ArgumentError();
			var hash:Object = new Object();
			var c1:CharacterData;
			var c2:CharacterData;
			var id:uint;
			for each ( c1 in target._list ) {
				id = c1.id;
				c2 = this._hash[ id ];
				if ( c2 ) c2.copyFrom( c1 );
				else target.addChild( c1.clone() );
				hash[ id ] = true;
			}
			for each ( c2 in this._list ) {
				if ( !hash[ c2.id ] ) target.removeChild( c2 );
			}
		}

		public function getElement(id:uint):BattleWorldElementData {
			return this._hash[ id ];
		}

		public function getElements():Vector.<BattleWorldElementData> {
			return this._list.slice();
		}

		public function getElementAt(x:int, y:int):BattleWorldElementData {
			for each ( var character:CharacterData in this._list ) {
				if ( int( character.coord.x ) == x && int( character.coord.y ) == y ) return character;
			}
			return null;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function addChild_before(child:Data):void {
			super.addChild_before( child );
			if ( child is BattleWorldElementData ) {
				var element:BattleWorldElementData = child as BattleWorldElementData;
				if ( this._hash[ element.id ] ) throw new ArgumentError();
				this._hash[ element.id ] = child;
				this._list.push( element );
			}
		}

		/**
		 * @private
		 */
		protected override function removeChild_before(child:Data):void {
			super.removeChild_before( child );
			if ( child is BattleWorldElementData ) {
				var element:BattleWorldElementData = child as BattleWorldElementData;
				delete this._hash[ element.id ];
				var i:int = this._list.indexOf( element );
				if ( i >= 0 ) this._list.splice( i, 0 );
			}
		}

	}

}