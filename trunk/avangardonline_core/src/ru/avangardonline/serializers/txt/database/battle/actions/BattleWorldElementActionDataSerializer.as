////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.txt.database.battle.actions {

	import ru.avangardonline.database.battle.actions.BattleAtackActionData;
	import ru.avangardonline.database.battle.actions.BattleLiveStatusActionData;
	import ru.avangardonline.database.battle.actions.BattleMoveActionData;
	import ru.avangardonline.database.battle.actions.BattleWorldElementActionData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 22:22:27
	 */
	public class BattleWorldElementActionDataSerializer extends BattleActionDataSerializer {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:BattleWorldElementActionData=null):BattleWorldElementActionData {
			switch ( source.charAt( 0 ) ) {
				case 'm':	return BattleMoveActionDataSerializer.deserialize( source, target as BattleMoveActionData );
				case 'a':	return BattleAtackActionDataSerializer.deserialize( source, target as BattleAtackActionData );
				case 'd':	return BattleLiveStatusActionDataSerializer.deserialize( source, target as BattleLiveStatusActionData );
			}
			throw new ArgumentError();
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldElementActionDataSerializer() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public override function deserialize(source:String, target:*=null):* {
			var data:BattleWorldElementActionData = target as BattleWorldElementActionData;
			if ( !data ) throw new ArgumentError();
			data.elementID = parseInt( source.split( '|', 1 )[0] );
			return data;
		}

	}

}