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
	public class RSSCloudData extends RSSPropertyData {

		public function RSSCloudData() {
			super();
		}

		[Deprecated( message="свойство устарело", replacement="domain" )]
		public override function set name(value:String):void {
			super.name = name;
		}

		public function get domain():String {
			return super.name;
		}

		public function set domain(value:String):void {
			super.name = value;
		}

		//<cloud domain="rpc.sys.com" port="80" path="/RPC2" registerProcedure="myCloud.rssPleaseNotify" protocol="xml-rpc" />

		private var _port:uint;

		public function get port():uint {
			return this._port;
		}

		public function set port(value:uint):void {
			if ( this._port == value ) return;
			this._port = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		private var _path:String;

		public function get path():String {
			return this._path;
		}

		public function set path(value:String):void {
			if ( this._path == value ) return;
			this._path = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		private var _registerProcedure:String;

		public function get registerProcedure():String {
			return this._registerProcedure;
		}

		public function set registerProcedure(value:String):void {
			if ( this._registerProcedure == value ) return;
			this._registerProcedure = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		private var _protocol:String;

		public function get protocol():String {
			return this._protocol;
		}

		public function set protocol(value:String):void {
			if ( this._protocol == value ) return;
			this._protocol = value;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		public override function parseXML(xml:XML):void {
			if ( xml.name().toString() != "cloud" ) throw new ArgumentError();
			this.$lock++;
			
			super.name =				XMLUtils.parseStringNode( xml.@domain );
			this._port =				XMLUtils.parseUIntNode( xml.@port );
			this._path =				XMLUtils.parseStringNode( xml.@path );
			this._registerProcedure =	XMLUtils.parseStringNode( xml.@registerProcedure );
			this._protocol =			XMLUtils.parseStringNode( xml.@protocol );

			this.$lock--;
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) ); 
		}

	}

}