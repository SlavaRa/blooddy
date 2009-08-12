////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.txt.database.battle.actions {
	import ru.avangardonline.database.battle.actions.BattleAtackActionData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 23:06:53
	 */
	public class BattleAtackActionDataSerializer extends BattleWorldElemenetActionDataSerializer {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _serializer:BattleAtackActionDataSerializer = new BattleAtackActionDataSerializer();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:BattleAtackActionData=null):BattleAtackActionData {
			return _serializer.deserialize( source, target ) as BattleAtackActionData;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleAtackActionDataSerializer() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public override function deserialize(source:String, target:*=null):* {
			var data:BattleAtackActionData = target as BattleAtackActionData;
			if ( !data ) data = new BattleAtackActionData();
			data = super.deserialize( source, data );
			var arr:Array = source.split( ',', 4 );
			data.targetID = parseInt( arr[ 2 ] );
			data.targetIncreaseHealth = parseInt( arr[ 3 ] );
			return data;
		}

	}

}