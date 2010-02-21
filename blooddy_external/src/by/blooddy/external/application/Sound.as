////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.external.application {

	import by.blooddy.core.net.ProxySharedObject;
	import by.blooddy.external.media.SoundController;
	
	import flash.display.Sprite;
	
	[SWF( width="1", height="1", frameRate="120", backgroundColor="#FF0000" )]
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.11.2009 3:24:22
	 */
	public class Sound extends Sprite {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function Sound() {
			super();
			this._controller = new SoundController( this, this.loaderInfo.parameters.so );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _controller:SoundController;
		
	}
	
}