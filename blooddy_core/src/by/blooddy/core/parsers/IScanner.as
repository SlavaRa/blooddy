////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.parsers {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 9, 2010 4:41:05 PM
	 */
	public interface IScanner {

		function get tokenContext():TokenContext;
		
		function readToken():int;

	}
	
}