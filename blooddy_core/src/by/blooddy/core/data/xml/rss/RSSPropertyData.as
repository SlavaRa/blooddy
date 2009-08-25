////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data.xml.rss {

	import by.blooddy.core.data.Data;
	import by.blooddy.core.events.data.DataBaseEvent;
	import flash.errors.IllegalOperationError;

	[Event(name="change", type="by.blooddy.core.events.data.DataBaseEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					rss, xml, data
	 */
	public class RSSPropertyData extends Data implements IRSSElementAsset {

		public function RSSPropertyData() {
			super();
		}

		protected var $lock:uint = 0;

		internal var $element:RSSElementData;

		public function get element():RSSElementData {
			return this.$element;
		}

		public override function set name(value:String):void {
			if ( super.name == value ) return;
			super.name = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		public virtual function parseXML(xml:XML):void {
			throw new IllegalOperationError();
		}

		public virtual function toXML():XML { // TODO: руализация
			return new XML();
		}

	}

}