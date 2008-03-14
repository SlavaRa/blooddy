////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.managers {

	import flash.events.IEventDispatcher;

	[Event(name="progress", type="flash.events.ProgressEvent")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					progress
	 */
	public interface IProgressable extends IEventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  progress
		//----------------------------------

		/**
		 * Значение прогресса.
		 * 
		 * @keyword					progress.progress, progress
		 * 
		 * @see						flash.events.ProgressEvent
		 */
		function get progress():Number;

	}

}