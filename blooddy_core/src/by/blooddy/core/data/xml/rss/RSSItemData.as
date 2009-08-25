////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data.xml.rss {

	import by.blooddy.core.data.Data;
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
	public class RSSItemData extends RSSElementData {

		public function RSSItemData() {
			super();
		}

		private var _author:String;

		public function get author():String {
			return this._author;
		}

		public function set author(value:String):void {
			if ( this._author == value ) return;
			this._author = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		private var _category:RSSCategoryData;

		public function get category():RSSCategoryData {
			return this._category;
		}

		public function set category(value:RSSCategoryData):void {
			if ( this._category === value ) return;
			if ( value )	super.addChild( value );
			else			super.removeChild( this._category );
		}

		private var _comments:String;

		public function get comments():String {
			return this._comments;
		}

		public function set comments(value:String):void {
			if ( this._comments == value ) return;
			this._comments = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		private var _enclosure:RSSEnclosureData;

		public function get enclosure():RSSEnclosureData {
			return this._enclosure;
		}

		public function set enclosure(value:RSSEnclosureData):void {
			if ( this._enclosure === value ) return;
			if ( value )	super.addChild( value );
			else			super.removeChild( this._enclosure );
		}

		private var _guid:RSSGuidData;

		public function get guid():RSSGuidData {
			return this._guid;
		}

		public function set guid(value:RSSGuidData):void {
			if ( this._guid === value ) return;
			if ( value )	super.addChild( value );
			else			super.removeChild( this._guid );
		}

		private var _pubDate:Date;

		public function get pubDate():Date {
			return new Date( this._pubDate.getTime() );
		}

		public function set pubDate(value:Date):void {
			if ( this._pubDate === value || this._pubDate.getTime() == value.getTime() ) return;
			this._pubDate = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		private var _source:RSSSourceData;

		public function get source():RSSSourceData {
			return this._source;
		}

		public function set source(value:RSSSourceData):void {
			if ( this._source === value ) return;
			if ( value )	super.addChild( value );
			else			super.removeChild( this._source );
		}

		protected override function addChild_before(child:Data):void {
			var change:Boolean = false;
			this.$lock++;
			if ( child is RSSCategoryData ) {
				if ( this._category ) super.removeChild( this._category );
				this._category = child as RSSCategoryData;
				change = true;
			} else if ( child is RSSEnclosureData ) {
				if ( this._enclosure ) super.removeChild( this._enclosure );
				this._enclosure = child as RSSEnclosureData;
				change = true;
			} else if ( child is RSSGuidData ) {
				if ( this._guid ) super.removeChild( this._guid );
				this._guid = child as RSSGuidData;
				change = true;
			} else if ( child is RSSSourceData ) {
				if ( this._source ) super.removeChild( this._source );
				this._source = child as RSSSourceData;
				change = true;
			}
			this.$lock--;
			if ( change && !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		protected override function removeChild_before(child:Data):void {
			super.removeChild_before( child );
			var change:Boolean = false;
			if ( child is RSSCategoryData ) {
				this._category = null;
				change = true;
			} else if ( child is RSSEnclosureData ) {
				this._enclosure = null;
				change = true;
			} else if ( child is RSSGuidData ) {
				this._guid = null;
				change = true;
			} else if ( child is RSSSourceData ) {
				this._source = null;
				change = true;
			}
			if ( change && !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		public override function parseXML(xml:XML):void {
			if ( xml.name().toString() != "item" ) throw new ArgumentError();
			this.$lock++;
			super.parseXML( xml );

			this._author =		XMLUtils.parseStringNode( xml.author );
			this._comments =	XMLUtils.parseStringNode( xml.comments );
			this._pubDate =		XMLUtils.parseDateNode( xml.pubDate );

			var list:XMLList;
			var prop:IRSSElementAsset;

			list = xml.category;
			if ( list.length() > 0 ) {
				if ( !this._category ) super.addChild( new RSSCategoryData() );
				this._category.parseXML( list[0] );
			} else {
				if ( this._category ) super.removeChild( this._category );
			}

			list = xml.enclosure;
			if ( list.length() > 0 ) {
				if ( !this._enclosure )  super.addChild( new RSSEnclosureData() );
				this._enclosure.parseXML( list[0] );
			} else {
				if ( this._enclosure ) super.removeChild( this._enclosure );
			}

			list = xml.guid;
			if ( list.length() > 0 ) {
				if ( !this._guid ) super.addChild( new RSSGuidData() );
				this._guid.parseXML( list[0] );
			} else {
				if ( this._guid ) super.removeChild( this._guid );
			}

			list = xml.source;
			if ( list.length() > 0 ) {
				if ( !this._source ) super.addChild( new RSSSourceData() );
				this._source.parseXML( list[0] );
			} else {
				if ( this._source ) super.removeChild( this._source );
			}

			this.$lock--;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

	}

}