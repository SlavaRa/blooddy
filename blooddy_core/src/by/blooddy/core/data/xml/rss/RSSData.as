////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data.xml.rss {

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import by.blooddy.core.data.DataContainer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					rss, xml, data
	 */
	public class RSSData extends DataContainer implements IRSSElementAsset {

		public function RSSData() {
			super();
		}

		public function get element():RSSElementData {
			return null;
		}

		private var _channel:RSSChannelData;

		public function get channel():RSSChannelData {
			return this._channel;
		}

		public function set channel(value:RSSChannelData):void {
			if ( this._channel === value ) return;
			if ( value )	super.addChild( value );
			else			super.removeChild( this._channel );
		}

		private var _version:Number;

		public function get version():Number {
			return this._version;
		}

		public function set version(value:Number):void {
			if ( this._version == value ) return;
			this._version = value;
		}

		public function parseXML(xml:XML):void {
			if ( this._channel ) super.removeChild( this._channel );
			this.update( xml );
		}

		public function toXML():XML { // TODO: реализовать
			return null;
		}

		public function update(xml:XML):void {
			if ( xml.name().toString() != "rss" ) throw new ArgumentError();
			var version:Number = parseFloat( xml.@version );
			if ( this._version && this._version != version ) throw new ArgumentError();
			switch ( parseFloat( xml.@version ) ) {
				case 2.0:
					var list:XMLList = xml.channel;
					if ( list.length() > 0 ) {
						if ( !this._channel ) {
							this._channel = new RSSChannelData();
							super.addChild( this._channel );
						}
						this._channel.updateXML( xml.channel[0] );
					}
					break;
				default:
					throw new ArgumentError();
			}
		}

	}

}