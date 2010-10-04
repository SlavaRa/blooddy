////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.Vector;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class ImageHelper {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * углебленный способ проверки прозрачности. флаг прозрачности может стоять,
	 * но картинка может быть не прозрачна. немного теряем в скорости на прозрачных
	 * картинках, зато выйигрываем с установленным флагом в ~5 раз.
	 *
	 * @param	image	картинка на проверку
	 *
	 * @return			прозрачна или нет?
	 */
	public static inline function isTransparent(image:BitmapData):Bool {
		return	image.transparent &&
				image.clone().threshold( image, image.rect, new Point(), '!=', 0xFF000000, 0, 0xFF000000, true ) != 0; // не все пиксели не прозрачны
	}

}