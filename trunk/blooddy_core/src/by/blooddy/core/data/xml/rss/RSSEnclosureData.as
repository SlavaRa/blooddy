////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data.xml.rss {

	import by.blooddy.core.events.data.DataBaseEvent;
	import by.blooddy.core.utils.XMLUtils;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					rss, xml, data
	 */
	public class RSSEnclosureData extends RSSPropertyData {

		public function RSSEnclosureData() {
			super();
		}

		[Deprecated( message="свойство устарело", replacement="url" )]
		public override function set name(value:String):void {
			super.name = name;
		}

		public function get url():String {
			return super.name;
		}

		public function set url(value:String):void {
			super.name = value;
		}

		private var _length:uint;

		public function get length():uint {
			return this._length;
		}

		public function set length(value:uint):void {
			if ( this._length == value ) return;
			this._length = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		private var _type:String;

		public function get type():String {
			return this._type;
		}

		public function set type(value:String):void {
			if ( this._type == value ) return;
			this._type = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		public override function parseXML(xml:XML):void {
			if ( xml.name().toString() != "enclosure" ) throw new ArgumentError();
			this.$lock++;
			super.name =				XMLUtils.parseStringNode( xml.@url );
			this._length =				XMLUtils.parseUIntNode( xml.@length );
			this._type =				XMLUtils.parseStringNode( xml.@type );
			this.$lock--;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

	}

}