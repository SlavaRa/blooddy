////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.commands.CommandDispatcher;
	import by.blooddy.core.logging.ILogging;
	import by.blooddy.core.logging.InfoLog;
	import by.blooddy.core.logging.Logger;
	import by.blooddy.core.logging.commands.CommandLog;
	
	import flash.events.AsyncErrorEvent;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * какая-то ошибка при исполнении.
	 */
	[Event( name="asyncError", type="flash.events.AsyncErrorEvent" )]	

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					iconnection, connection
	 */
	public class AbstractRemoter extends CommandDispatcher implements IRemoter, ILogging {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructior
		 */
		public function AbstractRemoter(unassisted:Boolean=false) {
			super();
			this._client = this;
			this._unassisted = unassisted;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _unassisted:Boolean;

		//--------------------------------------------------------------------------
		//
		//  Implements properties: INetConnection
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  client
		//----------------------------------

		/**
		 * @private
		 */
		private var _client:Object;

		/**
		 * @inheritDoc
		 */
		public function get client():Object {
			return this._client;
		}

		/**
		 * @private
		 */
		public function set client(value:Object):void {
			if ( this._client === value ) return;
			this._client = value || this;
		}

		//----------------------------------
		//  logger
		//----------------------------------

		/**
		 * @private
		 */
		private const _logger:Logger = new Logger();

		/**
		 * @inheritDoc
		 */
		public function get logger():Logger {
			return this._logger;
		}

		//----------------------------------
		//  logging
		//----------------------------------

		/**
		 * @private
		 */
		private var _logging:Boolean = true;

		/**
		 * @inheritDoc
		 */
		public function get logging():Boolean {
			return this._logging;
			
		}

		/**
		 * @private
		 */
		public function set logging(value:Boolean):void {
			if ( this._logging == value ) return;
			this._logging = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IConnection
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function call(commandName:String, ...parameters):* {
			return this.$invokeCallOutputCommand( new Command( commandName, parameters ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  output
		//----------------------------------

		protected function $invokeCallOutputCommand(command:Command!, async:Boolean=true):* {
			if ( this._logging && ( !( command is NetCommand ) || !( command as NetCommand ).system ) ) {
				this._logger.addLog( new CommandLog( command ) );
			}
			if ( async ) {
				
				try { // отлавливаем ошибки выполнения
					return this.$callOutputCommand( command );
				} catch ( e:Error ) {
					if ( this._logging ) {
						this._logger.addLog( new InfoLog( ( e.toString() || e.getStackTrace() ), InfoLog.ERROR ) );
						trace( e.getStackTrace() || e.toString() );
					}
					if ( super.hasEventListener( AsyncErrorEvent.ASYNC_ERROR ) || !this._unassisted ) {
						super.dispatchEvent( new AsyncErrorEvent( AsyncErrorEvent.ASYNC_ERROR, false, false, e.toString(), e ) );
					}
				}
				
			} else {
				
				return this.$callOutputCommand( command );
				
			}
			
		}

		protected function $callOutputCommand(command:Command):* {
			return this.$invokeCallInputCommand( command, false );
		}

		//----------------------------------
		//  input
		//----------------------------------

		protected function $invokeCallInputCommand(command:Command!, async:Boolean=true):* {

			if ( this._logging && ( !( command is NetCommand ) || !( command as NetCommand ).system ) ) {
				this._logger.addLog( new CommandLog( command ) );
			}

			if ( async ) {

				try { // отлавливаем ошибки выполнения
					return this.$callInputCommand( command );
				} catch ( e:Error ) {
					if ( this._logging ) {
						this._logger.addLog( new InfoLog( ( e.toString() || e.getStackTrace() ), InfoLog.ERROR ) );
						trace( e.getStackTrace() || e.toString() );
					}
					if ( super.hasEventListener( AsyncErrorEvent.ASYNC_ERROR ) || !this._unassisted ) {
						super.dispatchEvent( new AsyncErrorEvent( AsyncErrorEvent.ASYNC_ERROR, false, false, e.toString(), e ) );
					}
				}

			} else {

				return this.$callInputCommand( command );

			}

		}

		protected function $callInputCommand(command:Command):* {
			if ( !command ) throw new ArgumentError(); // TODO: описать ошибку
			// пытаемся выполнить что-нить
			var result:*;
			var has:Boolean = command.name in this._client;
			if ( has ) {
				result = command.call( this._client );
			}
			// проверим нету ли хендлера на нашу комманду
			if ( super.hasCommandListener( command.name ) ) {
				super.dispatchCommand( command );
			} else if ( !has ) {
				throw new DefinitionError( 'не найдено слушетелей команды: ' + command );
			}
			return result;
		}

	}

}