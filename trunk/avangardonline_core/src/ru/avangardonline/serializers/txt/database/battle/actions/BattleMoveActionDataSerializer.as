////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.txt.database.battle.actions {

	import ru.avangardonline.database.battle.actions.BattleMoveActionData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 22:41:07
	 */
	public class BattleMoveActionDataSerializer extends BattleWorldElemenetActionDataSerializer {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _serializer:BattleMoveActionDataSerializer = new BattleMoveActionDataSerializer();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:BattleMoveActionData=null):BattleMoveActionData {
			return _serializer.deserialize( source, target ) as BattleMoveActionData;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleMoveActionDataSerializer() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public override function deserialize(source:String, target:*=null):* {
			var data:BattleMoveActionData = target as BattleMoveActionData;
			if ( !data ) data = new BattleMoveActionData();
			data = super.deserialize( source, data );
			var arr:Array = source.split( ',', 4 );
			data.x = parseInt( arr[ 2 ] );
			data.y = parseInt( arr[ 3 ] );
			return data;
		}

	}

}