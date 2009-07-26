////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//  © 2006 Claus Wahlers and Max Herkender
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events {

	import by.blooddy.core.net.zip.FZipFile;

	import by.blooddy.core.utils.ClassUtils;

	import flash.events.Event;

	/**
	 * Евент зип парсера.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					fzipevent, fzip, zip, fzipfile, zipfile, file, event
	 * 
	 * @see						by.blooddy.core.net.FZip
	 */
	public class FZipEvent extends Event {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @eventType			extract
		 */
		public static const EXTRACT:String = "extract";

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	type			The event type; indicates the action that caused the event.
		 * @param	bubbles			Specifies whether the event can bubble up the display list hierarchy.
		 * @param	cancelable		Specifies whether the behavior associated with the event can be prevented.
		 * @param	file			Распокованный зип-файл.
		 */
		public function FZipEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, file:FZipFile=null) {
			super(type, bubbles, cancelable);
			this.file = file;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  file
		//----------------------------------

		/**
		 * Имя изменённого "пучка".
		 * 
		 * @keyword					fzipevent.file, file
		 */
		public var file:FZipFile;

		//--------------------------------------------------------------------------
		//
		//  Overridden methods: Event
		//
		//--------------------------------------------------------------------------

	    /**
	     * @private
	     */
		public override function clone():Event {
			return new FZipEvent(this.type, this.bubbles, this.cancelable, this.file);
		}

	    /**
	     * @private
	     */
		public override function toString():String {
			return super.formatToString(ClassUtils.getClassName(this), "type", "bubbles", "cancelable", "file");
		}

	}

}