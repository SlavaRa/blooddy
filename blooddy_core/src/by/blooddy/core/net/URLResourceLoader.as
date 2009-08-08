////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.managers.resource.IResourceBundle;
	
	import flash.net.URLRequest;

	/**
	 * Евент ресурс манагера.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					urlresourceloader, resourceloader, urlloader
	 * 
	 * @see						by.blooddy.core.managers.ResourceManager
	 */
	public class URLResourceLoader extends URLLoader implements IResourceBundle {

		public function URLResourceLoader(request:URLRequest=null) {
			super( request );
		}

		/**
		 * @inheritDoc
		 */
		public function get name():String {
			return super.url;
		}

		/**
		 * @inheritDoc
		 */
		public function get empty():Boolean {
			return super.data == null;
		}

		/**
		 * @inheritDoc
		 */
		public function getResource(name:String):* {
			if ( name != "" ) throw new ArgumentError();
			return super.data;
		}

		/**
		 * @inheritDoc
		 */
		public function hasResource(name:String):Boolean {
			return ( name == "" ) && super.data != null;
		}

		/**
		 * @inheritDoc
		 */
		public function getResources():Array {
			return new Array();
		}

	}

}