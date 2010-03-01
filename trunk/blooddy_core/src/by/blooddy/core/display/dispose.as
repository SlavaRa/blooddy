////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import flash.display.DisplayObject;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					21.02.2010 18:26:29
	 */
	public function dispose(child:DisplayObject, safe:Boolean=false):void {
		if ( child.stage ) throw new ArgumentError();
		$dispose( child, safe );
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.text.TextField;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper method: $dispose
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal function $dispose(child:DisplayObject, safe:Boolean):void {
	if ( child is DisplayObjectContainer ) {
		var container:DisplayObjectContainer = child as DisplayObjectContainer;
		while ( container.numChildren ) {
			$dispose( container.removeChildAt( 0 ), safe );
		}
	}
	if ( child is Sprite ) {
		( child as Sprite ).graphics.clear();
		if ( child is MovieClip ) {
			( child as MovieClip ).stop();
		}
	} else if ( child is Shape ) {
		( child as Shape ).graphics.clear();
	} else if ( child is Bitmap ) {
		if ( ( child as Bitmap ).bitmapData ) {
			if ( !safe ) {
				( child as Bitmap ).bitmapData.dispose();
			}
			( child as Bitmap ).bitmapData = null;
		}
	} else if ( child is TextField ) {
		( child as TextField ).text = '';
		( child as TextField ).styleSheet = null;
	} else if ( child is SimpleButton ) {
		with ( child as SimpleButton ) {
			upState = null;
			downState = null;
			overState = null;
			hitTestState = null;
		}
	}
	// TODO: все остальные типы
	child.mask = null;
}