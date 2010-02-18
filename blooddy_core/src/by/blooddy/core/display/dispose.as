package by.blooddy.core.display {

	import flash.display.DisplayObject;

	public function dispose(child:DisplayObject):void {
		if ( child.stage ) throw new ArgumentError();
		$dispose( child );
	}

}

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.display.Bitmap;
import flash.text.TextField;
import flash.geom.Transform;

internal function $dispose(child:DisplayObject):void {
	if ( child is DisplayObjectContainer ) {
		var container:DisplayObjectContainer = child as DisplayObjectContainer;
		while ( container.numChildren ) {
			$dispose( container.removeChildAt( 0 ) );
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
		( child as Bitmap ).bitmapData = null;
	} else if ( child is TextField ) {
		( child as TextField ).text = '';
		( child as TextField ).styleSheet = null;
	}
	// TODO: все остальные типы
	child.mask = null;
}