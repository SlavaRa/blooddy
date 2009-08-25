////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data.xml.rss {

	import by.blooddy.core.data.DataContainer;
	import by.blooddy.core.events.data.DataBaseEvent;
	import by.blooddy.core.data.Data;
	import by.blooddy.core.utils.XMLUtils;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					rss, xml, data
	 */
	public class RSSElementData extends DataContainer implements IRSSElementAsset {

		public function RSSElementData() {
			super();
		}

		protected var $lock:uint = 0;

		internal var $element:RSSElementData;

		public function get element():RSSElementData {
			return this.$element;
		}

		[Deprecated(message="свойство устарело", replacement="title")]
		public override function set name(value:String):void {
			this.setName( value );
		}

		public function get title():String {
			return super.name;
		}

		public function set title(value:String):void {
			this.setName( value );
		}

		private function setName(value:String):void {
			if ( super.name == value ) return;
			super.name = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		private var _link:String;

		public function get link():String {
			return this._link;
		}

		public function set link(value:String):void {
			if ( this._link == value ) return;
			this._link = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		private var _description:String;

		public function get description():String {
			return this._description;
		}

		public function set description(value:String):void {
			if ( this._description == value ) return;
			this._description = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		public function parseXML(xml:XML):void {
			this.$lock++;
			super.name =		XMLUtils.parseStringNode( xml.title );
			this._link =		XMLUtils.parseStringNode( xml.link );
			this._description =	XMLUtils.parseStringNode( xml.description );
			this.$lock--;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		public function toXML():XML { // TODO: руализация
			var xml:XML = new XML();
			xml.link = this._link;
			xml.title = super.name;
			xml.description = this._description;
			return xml;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected override function addChild_before(child:Data):void {
			if ( child is RSSPropertyData ) {
				( child as RSSPropertyData ).$element = this;
			} else if ( child is RSSElementData ) {
				( child as RSSElementData ).$element = this;
			}
		}

		protected override function removeChild_before(child:Data):void {
			if ( child is RSSPropertyData ) {
				( child as RSSPropertyData ).$element = null;
			} else if ( child is RSSElementData ) {
				( child as RSSElementData ).$element = null;
			}
		}

	}

}