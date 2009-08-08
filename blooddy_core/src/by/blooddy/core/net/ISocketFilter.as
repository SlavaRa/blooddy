////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.events.net.CommandEvent;

	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					socketfilter, filter, socket
	 */
	public interface ISocketFilter {
/*
		function readInputCommand(input:IDataInput):NetCommand;

		function writeInputCommand(output:IDataOutput, command:NetCommand):void;

		function readOutputCommand(input:IDataInput):NetCommand;

		function writeOutputCommand(output:IDataOutput, command:NetCommand):void;
*/
		function readCommand(input:IDataInput, io:String="input"):NetCommand;

		function writeCommand(output:IDataOutput, command:NetCommand):void;

//		function createNetCommandEvent(command:NetCommand):NetCommandEvent;

	}

}