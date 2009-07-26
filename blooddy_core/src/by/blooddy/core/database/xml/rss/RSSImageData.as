////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.database.xml.rss {

	import by.blooddy.core.events.database.DataBaseEvent;
	import by.blooddy.core.utils.XMLUtils;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					rss, xml, data
	 */
	public class RSSImageData extends RSSElementData {

		public function RSSImageData() {
			super();
		}

		private var _url:String;

		public function get url():String {
			return this._url;
		}

		public function set url(value:String):void {
			if ( this._url == value ) return;
			this._url = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		private var _width:uint;

		public function get width():uint {
			return this._width;
		}

		public function set width(value:uint):void {
			if ( this._width == value ) return;
			this._width = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		private var _height:uint;

		public function get height():uint {
			return this._height;
		}

		public function set height(value:uint):void {
			if ( this._height == value ) return;
			this._height = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		public override function parseXML(xml:XML):void {
			if ( xml.name().toString() != "image" ) throw new ArgumentError();
			this.$lock++;
			super.parseXML( xml );
			this._url =		XMLUtils.parseStringNode( xml.image );
			this._width =	XMLUtils.parseUIntNode( xml.width );
			this._height =	XMLUtils.parseUIntNode( xml.height );
			this.$lock--;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

	}

}