////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.txt.database.battle {

	import ru.avangardonline.database.battle.BattleTurnData;
	import ru.avangardonline.serializers.ISerializer;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 23:33:00
	 */
	public class BattleTurnDataSerializer implements ISerializer {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _serializer:BattleTurnDataSerializer = new BattleTurnDataSerializer();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:BattleTurnData=null):BattleTurnData {
			return _serializer.deserialize( source, target ) as BattleTurnData;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleTurnDataSerializer() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public function deserialize(source:String, target:*=null):* {
			var data:BattleTurnData = target as BattleTurnData;
			if ( !data ) throw new ArgumentError();
			return data;
		}

	}

}