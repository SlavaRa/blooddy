/*!
 * blooddy/logger.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

if ( !blooddy.Logger ) {

	blooddy.require( 'blooddy.events.EventDispatcher' );

	/**
	 * @class
	 * логгер
	 * @namespace	blooddy
	 * @extends		blooddy.events.EventDispatcher
	 * @requires	blooddy.utils.Version
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.Logger = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var $ =			blooddy,
			utils =		$.utils,

			EE_A =		'addedLog';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 * @param	{Number}	maxLength
		 * @param	{Number}	maxTime
		 */
		var Logger = function(maxLength, maxTime, minLength) {
			LoggerSuperPrototype.constructor.call( this );
			this._maxLength =	( isNaN( maxLength ) ? 50 : maxLength );
			this._maxTime =		( isNaN( maxTime ) ? 5*60e3 : maxTime );
			this._minLength =	( minLength || 0 );
			this._list =		new Array();
		};

		$.extend( Logger, $.events.EventDispatcher );

		var	LoggerPrototype =		Logger.prototype,
			LoggerSuperPrototype =	Logger.superPrototype;

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @type	{Array}
		 */
		LoggerPrototype._list = null;

		/**
		 * @private
		 * @type	{Number}
		 */
		LoggerPrototype._minLength = null;

		/**
		 * @private
		 * @type	{Number}
		 */
		LoggerPrototype._maxLength = null;

		/**
		 * @private
		 * @type	{Number}
		 */
		LoggerPrototype._maxTime = null;

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var updateList = function(scope) {
			var	time = utils.getTime(),
				l = scope._list.length,
				i;
			for ( i=0; i<l; i++ ) {
				if ( time - scope._list[i].time < scope._maxTime ) {
					break;
				}
			}
			if ( l - i > this._minLength ) {
				if ( l - i > scope._maxLength ) {
					i = l - scope._maxLength;
				}
				if ( i > 0 ) {
					scope._list.splice( 0, i );
				}
			}
		};

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  length
		//----------------------------------

		/**
		 * @method
		 * @return	{Number}
		 */
		LoggerPrototype.getLength = function() {
			return this._list.length;
		};

		//----------------------------------
		//  minLength
		//----------------------------------

		/**
		 * @method
		 * @private
		 */
		LoggerPrototype._minLength = 0;

		/**
		 * @method
		 * @return	{Number}
		 */
		LoggerPrototype.getMinLength = function() {
			return this._minLength;
		};

		/**
		 * @method
		 * @param	{Number}	value
		 */
		LoggerPrototype.setMinLength = function(value) {
			if ( this._minLength == value ) return;
			this._minLength = Math.min( value || 0, this._maxLength );
		};

		//----------------------------------
		//  maxLength
		//----------------------------------

		/**
		 * @private
		 */
		LoggerPrototype._maxLength = 0;

		/**
		 * @method
		 * @return	{Number}
		 */
		LoggerPrototype.getMaxLength = function() {
			return this._maxLength;
		};

		/**
		 * @method
		 * @param	{Number}	value
		 */
		LoggerPrototype.setMaxLength = function(value) {
			if ( this._maxLength == value ) return;
			this._maxLength = value;
			updateList( this );
		};

		//----------------------------------
		//  maxTime
		//----------------------------------

		/**
		 * @private
		 */
		LoggerPrototype._maxTime = 0;

		/**
		 * @method
		 * @return	{Number}
		 */
		LoggerPrototype.getMaxTime = function() {
			return this._maxTime;
		};

		/**
		 * @method
		 * @param	{Number}	value
		 */
		LoggerPrototype.setMaxTime = function(value) {
			if ( this._maxTime == value ) return;
			this._maxTime = value;
			updateList( this );
		};

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @param	{blooddy.Logger.Log}	log
		 */
		LoggerPrototype.addLog = function(log) {
			this._list.push( log );
			updateList( this );
			if ( this.hasEventListener( EE_A ) ) {
				var event = new $.events.Event( EE_A );
				event.log = log;
				this.dispatchEvent( event );
			}
		};

		/**
		 * @method
		 * @return	{Array}
		 */
		LoggerPrototype.getList = function() {
			return this._list.slice();
		};

		/**
		 * @method
		 * @override
		 * подготавливает объект к удалению
		 */
		LoggerPrototype.dispose = function() {
			this._list.splice( 0, this._list.length );
			this._list = null;
			LoggerSuperPrototype.dispose.call( this );
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		LoggerPrototype.toString = function() {
			return '[Logger object]';
		};

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @static
		 * @method
		 * @override
		 * @return	{String}
		 */
		Logger.toString = function() {
			return '[class Logger]';
		};

		return Logger;

	}() );

}