////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display.text {
	
	import by.blooddy.core.blooddy;
	import by.blooddy.core.utils.ClassAlias;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;

	//--------------------------------------
	//  Aliases
	//--------------------------------------
	
	ClassAlias.registerQNameAlias( new QName( blooddy, 'TextField' ), BaseTextField );

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 1, 2010 1:15:43 PM
	 */
	public class BaseTextField extends TextField {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function BaseTextField() {
			super();
			super.mouseEnabled = false;
			super.addEventListener( Event.ADDED,				this.handler_added,				false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED,				this.handler_removed,			false, int.MAX_VALUE, true );
			super.addEventListener( Event.ADDED_TO_STAGE,		this.handler_addedToStage,		false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE,	this.handler_removedFromStage,	false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Includes
		//
		//--------------------------------------------------------------------------
		
		include "../../../../../includes/implements_BaseDisplayObject.as";

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_added(event:Event):void {
			if ( event.target !== this ) {
				// останавливаем расспостранение события
				// наши родители даже не догадываются о его существовании
				event.stopImmediatePropagation();
				// если пришёл Loader, то надо подписаться на всяческие ошибки
				if ( event.target is Loader ) {
					// так как мы не собираемся контролировать объект, лучше подпишимся со слабыми ссылками
					var loader:LoaderInfo = ( event.target as Loader ).contentLoaderInfo;
					loader.addEventListener( Event.COMPLETE,		this.handler_complete, false, int.MAX_VALUE, true );
					loader.addEventListener( IOErrorEvent.IO_ERROR,	this.handler_complete, false, int.MAX_VALUE, true );
				}
			}
		}
		
		/**
		 * @private
		 */
		private function handler_removed(event:Event):void {
			if ( event.target !== this ) {
				// останавливаем расспостранение события
				// наши родители даже не догадываются о его существовании
				event.stopImmediatePropagation();
				// если пришёл Loader, то надо отписаться на всяческие ошибки
				if ( event.target is Loader ) {
					// отписываемся
					var loader:LoaderInfo = ( event.target as Loader ).contentLoaderInfo;
					loader.removeEventListener( Event.COMPLETE,			this.handler_complete );
					loader.removeEventListener( IOErrorEvent.IO_ERROR,	this.handler_complete );
					// TODO: uncatch errors
				}
			}
		}
		
		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			var loader:LoaderInfo = event.target as LoaderInfo;
			loader.removeEventListener( Event.COMPLETE,			this.handler_complete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR,	this.handler_complete );
			// TODO: uncatch errors
		}
		
	}
	
}