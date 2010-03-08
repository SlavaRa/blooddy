////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.net.Responder;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class Responder extends flash.net.Responder {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function Responder(result:Function, status:Function=null) {

			super( result, status );

			this._result = result;
			this._status = status;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _result:Function;

		internal function get result():Function {
			return this._result;
		}

		/**
		 * @private
		 */
		private var _status:Function;

		internal function get status():Function {
			return this._status;
		}

	}

}