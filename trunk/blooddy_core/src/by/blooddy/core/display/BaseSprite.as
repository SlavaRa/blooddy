////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import flash.display.Sprite;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class BaseSprite extends Sprite {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BaseSprite() {
			super();
			new DisplayObjectListener( this );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden peoperties: DisplayObject
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function set filters(value:Array):void {
			if ( !super.filters.length && ( !value || !value.length ) ) return;
			super.filters = value;
		}

	}

}