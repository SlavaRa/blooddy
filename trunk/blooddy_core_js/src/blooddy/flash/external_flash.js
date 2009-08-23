/*!
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( 'blooddy not initialized.' );

blooddy.require( 'blooddy.Flash' );

if ( !blooddy.Flash.ExternalFlash ) {

	/**
	 * @class
	 * класс, который умеет общаться с флэш объектами
	 * @namespace	blooddy.Flash
	 * @extends		blooddy.Flash
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.Flash.ExternalFlash = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var	Flash =			blooddy.Flash,
			Event =			blooddy.events.Event,

			OBJECT =		'object',

			_flashs =		new Object(),
			_min_version =	new blooddy.utils.Version( 8 );

		//--------------------------------------------------------------------------
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
		var ExternalFlash = function(id) {
			if ( _flashs[ id ] ) throw new Error( 'Object already created.' );
			_flashs[ id ] = this;
			ExternalFlash.superPrototype.constructor.call( this, id );
		}

		blooddy.extend( ExternalFlash, Flash );

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @return	{Boolean}
		 */
		ExternalFlash.prototype.isInitialized = function() {
			return '__flash__call' in this.getElement();
		}

		/**
		 * @method
		 * вызывает произвольный метод у флэшки
		 * @param	{String}	methodName		имя метода
		 * @param				...rest			параметры
		 * @return	{Object}					результат работы метода
		 */
		ExternalFlash.prototype.call = function(methodName) {
			var	i,
				l =			arguments.length,
				args =		new Array(),
				element =	document.getElementById( this._id );
			for ( i=0; i<l; i++ ) {
				args[ i ] = arguments[ i ];
			}
			args.unshift( this._id );
			return element.__flash__call.apply( element, args );
		}

		/**
		 * @method
		 * @override
		 * диспатчит событие у флэшки
		 * @param	{blooddy.events.Event}	event	событие
		 * @return	{Boolean}						true - елси событие завершило работы, false - если было отменено
		 */
		ExternalFlash.prototype.dispatchEvent = function(event) {
			var	o =		new Object(),
				key;
			for ( key in event ) {
				if ( key in Event.prototype ) continue;
				o[ key ] = o[ key ];
			}
			return this.call( 'dispatchEvent', event.type, event.cancelable, o );
		}

		/**
		 * @method
		 * пытается запросить свойство у флэшки
		 * @param	{String}	name	ключ свойства
		 * @return	{Object}			значение  свойства
		 */
		ExternalFlash.prototype.getProperty = function(name) {
			return this.call( 'getProperty', name );
		}

		/**
		 * @method
		 * пытается установить свойство у флэшки
		 * @param	{String}	name	ключ свойства
		 * @param	{Object}	value	значение  свойства
		 */
		ExternalFlash.prototype.setProperty = function(name, value) {
			this.call( 'setProperty', name, value );
		}

		/**
		 * @method
		 * @override
		 * подготавливает объект к удалению
		 */
		ExternalFlash.prototype.dispose = function() {
			if ( _flashs[ this._id ] === this ) {
				delete _flashs[ this._id ];
			}
			ExternalFlash.superPrototype.dispose.call( this );
		}

		/**
		 * @method
		 * @return	{String}
		 */
		ExternalFlash.prototype.toString = function() {
			return '[ExternalFlash id="' + this._id + '"]';
		}

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @static
		 * @method
		 * Вставляет флэшку в HTML, автоматически прописывая ей некоторые парметры. 
		 * @param	{String}				id			ID флэшки
		 * @param	{String}				uri			путь к флэшке
		 * @param	{Number}				width		ширина флэшки
		 * @param	{Number}				height		высота флэшки
		 * @param	{blooddy.utils.Version}	version		минимальная версияплэйера 
		 * @param	{Object}				flashvars	переменные лэфшки
		 * @param	{Object}				parameters	параметры флэшки
		 * @param	{Object}				attributes	атрибуты флэшки
		 * @return	{HTMLElement}						Flash-объект
		 */
		ExternalFlash.embedSWF = function(id, uri, width, height, version, flashvars, parameters, attributes) {
			var	key,
				value,
				params =	new Object(),
				fv =		new Object();

			if ( _min_version.compare( Flash.getPlayerVersion() ) > 0 ) {
				return null;
			}

			if ( parameters && typeof parameters == OBJECT ) {
				for ( key in parameters ) {
					value = parameters[ key ];
					if ( key in Object.prototype ) continue;
					switch ( key.toLowerCase() ) {
						case 'flashvars':
						case 'movie':				value = null;	break;
					}
					if ( !value ) continue;
					params[ key ] = value;
				}
			}
			params.swLiveConnect = true;
			params.allowScriptAccess = 'always';

			if ( flashvars && typeof flashvars == OBJECT ) {
				for ( key in flashvars ) {
					value = flashvars[ key ];
					if ( key in Object.prototype ) continue;
					if ( !value ) continue;
					fv[ key ] = value;
				}
			}
			fv.externalID = id;

			return Flash.embedSWF( id, uri, width, height, version, fv, params, attributes );
		}

		/**
		 * @static
		 * @method
		 * Вставляет флэшку в HTML и генерирует контроллер
		 * @param	{String}				id			ID флэшки
		 * @param	{String}				uri			путь к флэшке
		 * @param	{Number}				width		ширина флэшки
		 * @param	{Number}				height		высота флэшки
		 * @param	{blooddy.utils.Version}	version		минимальная версияплэйера 
		 * @param	{Object}				flashvars	переменные лэфшки
		 * @param	{Object}				parameters	параметры флэшки
		 * @param	{Object}				attributes	атрибуты флэшки
		 * @return	{blooddy.Flash}						контроллер Flash-объекта
		 */
		ExternalFlash.createFlash = function(id, uri, width, height, version, flashvars, parameters, attributes) {
			if ( ExternalFlash.embedSWF( id, uri, width, height, version, flashvars, parameters, attributes ) ) {
				return ExternalFlash.getFlash( id );
			}
			return null;
		}

		/**
		 * @static
		 * проверяет существование конроллера
		 * @param	{String}	id			ID флэшки
		 * @return	{Boolean}
		 */
		ExternalFlash.hasFlash = function(id) {
			return Boolean( _flashs[ id ] );
		}

		/**
		 * @static
		 * @method
		 * возвращает существующий конроллер, или создаёт новый
		 * @param	{String}						id	ID флэшки
		 * @return	{blooddy.Flash.ExternalFlash}		контроллер Flash-объекта
		 * @throws	{Error}								Object already created as blooddy.Flash
		 */
		ExternalFlash.getFlash = function(id) {
			var	flash = _flashs[ id ];
			if ( !flash ) {
				if ( Flash.hasFlash( id ) ) throw new Error( 'Object already created as blooddy.Flash' );
				flash = new ExternalFlash( id );
			}
			return flash;
		}

		/**
		 * @static
		 * @method
		 * @return	{String}
		 */
		ExternalFlash.toString = function() {
			return '[class ExternalFlash]';
		}

		return ExternalFlash;

	}() );

	/**
	 * @static
	 * @method
	 * @final
	 * глобальный метод, который ловит вызовы флэшек и распределяет по контроллерам.
	 * @param	{String}	id				ID флэшки
	 * @param	{String}	methodName		имя метода
	 * @param				...rest			параметры
	 * @return	{Object}					результат работы метода
	 * @throws	{Error}						ioError
	 * @author	BlooDHounD	<http://www.blooddy.by>
	 */
	function __flash__call(id, commandName) {

		var	ExternalFlash =	blooddy.Flash.ExternalFlash,
			flash =			ExternalFlash.getFlash( id ),
			a =				arguments;

		if ( !flash || !( flash instanceof ExternalFlash ) ) {
			throw new Error( 'ioError' );
		}

		switch ( commandName ) {

			case 'dispatchEvent':
				var	event = a[ 4 ] || new Object();
				event.type = a[ 2 ];
				event.cancelable = a[ 3 ];
				return ExternalFlash.superPrototype.dispatchEvent.call( flash, event );

			case 'getProperty':
				return this[ arguments[ 2 ] ];

			case 'setProperty':
				this[ arguments[ 2 ] ] = arguments[ 3 ];
				break;

			default:
				if ( !flash[ commandName ] ) {
					throw new Error( 'ioError' );
				}
				var	l =		arguments.length,
					i,
					args =	new Array();
				for ( i=2; i<l; i++ ) {
					args[ i-2 ] = arguments[ i ];
				}
				return flash[ commandName ].apply( flash, args );

		}
		return undefined;
	}

}