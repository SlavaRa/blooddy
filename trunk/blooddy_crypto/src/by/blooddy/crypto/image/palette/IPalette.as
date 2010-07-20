////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image.palette {

	/**
	 * Базовый интерфейс для создания различных палитр.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.06.2010 22:35:21
	 * 
	 * @see						by.blooddy.crypto.image.PNG8Encoder
	 */
	public interface IPalette {

		/**
		 * Возрврщает список используемых в палитре цветов.
		 * 
		 * @return все используемые в палитре цвета.
		 */
		function getColors():Vector.<uint>;

		/**
		 * Возврщает номер цвета в палитре. Одни и тот же номер может вернуться для для разных цветов.
		 * 
		 * @param	color			цвет для которого нужно вернуть его номер.
		 * 
		 * @return					номер цвета в палитре.
		 * 
		 * @throw	ArgumentError	цвет в палитре не найден.
		 */
		function getIndexByColor(color:uint):uint;

	}

}