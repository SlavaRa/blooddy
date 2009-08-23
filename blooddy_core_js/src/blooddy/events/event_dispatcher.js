/*!
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( 'blooddy not initialized.' );

blooddy.require( 'blooddy.events.Event' );

if ( !blooddy.events.EventDispatcher ) {

	/**
	 * @class
	 * базовый класс дляработы с событиями
	 * @namespace	blooddy.events
	 * @requires	blooddy.events.Event
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.events.EventDispatcher = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var	Event = blooddy.events.Event;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 * @param	{Object}	target		контекст событий
		 */
		var EventDispatcher = function(target) {
			this._listeners = new Object();
			this._event_target = ( target || this );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @property
		 * @type	{Object}
		 */
		EventDispatcher.prototype._listeners = null;

		/**
		 * @private
		 * @property
		 * @type	{Object}
		 */
		EventDispatcher.prototype._event_target = null;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * добавляет новго слушателя
		 * @param	{String}	type		тип события
		 * @param	{Object}	scope		контекст слушателя
		 * @param	{Object}	listener	слушатель
		 * @param	{Number}	priority	приоритет
		 */
		EventDispatcher.prototype.addEventListener = function(type, scope, listener, priority) {
			if ( !type || ( ( typeof listener != 'string' || !scope ) && typeof listener != 'function' ) ) return;
			if ( isNaN( priority ) ) priority = 0;
			var	arr = this._listeners[ type ];
			if ( arr ) {
				//проверить, есть ли уже такой листенер, и не дать подписаться второй раз
				var	i =		0,
					l =		arr.length,
					o,
					ot,
					index =	l;
				for ( ; i < l; i++ ) {
					o = arr[i];
					if ( o.scope == scope && o.listener == listener ) {
						if ( o.priority === priority ) return; // всё и так ништяк
						ot = o;
						arr.splice( i, 1 );
						l--;
						i--;
						break;
					}
					if ( o.priority < priority ) {
						index = i;
						break;
					}
				}
				if ( !ot ) {
					for ( ; i < l; i++ ) {
						o = arr[i];
						if ( o.scope == scope && o.listener == listener ) {
							if ( o.priority === priority ) return; // всё и так ништяк
							ot = o;
							arr.splice( i, 1 );
							break;
						}
					}
					if ( !ot ) {
						ot = {
							scope: ( scope || null ),
							listener: listener
						}
					}
				} else {
					if ( index == l ) {
						for ( ; i < l; i++ ) {
							if ( o.priority < priority ) {
								index = i;
								break;
							}
						}
					}
				}
	
				ot.priority = priority;
	
				arr.splice( index, 0, ot );
			} else {
				this._listeners[ type ] = new Array( {
					priority: priority,
					scope: ( scope || null ),
					listener: listener
				} );
			}
		}

		/**
		 * @method
		 * удаляет слушателя
		 * @param	{String}	type		тип события
		 * @param	{Object}	scope		контекст слушателя
		 * @param	{Object}	listener	слушатель
		 */
		EventDispatcher.prototype.removeEventListener = function(type, scope, listener) {
			var	arr = this._listeners[ type ],
				j,
				o;
			if ( !arr ) return;
			if ( scope ) {
				if ( listener ) {
					for ( j in arr ) {
						o = arr[j];
						if ( o.scope == scope && o.listener == listener ) {
							delete o.scope;
							delete o.listener;
							arr.splice( Number(j), 1 );
							break;
						}
					}
				} else {
					for ( j in arr ) {
						o = arr[j];
						if ( o.scope == scope ) {
							delete o.scope;
							delete o.listener;
							arr.splice( Number(j), 1 );
						}
					}
				}
			} else {
				if ( typeof listener == 'function' ) {
					for ( j in arr ) {
						o = arr[j];
						if ( !o.scope && o.listener === listener ) {
							delete o.scope;
							delete o.listener;
							arr.splice( Number(j), 1 );
						}
					}
				}
			}
			if ( arr.length <= 0 ) delete this._listeners[ type ];
		}

		/**
		 * @method
		 * распотраняет событие
		 * @param	{blooddy.events.Event}	event	событие
		 * @return	{Boolean}						true - елси событие завершило работы, false - если было отменено
		 */
		EventDispatcher.prototype.dispatchEvent = function(event) {
			if ( !( event instanceof Event ) ) event = Event.IEvent( event );
			event.target = this._event_target;
			var	arr = this._listeners[ event.type ];
			if ( arr ) {
				arr = arr.slice(); // копируем, чтобы удаление на нас не повлияло
				var	obj,
					e,
					i,
					l =	arr.length;
				for ( i=0; i<arr.length; i++ ) {
					obj = arr[i];
					if ( !obj.listener || ( !obj.scope && obj.scope !== null ) ) continue; // FIXME: удалить нафиг
					e = event.clone();
					if ( typeof obj.listener == 'function' ) {
						obj.listener.call( obj.scope, e );
					} else {
						obj.scope[ obj.listener ]( e );
					}
					// нас отменили. надо превать распостранение события
					if ( event.cancelable && e.isDefaultPrevented() ) {
						return false;
					}
					if ( e._do_stop ) {
						return true; // выход из цикла
					}
				}
				if ( arr.length <= 0 ) delete this._listeners[ event._type ];
			}
			return true;
		}

		/**
		 * @method
		 * проверяет наличие слушателя
		 * @param	{String}	type	тип события
		 * @return	{Boolean}
		 */
		EventDispatcher.prototype.hasEventListener = function(type) {
			return Boolean( this._listeners[ type ] );
		}

		/**
		 * @method
		 * подготавливает объект к удалению
		 */
		EventDispatcher.prototype.dispose = function() {
			this._event_target = null;
			var i,
				arr;
			for ( i in this.__listeners ) {
				arr = this.__listeners[ i ];
				arr.splice( 0, arr.length );
				delete this.__listeners[ i ];
			}
		}

		/**
		 * @method
		 * @return	{String}
		 */
		EventDispatcher.prototype.toString = function() {
			return '[EventDispatcher' +
				( this._event_target !== this ? ' (' + this._event_target + ')' : '' ) +
			']';
		}

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @static
		 * @method
		 * @return	{String}
		 */
		EventDispatcher.toString = function() {
			return '[class EventDispatcher]';
		}

		return EventDispatcher;

	}() );

}