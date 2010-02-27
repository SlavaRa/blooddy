////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.events.IEventDispatcher;

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Транслиуется, когда приходят байты данных.
	 * 
	 * @eventType			flash.events.ProgressEvent.PROGRESS
	 */
	[Event( name="progress", type="flash.events.ProgressEvent" )]
	
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