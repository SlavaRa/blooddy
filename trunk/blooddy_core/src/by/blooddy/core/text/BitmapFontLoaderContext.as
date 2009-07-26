////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.text {

	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;

	public class BitmapFontLoaderContext extends LoaderContext {

		public function BitmapFontLoaderContext(checkPolicyFile:Boolean=false, applicationDomain:ApplicationDomain=null, securityDomain:SecurityDomain=null) {
			super(checkPolicyFile, applicationDomain, securityDomain);
		}

		public var glyphWidth:uint = 10;

		public var glyphHeight:uint = 10;

	}

}