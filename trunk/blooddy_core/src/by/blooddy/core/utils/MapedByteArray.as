package by.blooddy.core.utils {

	import flash.utils.ByteArray;

	public dynamic class MapedByteArray extends ByteArray {

		public function MapedByteArray() {
			super();
		}

		protected const map:Object = new Object();

		public function hasPosition(name:String):Boolean {
			return name in this.map;
		}

		public function	movePosition(name:String):void {
			if ( !( name in this.map ) ) throw new ArgumentError();
			super.position = ( this.map[ name ] as Element ).position;
		}

		public function writeBytesElement(name:String, bytes:ByteArray):void {
			var element:Element;
			if ( name in this.map ) {
				element = ( this.map[name] as Element );
				if ( element.length != bytes.length ) {
					element = null;
				}
			}
			if ( !element ) {
				element = new Element( super.length, bytes.length );
			}
			this.map[name] = element;
			bytes.readBytes( this, element.position );
		}

	}

}

internal final class Element {

	public function Element(position:uint, length:uint) {
		super();
		this.position = position;
		this.length = length;
	}

	public var position:uint;

	public var length:uint;

}