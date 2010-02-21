////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.txt.data.battle.world {

	import by.blooddy.game.serializers.txt.ISerializer;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import ru.avangardonline.data.battle.world.BattleWorldAbstractElementData;
	import ru.avangardonline.data.battle.world.BattleWorldElementCollectionData;
	import ru.avangardonline.data.battle.world.BattleWorldElementData;
	import ru.avangardonline.data.character.CharacterData;
	import ru.avangardonline.data.character.HeroCharacterData;

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
			if ( _serializer ) throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function deserialize(source:String, target:*=null):* {
			var data:BattleWorldElementCollectionData = target as BattleWorldElementCollectionData;
			if ( !data ) throw new ArgumentError();
			var arr:Array = source.split( '\n' );
			var element:BattleWorldElementData;
			var h:Boolean;
			var id:uint;
			var non:Vector.<CharacterData> = new Vector.<CharacterData>();
			var races:Object = new Object();
			var char:CharacterData;
			var hash:Dictionary = new Dictionary();
			for each ( var s:String in arr ) {
				id = parseInt( s.split( ',', 1 )[0].substr( 2 ) );
				element = data.getElement( id );
				h = Boolean( element );
				element = BattleWorldElementDataSerializer.deserialize( s, element );
				if ( element is CharacterData ) { // хук для экономии трафика
					char = element as CharacterData;
					if ( char is HeroCharacterData ) { // если это герой, то надо сохранить рассу
						races[ char.group ] = char.race;
					} else {
						if ( char.group in races ) {
							char.race = races[ char.group ];
						} else {
							non.push( char );
						}
					}
				}
				if ( !h ) data.addChild( element );
				hash[ element ] = true;
			}
			// попишем рассу запоздавшим персонажам
			for each ( char in non ) {
				if ( char.group in races ) {
					char.race = races[ char.group ];
				}
			}
			// удалим ненужные элементы
			var elements:Vector.<BattleWorldAbstractElementData> = data.getElements();
			for each ( element in elements ) {
				if ( !( element in hash ) ) {
					data.removeChild( element );
				}
			}
			return data;
		}

	}

}