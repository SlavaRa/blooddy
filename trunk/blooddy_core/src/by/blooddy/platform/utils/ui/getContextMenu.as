////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 BlooDHounD.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.utils.ui {

	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	import flash.display.InteractiveObject;

	/**
	 * Ищет билижайшее меню по родителям.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @param	child			Объект меню, которого надо найти.
	 * 
	 * @return					Контекстное меню.
	 * 
	 * @keyword					getcontextmenu, contextmenu, contextmenuitem, contextmenubuiltinitems
	 * 
	 * @see						flash.display.InteractiveObject#contextMenu 
	 * @see						flash.ui.ContextMenu
	 */
	public function getContextMenu(child:InteractiveObject):ContextMenu {
		do {
			// О! у нашего предка есть менюшка
			if (child.contextMenu) return child.contextMenu;
			child = child.parent;
		} while (child);
		// ничё не нашли
		return null;
	}

}