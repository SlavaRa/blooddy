////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.database.xml.rss {

	import by.blooddy.core.database.Data;
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
	public class RSSCategoryData extends RSSPropertyData {

		public function RSSCategoryData() {
			super();
		}

		private var _domain:String;

		public function get domain():String {
			return this._domain;
		}

		public function set domain(value:String):void {
			if ( this._domain == value ) return;
			this._domain = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		public override function parseXML(xml:XML):void {
			if ( xml.name().toString() != "category" ) throw new ArgumentError();
			this.$lock++;
			this._domain = XMLUtils.parseStringNode( xml.@domain );
			super.name = XMLUtils.parseStringNode( xml.* );
			this.$lock--;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

	}

}