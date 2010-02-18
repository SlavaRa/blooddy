////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

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

		function readCommand(input:IDataInput, io:String='input'):NetCommand;

		function writeCommand(output:IDataOutput, command:NetCommand):void;

	}

}