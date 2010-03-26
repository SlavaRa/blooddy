////////////////////////////////////////////////////////////////////////////////
//
//  © 2004—2009 TimeZero LLC.
//
////////////////////////////////////////////////////////////////////////////////

package com.timezero.social.controller {
	import com.timezero.platform.controllers.IController;
	
	/**
	 * @author					etc
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public interface ISocialController extends IController {
		
		function get appID():String;
		
		function get viewerID():String;
		
		function get referer():String;
		
	}
}