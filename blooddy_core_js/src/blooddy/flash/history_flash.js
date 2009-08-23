/*!
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( 'blooddy not initialized.' );

blooddy.require( 'blooddy.Flash.ExternalFlash' );
blooddy.require( 'blooddy.utils.history' );

if ( !blooddy.Flash.HistoryFlash ) {

	/**
	 * @class
	 * класс работает с историей страницы и передаёт информацию флэшке
	 * @namespace	blooddy.Flash
	 * @extends		blooddy.Flash.ExternalFlash
	 * @requires	blooddy.utils.history
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.Flash.HistoryFlash = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var	Flash =			blooddy.Flash,
			ExternalFlash =	Flash.ExternalFlash,
			history =		blooddy.utils.history,

			_flashs = new Object();

		//--------------------------------------------------------------------------
		//
		//  Event handlres
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var initHandler = function() {
			history.addEventListener( 'change', this, changeHandler );
			var href = history.getHREF();
			if ( href ) {
				changeHandler.call( this );
			}
		}

		/**
		 * @private
		 */
		var changeHandler = function() {
			HistoryFlash.superPrototype.dispatchEvent.call( this, new blooddy.events.Event( 'historyChange' ) );
		}

		//-------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @constructor
		 * @param	{String}	id		ID флэшки
		 * @throws	{Error}				Object already created
		 */
		var HistoryFlash = function(id) {
			if ( _flashs[ id ] ) throw new Error( 'Object already created.' );
			_flashs[ id ] = this;
			HistoryFlash.superPrototype.constructor.call( this, id );
			if ( !this.isInitialized() ) {
				this.addEventListener( 'init', this, initHandler );
			} else {
				initHandler.call( this );
			}
		}

		blooddy.extend( HistoryFlash, ExternalFlash );

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @see		blooddy.utils.History#isAvailable
		 * @return	{Boolean}
		 */
		HistoryFlash.prototype.isHistoryAvailable = function() {
			history.isAvailable();
		}

		/**
		 * @method
		 * @see		blooddy.utils.History#back
		 */
		HistoryFlash.prototype.back = function() {
			history.back();
		};

		/**
		 * @method
		 * @see		blooddy.utils.History#forward
		 */
		HistoryFlash.prototype.forward = function() {
			history.forward();
		};

		/**
		 * @method
		 * @see		blooddy.utils.History#go
		 * @param	{Number}
		 */
		HistoryFlash.prototype.go = function(delta) {
			history.go( delta );
		};

		/**
		 * @method
		 * @see		blooddy.utils.History#up
		 */
		HistoryFlash.prototype.up = function() {
			history.up();
		};

		/**
		 * @method
		 * @see		blooddy.utils.History#getHREF
		 * @return	{String}
		 */
		HistoryFlash.prototype.getHREF = function() {
			return history.getHREF();
		};

		/**
		 * @method
		 * @see		blooddy.utils.History#setHREF
		 * @param	{String}	value
		 */
		HistoryFlash.prototype.setHREF = function(value) {
			history.setHREF( value );
		};

		/**
		 * @method
		 * @see		blooddy.utils.History#getTitle
		 * @return	{String}
		 */
		HistoryFlash.prototype.getTitle = function() {
			return history.getTitle();
		};
	
		/**
		 * @method
		 * @see		blooddy.utils.History#setTitle
		 * @param	{String}
		 */
		HistoryFlash.prototype.setTitle = function(value) {
			history.setTitle( value );
		};

		/**
		 * @method
		 * @override
		 * подготавливает объект к удалению
		 */
		HistoryFlash.prototype.dispose = function() {
			history.removeEventListener( 'change', this );
			if ( _flashs[ this._id ] === this ) {
				delete _flashs[ this._id ];
			}
			HistoryFlash.superPrototype.dispose.call( this );
		}

		/**
		 * @method
		 * @return	{String}
		 */
		HistoryFlash.prototype.toString = function() {
			return '[HistoryFlash id="' + this._id + '"]';
		}

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @static
		 * @method
		 * Вставляет флэшку в HTML и генерирует контроллер
		 * @param	{String}						id			ID флэшки
		 * @param	{String}						uri			путь к флэшке
		 * @param	{Number}						width		ширина флэшки
		 * @param	{Number}						height		высота флэшки
		 * @param	{blooddy.utils.Version}			version		минимальная версияплэйера 
		 * @param	{Object}						flashvars	переменные лэфшки
		 * @param	{Object}						parameters	параметры флэшки
		 * @param	{Object}						attributes	атрибуты флэшки
		 * @return	{blooddy.Flash.HistoryFlash}				контроллер Flash-объекта
		 */
		HistoryFlash.createFlash = function(id, uri, width, height, version, flashvars, parameters, attributes) {
			if ( ExternalFlash.embedSWF( id, uri, width, height, version, flashvars, parameters, attributes ) ) {
				return HistoryFlash.getFlash( id );
			}
			return null;
		}

		/**
		 * @static
		 * проверяет существование конроллера
		 * @param	{String}	id			ID флэшки
		 * @return	{Boolean}
		 */
		HistoryFlash.hasFlash = function(id) {
			return Boolean( _flashs[ id ] );
		}

		/**
		 * @static
		 * @method
		 * возвращает существующий конроллер, или создаёт новый
		 * @param	{String}						id	ID флэшки
		 * @return	{blooddy.Flash.HistoryFlash}		контроллер Flash-объекта
		 * @throws	{Error}								Object already created as bloddy.Flash
		 */
		HistoryFlash.getFlash = function(id) {
			var flash = _flashs[ id ];
			if ( !flash ) {
				if ( Flash.hasFlash( id ) ) throw new Error( 'Object already created as blooddy.Flash' );
				flash = new HistoryFlash( id );
			}
			return flash;
		}

		/**
		 * @static
		 * @method
		 * @return	{String}
		 */
		HistoryFlash.toString = function() {
			return '[class HistoryFlash]';
		}

		return HistoryFlash;

	}() );

}