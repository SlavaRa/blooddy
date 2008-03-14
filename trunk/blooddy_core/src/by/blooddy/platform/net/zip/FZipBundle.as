////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.net.zip {

	import flash.net.URLRequest;

	import by.blooddy.platform.managers.IResourceBundle;

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
		 * Constructor.
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

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IResourceBundle
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function getObject(name:String):* {
			return this.getFileByName(name);
		}

	}

}