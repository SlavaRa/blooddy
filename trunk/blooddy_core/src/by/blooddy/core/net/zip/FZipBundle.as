////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.zip {

	import flash.net.URLRequest;

	import by.blooddy.core.managers.IResourceBundle;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					fzipbundle, zip, resourcebundle, resource, bundle
	 * 
	 */
	public class FZipBundle extends FZip implements IResourceBundle {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function FZipBundle(request:URLRequest=null) {
			super(request);
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties: IResourceBundle
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  name
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get name():String {
			return this.url;
		}

		public function get empty():Boolean {
			return super.fileCount <= 0;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IResourceBundle
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function getResource(name:String):* {
			return this.getFileByName(name);
		}

		/**
		 * @inheritDoc
		 */
		public function hasResource(name:String):Boolean {
			return Boolean( this.getFileByName(name) );
		}

		/**
		 * @inheritDoc
		 */
		public function getResources():Array {
			return super.fileList;
		}

	}

}