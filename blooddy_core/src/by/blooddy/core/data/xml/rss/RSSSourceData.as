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
	public class RSSSourceData extends RSSPropertyData {

		public function RSSSourceData() {
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

		public override function parseXML(xml:XML):void {
			if ( xml.name().toString() != "source" ) throw new ArgumentError();
			this.$lock++;
			this._url =		XMLUtils.parseStringNode( xml.@url );
			super.name =	XMLUtils.parseStringNode( xml.* );
			this.$lock--;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

	}

}