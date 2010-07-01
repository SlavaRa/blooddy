////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image.palette {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.06.2010 22:35:21
	 */
	public interface IPalette {

		function getColors():Vector.<uint>;
		
		function getIndexByColor(color:uint):uint;
		
	}
	
}