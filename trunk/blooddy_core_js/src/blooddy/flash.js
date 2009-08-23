/*!
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( 'blooddy not initialized.' );

blooddy.require( 'blooddy.utils.Version' );
blooddy.require( 'blooddy.events.EventDispatcher' );

if ( !blooddy.Flash ) {

	/**
	 * @class
	 * базовый класс работы с Flash-объектами
	 * @namespace	blooddy
	 * @extends		blooddy.events.EventDispatcher
	 * @requires	blooddy.utils.Version
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.Flash = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @static
		 * @method
		 * создаёт flash-объект при пощи DOM
		 * @param	{HTMLElement}	element		объект для замены флэшкой
		 * @param	{String}		id			ID флэшки
		 * @param	{String}		uri			путь к флэшке
		 * @param	{Object}		attributes	атрибуты флэшки
		 * @param	{Object}		parameters	параметры флэшки
		 * @return	{HTMLElement}	Flash-объект
		 */
		var createSWF = function(element, id, uri, attributes, parameters) {
			var	key,
				o = doc.createElement( OBJECT ),
				p;
			for ( key in attributes ) {
				if ( key in Object.prototype ) continue;
				o.setAttribute( key, attributes[ key ] );
			}
			o.setAttribute( 'type', FLASH_MIME_TYPE );
			o.setAttribute( 'data', uri );
			o.setAttribute( 'id', id );
			o.setAttribute( 'name', id );
			for ( key in parameters ) {
				if ( key in Object.prototype ) continue;
				p = doc.createElement( 'param' );
				p.setAttribute( 'name', key );
				p.setAttribute( 'value', parameters[ key ] );
				o.appendChild( p );
			}
			element.parentNode.replaceChild( o, element );
			return o;
		}

		/**
		 * @private
		 * @static
		 * @method
		 * создаёт Flash-объект на основе outerHTML
		 * @param	{HTMLElement}	element		объект для замены флэшкой
		 * @param	{String}		id			ID флэшки
		 * @param	{String}		uri			путь к флэшке
		 * @param	{Object}		attributes	атрибуты флэшки
		 * @param	{Object}		parameters	параметры флэшки
		 * @return	{HTMLElement}	Flash-объект
		 */
		var writeSWF = function(element, id, uri, attributes, parameters) {
			var	key,
				attrs =		new Array(),
				params =	new Array();
			for ( key in attributes ) {
				if ( key in Object.prototype ) continue;
				attrs.push( key + '="' + attributes[ key ] + '"' );
			}
			params.push( '<param name="movie" value="' + uri + '" />' );
			for ( key in parameters ) {
				if ( key in Object.prototype ) continue;
				params.push( '<param name="' + key + '" value="' + parameters[ key ] + '" />' );
			}
			element.outerHTML = '<object id="' + id + '" name="' + id + '" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" ' + attrs.join( ' ' ) + '>' + params.join( '' ) + '</object>';
			return doc.getElementById( id );	
		}

		/**
		 * @private
		 * @static
		 * @method
		 * @param	{HTMLElement}
		 * @return {Boolean}
		 */
		var isFlash = function(e) {
			if (
				e &&
				e.id &&
				_flashs[ e.id ] &&
				e === _flashs[ e.id ].getElement()
			) {
				return true;
			}
			return false;
		}

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var	Version =	blooddy.utils.Version,
			Browser =	blooddy.Browser,

			msie =		Browser.getMSIE(),
			webKit =	Browser.getWebKit(),

			OBJECT =			'object',
			SHOCKWAVE_FLASH =	'Shockwave Flash',
			FLASH_MIME_TYPE =	'application/x-shockwave-flash',

			twin =	top || win,
			tdoc =	twin.document,
			doc =	document,
			nav =	navigator,

			_playerVersion,
			_flashs = new Object();

		//--------------------------------------------------------------------------
		//
		//  Static
		//
		//--------------------------------------------------------------------------

		if ( nav.plugins && typeof nav.plugins[ SHOCKWAVE_FLASH ] == 'object' ) {
			var d = nav.plugins[ SHOCKWAVE_FLASH ].description;
			if (
				d &&
				nav.mimeTypes &&
				nav.mimeTypes[ FLASH_MIME_TYPE ] &&
				nav.mimeTypes[ FLASH_MIME_TYPE ].enabledPlugin
			) {
				d = d.match( /^[\w\s]+?(\d+)\.(\d+)([^\d]+(\d+)([^\d]+(\d+))?)?/ );
				_playerVersion = new Version();
				_playerVersion[ 0 ] = parseInt( d[ 1 ] );
				_playerVersion[ 1 ] = parseInt( d[ 2 ] );
				_playerVersion[ 2 ] = parseInt( d[ 4 ] );
				_playerVersion[ 3 ] = parseInt( d[ 6 ] );
			}
		} else if ( twin.ActiveXObject ) {
			try {
				var a =	new ActiveXObject( 'ShockwaveFlash.ShockwaveFlash' );
				if ( a ) {
					var	v = a.GetVariable( '$version' );
					if ( v ) {
						v = d.match( /^\w+\s(\d+,\d+,\d+,\d+)/ );
						_playerVersion = Version.parse( v[ 1 ] );
					}
				}
			} catch( e ) {
			}
		}

		if ( !_playerVersion ) {
			_playerVersion = new Version();
		}

		if ( msie ) { // эксплорер отвратительно себя ведёт с табом
			doc.attachEvent(
				'onkeydown',
				function() {
					if ( event.keyCode == 8 || event.keyCode == 9 ) {
						return !isFlash( doc.activeElement );
					}
					return true;
				}
			);
			doc.attachEvent(
				'onmousewheel',
				function() {
					return !isFlash( doc.activeElement );
				}
			);
		} else {
			tdoc.addEventListener(
				'DOMMouseScroll',
				function(event) {
					if ( isFlash( doc.activeElement ) ) {
						event.preventDefault();
					}
				},
				true
			);
		}

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
		var Flash = function(id) {
			if ( _flashs[ id ] ) throw new Error( 'Object already created.' );
			_flashs[ id ] = this;
			Flash.superPrototype.constructor.call( this );
			this._id = id;
		}

		blooddy.extend( Flash, blooddy.events.EventDispatcher );

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @property
     	 * @type 		String
		 */
		Flash.prototype._id = null;

		/**
		 * @private
		 * @property
     	 * @type 		String
		 */
		Flash.prototype._uri = null;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @return	{String}	ID флэшки
		 */
		Flash.prototype.getID = function() {
			return this._id;
		}

		/**
		 * @return	{String}	путь, по которому расположена флэшка
		 */
		Flash.prototype.getURI = function() {
			if ( !this._uri ) {
				var	element = doc.getElementById( this._id ) || null;
				if ( element ) {
					this._uri = element.data;
					if ( !this._uri ) {
						var	params = element.getElementsByTagName( 'param' ),
							l = params.length,
							i,
							p;
						for ( i=0; i<l; i++ ) {
							p = params[ i ];
							if ( p.name.toLowerCase() == 'movie' ) {
								this._uri = p.value;
								break;
							}
						}
					}
				}
			}
			return this._uri;
		}

		/**
		 * @return	{String}	HTMLElement флэшки
		 */
		Flash.prototype.getElement = function() {
			return doc.getElementById( this._id );
		}

		/**
		 * @method
		 * @override
		 * подготавливает объект к удалению
		 */
		Flash.prototype.dispose = function() {
			if ( _flashs[ this._id ] === this ) {
				delete _flashs[ this._id ];
			}
			this._id = null
			this._uri = null;
			Flash.superPrototype.dispose.call( this );
		}

		/**
		 * @return	{String}
		 */
		Flash.prototype.toString = function() {
			return '[Flash id="' + this._id + '"]';
		}

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @static
		 * @method
		 * Вставляет флэшку в HTML
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
		Flash.embedSWF = function(id, uri, width, height, version, flashvars, parameters, attributes) {
			if ( !id || !uri ) return null;

			var	element = doc.getElementById( id );
			if ( !element ) return null;

			if ( webKit && webKit < 312 ) {
				return null;
			}
			if ( version ) {
				if ( typeof version == 'string' ) {
					version = Version.parse( version );
				} else if ( typeof version == 'number' ) {
					version = Version.parse( version.toString() );
				}
				if ( version instanceof Version ) {
					if ( version.compare( _playerVersion ) > 0 ) {
						return null;
					}
				}
			}

			var	key,
				value,
				attrs =		new Object(),
				params =	new Object();

			if ( attributes && typeof attributes == OBJECT ) {
				for ( key in attributes ) {
					value = attributes[ key ];
					if ( key in Object.prototype ) continue;
					switch ( key.toLowerCase() ) {
						case 'styleclass':	key = 'class';	break;
						case 'id':
						case 'name':
						case 'data':
						case 'classid':
						case 'type':		value = null;	break;
					}
					if ( !value ) continue;
					attrs[ key ] = value;
				}
			}
			attrs.width = width || element.clientWidth || 100;
			attrs.height = height || element.clientHeight || 100;

			if ( parameters && typeof parameters == OBJECT ) {
				for ( key in parameters ) {
					value = parameters[ key ];
					if ( key in Object.prototype ) continue;
					switch ( key.toLowerCase() ) {
						case 'flashvars':
						case 'movie':		value = null;	break;
					}
					if ( !value ) continue;
					params[ key ] = value;
				}
			}

			if ( flashvars && typeof flashvars == OBJECT ) {
				var	fv = new Array(); 
				for ( key in flashvars ) {
					value = flashvars[ key ];
					if ( key in Object.prototype ) continue;
					if ( !value ) continue;
					fv.push( key + '=' + flashvars[ key ] );
				}
				if ( fv.length > 0 ) {
					params.flashvars = fv.join( '&' );
				}
			}

			if ( msie ) {
				return writeSWF( element, id, uri, attrs, params );
			} else {
				return createSWF( element, id, uri, attrs, params );
			}

			return null;
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
		Flash.createFlash = function(id, uri, width, height, version, flashvars, parameters, attributes) {
			if ( Flash.embedSWF( id, uri, width, height, version, flashvars, parameters, attributes ) ) {
				return Flash.getFlash( id );
			}
			return null;
		}

		/**
		 * @static
		 * проверяет существование конроллера
		 * @param	{String}	id			ID флэшки
		 * @return	{Boolean}
		 */
		Flash.hasFlash = function(id) {
			return ( _flashs[ id ] ? true : false );
		}

		/**
		 * @static
		 * @method
		 * возвращает существующий конроллер, или создаёт новый
		 * @param	{String}		id		ID флэшки
		 * @return	{blooddy.Flash}			контроллер Flash-объекта
		 */
		Flash.getFlash = function(id) {
			return _flashs[ id ] || new Flash( id );
		}

		/**
		 * @static
		 * @method
		 * возращает версию плэйера
		 * @return	{blooddy.utils.Version}		версия
		 */
		Flash.getPlayerVersion = function() {
			return _playerVersion;
		}

		/**
		 * @static
		 * @method
		 * @return	{String}
		 */
		Flash.toString = function() {
			return '[class Flash]';
		}

		return Flash;

	}() );

}