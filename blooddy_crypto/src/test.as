package { 
	
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import by.blooddy.crypto.CRC32;
	import by.blooddy.core.utils.crypto.CRC32;
	import by.blooddy.core.utils.ByteArrayUtils;
	import flash.utils.Endian;
	import flash.display.BitmapData;
	import by.blooddy.crypto.image.JPEGEncoder;
	import by.blooddy.crypto.image.JPEGEncoder2;
	
	/**
	 * @author			BlooDHounD
	 * @playerversion	Flash 9
	 * @langversion		3.0
	 */
	public class test extends Sprite {
		
		[Embed(source='../LogovoLauncher.exe', mimeType='application/octet-stream')]
		private static const _binData:Class; // 444 Kb
		
		
		/**
		 * Constructor
		 */
		public function test() {
			super();
			
			var s:String = '';
			
			var arr:* = Vector.<int>([
				0x03020100, 0x21050411, 0x41120631, 0x71610751, 0x81322213, 0x91421408, 0x09c1b1a1, 0xf0523323, 0xd1726215, 0x3424160a, 0x17f125e1, 0x261a1918, 0x2a292827, 0x38373635, 0x44433a39, 0x48474645, 0x54534a49, 0x58575655, 0x64635a59, 0x68676665, 0x74736a69, 0x78777675, 0x83827a79, 0x87868584, 0x928a8988, 0x96959493, 0x9a999897, 0xa5a4a3a2, 0xa9a8a7a6, 0xb4b3b2aa, 0xb8b7b6b5, 0xc3c2bab9, 0xc7c6c5c4, 0xd2cac9c8, 0xd6d5d4d3, 0xdad9d8d7, 0xe5e4e3e2, 0xe9e8e7e6, 0xf4f3f2ea, 0xf8f7f6f5, 0x0000faf9
			]);
			
			for each ( var i:int in arr ) {
				s += '\\x' + ( i < 0x10 ? '0' : '' ) + i.toString( 16 );
			}
			trace( arr.length );
			trace( s );
			
			var bmp:BitmapData = new BitmapData( 10, 10, true, 0xFFFF0000 );
			
			trace( ByteArrayUtils.dump( JPEGEncoder.encode( bmp ) ) );
			trace( '================================================================' );
			trace( ByteArrayUtils.dump( ( new JPEGEncoder2( 60 ) ).encode( bmp ) ) );
			
		}
		
		
		
		
	}
	
}
/*ActionScript *идиотизм *странности
Дениска ( http://etcs.ru/ ) меня сегодня порадовал ещё раз:

public function test()void {
var a:String;
trace( typeof a ); //string
}

в чём же прикол? по логике в *a* записан *null* а значит результатом должен быть *object*, но мы наблюдаем *string*.

оказывается компилятор превращает это вот такой вот код:

_as3_pushnull 
_as3_coerce_s 
_as3_setlocal <1> 
_as3_findpropstrict trace
_as3_pushstring "string"
_as3_callpropvoid trace(param count:1)

в хуманабельном виде это выглядит так:

public function test() : void {
var _loc_1:String = null;
trace("string");
return;
}

тоесть копилятор оптимизирует выражение *typeof a* до выражение *string*, но этот же копилятор не умеет оптимизировать математические выражения =) лол.
*/





