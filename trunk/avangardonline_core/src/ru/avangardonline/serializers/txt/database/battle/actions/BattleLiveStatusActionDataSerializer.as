////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.txt.database.battle.actions {

	import ru.avangardonline.database.battle.actions.BattleLiveStatusActionData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 23:27:32
	 */
	public class BattleLiveStatusActionDataSerializer extends BattleWorldElemenetActionDataSerializer {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _serializer:BattleLiveStatusActionDataSerializer = new BattleLiveStatusActionDataSerializer();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:BattleLiveStatusActionData=null):BattleLiveStatusActionData {
			return _serializer.deserialize( source, target ) as BattleLiveStatusActionData;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleLiveStatusActionDataSerializer() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public override function deserialize(source:String, target:*=null):* {
			var data:BattleLiveStatusActionData = target as BattleLiveStatusActionData;
			if ( !data ) data = new BattleLiveStatusActionData();
			data = super.deserialize( source, data );
			var arr:Array = source.split( ',', 3 );
			data.live = Boolean( parseInt( arr[ 2 ] ) );
			return data;
		}

	}

}