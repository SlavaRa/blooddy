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
	public class RSSGuidData extends RSSPropertyData {

		public function RSSGuidData() {
			super();
		}

		private var _isPermaLink:Boolean;

		public function get isPermaLink():Boolean {
			return this._isPermaLink;
		}

		public function set isPermaLink(value:Boolean):void {
			if ( this._isPermaLink == value ) return;
			this._isPermaLink = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		public function url():String {
			if ( this._isPermaLink ) {
				return super.name;
			}
			return null;
		}

		public override function parseXML(xml:XML):void {
			if ( xml.name().toString() != "guid" ) throw new ArgumentError();
			this.$lock++;
			super.name =		XMLUtils.parseStringNode( xml.* );;
			this._isPermaLink =	XMLUtils.parseBooleanNode( xml.@isPermaLink );
			this.$lock--;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

	}

}