/*!
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( 'blooddy not initialized.' );

blooddy.require( 'blooddy.events' );

if ( !blooddy.events.Event ) {

	/**
	 * @class
	 * класс осбытия
	 * @namespace	blooddy.events
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.events.Event = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 * @constructor
		 * @param	{String}	type			тип события
		 * @param	{Boolean}	cancelable		отменяемо ли соыбтие?
		 */
		var Event = function(type, cancelable) {
			this.type = type;
			this.cancelable = cancelable;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @property
		 * @type	{Boolean}
		 */
		Event.prototype._do_cancel = false;
	

		/**
		 * @private
		 * @property
		 * @type	{Boolean}
		 */
		Event.prototype._do_stop = false;
	
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @property
		 * тип события
		 * @type	{String}
		 */
		Event.prototype.type = null;
	
		/**
		 * @property
		 * вызыватель события :)
		 * @type	{Object}
		 */
		Event.prototype.target = null;
	
		/**
		 * @property
		 * отменяемо ли?
		 * @type	{Boolean}
		 */
		Event.prototype.cancelable = false;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
	
		/**
		 * @method
		 * клонирует событие.
		 * @return	{blooddy.events.Event}	новое событие
		 */
		Event.prototype.clone = function() {
			var	c = this.constructor || Event,
				event = new c(),
				key;
			for ( key in this ) {
				if ( key in c.prototype ) continue;
				event[ key ] = this[ key ];
			}
			return event;
		}

		/**
		 * @method
		 * останавливает распостранение.
		 */
		Event.prototype.stopPropagation = function() {
			this._do_stop = true;
		}

		/**
		 * @method
		 * отменяет событие
		 */
		Event.prototype.preventDefault = function() {
			if ( this.cancelable ) {
				this._do_cancel = true;
			}
		}

		/**
		 * @method
		 * событие было отменено
		 * @return	{Boolean}
		 */
		Event.prototype.isDefaultPrevented = function() {
			return this._do_cancel;
		}
	
		/**
		 * @method
		 * приводит к строковому виду
		 */
		Event.prototype.toString = function() {
			var	arr = new Array(),
				i,
				s;
			for ( i in this ) arr.push( i );
			for ( i in arr ) {
				s = ( typeof this[ arr[ i ] ] == 'string' );
				arr[ i ] += '=' + ( s ? '"' : '' ) + this[ arr[ i ] ] + ( s ? '"' : '' );
			}
			return '[Event ' + arr.join( ' ' ) + ']';
		}

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
	
		/**
		 * @static
		 * @method
		 * конвертирует объект в Event.
		 * @param		object		объект, который надо сконвертировать
		 */
		Event.IEvent = function(object) {
			if ( !object || !object.type ) return null;
			else if ( object instanceof Event ) return object;
			var	result = new Event( object.type, object.cancelable ),
				key;
			for ( key in object ) {
				if ( key in Event.prototype ) continue;
				result[ i ] = object[ i ];
			}
			return result;
		}

		/**
		 * @static
		 * @method
		 * @return	{String}
		 */
		Event.toString = function() {
			return '[class Event]';
		}
	
		return Event;

	}() );

}