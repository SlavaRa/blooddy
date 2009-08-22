////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.txt.database.battle.world {

	import ru.avangardonline.database.battle.world.BattleWorldElementCollectionData;
	import ru.avangardonline.database.battle.world.BattleWorldElementData;
	import ru.avangardonline.serializers.ISerializer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 23:30:07
	 */
	public class BattleWorldElementCollectionDataSerializer implements ISerializer {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _serializer:BattleWorldElementCollectionDataSerializer = new BattleWorldElementCollectionDataSerializer();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:BattleWorldElementCollectionData=null):BattleWorldElementCollectionData {
			return _serializer.deserialize( source, target ) as BattleWorldElementCollectionData;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldElementCollectionDataSerializer() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public function deserialize(source:String, target:*=null):* {
			var data:BattleWorldElementCollectionData = target as BattleWorldElementCollectionData;
			if ( !data ) throw new ArgumentError();
			var arr:Array = source.split( '\n' );
			var element:BattleWorldElementData;
			var h:Boolean;
			var id:uint;
			for each ( var s:String in arr ) {
				id = parseInt( s.split( ',', 1 )[0].substr( 2 ) );
				element = data.getElement( id );
				h = Boolean( element );
				element = BattleWorldElementDataSerializer.deserialize( s, element );
				if ( !h ) data.addChild( element );
			}
			return data;
		}

	}

}