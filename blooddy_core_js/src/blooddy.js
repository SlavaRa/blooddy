/*!
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) {

	/**
	 * @package
	 * @final
	 * @author	BlooDHounD	<http://www.blooddy.by>
	 */
	var blooddy = new ( function() {

		//--------------------------------------------------------------------------
		//
		//  Classes
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @class
		 * @final
		 * Класс содержащий характеристики браузера 
		 * @memberOf	blooddy
		 */
		var Browser = ( function() {

			//--------------------------------------------------------------------------
			//
			//  Class variables
			//
			//--------------------------------------------------------------------------
	
			/**
			 * @private
			 */
			var	_u = navigator.userAgent,
	
				_msie =		0,
				_opera =	0,
				_gecko =	0,
				_webkit =	0,
				
				m;
	
			m = _u.match( /AppleWebKit\/([\.\d]*)/ );
			if ( m ) {
				if ( m[1] )	_webkit = parseFloat( m[1] );
				else		_webkit = 1;
			} else if ( ( /KHTML/ ).test( _u ) ) {
				_webkit = 1;
			} else {
				m = _u.match( /Opera[\s\/]([^\s]*)/ );
				if ( m ) {
					if ( m[1] )	_opera = parseFloat( m[1] );
					else		_opera = 1;
				} else {
					m = _u.match( /MSIE\s([^;]*)/ );
					if ( m ) {
						if ( m[1] )	_msie = parseFloat( m[1] );
						else		_msie = 1;
					} else {
						m = _u.match( /Gecko\/([^\s]*)/ );
						if ( m ) {
							m = _u.match( /rv:([\.\d]*)/ );
							if ( m && m[1] )	_gecko = parseFloat( m[1] );
							else				_gecko = 1;
						}
					}
				}
			}
	
			//--------------------------------------------------------------------------
			//
			//  Constructor
			//
			//--------------------------------------------------------------------------
	
			/**
			 * @private
			 * @constructor
			 */
			var Browser = new Function();
	
			//--------------------------------------------------------------------------
			//
			//  Class methods
			//
			//--------------------------------------------------------------------------
	
			/**
			 * @static
			 * @method
			 * получает версию Gecko ( 0 - если не используется )
			 * @return	{Number}	версия
			 */
			Browser.getGecko = function() {
				return _gecko;
			}
	
			/**
			 * @static
			 * @method
			 * получает версию AppleWebKit ( 0 - если не используется )
			 * @return	{Number}	версия
			 */
			Browser.getWebKit = function() {
				return _webkit;
			}
	
			/**
			 * @static
			 * @method
			 * получает версию Internet Explorer ( 0 - если не используется )
			 * @return	{Number}	версия
			 */
			Browser.getMSIE = function() {
				return _msie;
			}
		
			/**
			 * @static
			 * @method
			 * получает версию Opera ( 0 - если не используется )
			 * @return	{Number}	версия
			 */
			Browser.getOpera = function() {
				return _opera;
			}
		
			/**
			 * @static
			 * @method
			 * @return	{String}
			 */
			Browser.toString = Browser.prototype.toString = function() {
				return '[class Browser ' +
					' gecko=' +		_gecko +
					' webkit=' +	_webkit +
					' opera=' +		_opera +
					' msie=' +		_msie +
					']';
			}
	
			return Browser;
	
		}() );
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var	win = window,

			_FILENAME = 'blooddy.js',
			_NOTATION = /([^^\/])([A-Z])/g,

			_incluedes =	new Object(),
			_files =		new Object(),
			_requires =		new Object(),

			_request,
			_root;

		//--------------------------------------------------------------------------
		//
		//  Static
		//
		//--------------------------------------------------------------------------

		// инитиализируем request
		if ( Browser.getMSIE() && win.ActiveXObject ) {
			try {
				_request = new ActiveXObject( 'Microsoft.XMLHTTP' )
			} catch ( e ) {
			}
		}
		if ( !_request && win.XMLHttpRequest ) {
			try {
				_request = new XMLHttpRequest();
				if ( _request.overrideMimeType ) {
					_request.overrideMimeType( 'text/javascript' ); // fix gecko error
				}
			} catch ( e ) {
			}
		}

		_incluedes[ _FILENAME ] = true;

		if ( Browser.getGecko() ) {
			try {
				_root = ( new Error() ).stack.split( '\n', 2 )[1].match( new RegExp( '^[\\w\\.]*\\(\\)@(.+?)' + _FILENAME + ':\\d+$' ) )[1];
			} catch ( e ) {
			}
		}
		if ( !_root ) {
			var	scripts = win.document.getElementsByTagName( 'script' ),
				i,
				l = scripts.length,
				s,
				index;
			for ( i=l-1; i>=0; i-- ) { // скорее всего мы последний добавленный скрипт
				s = scripts[ i ].src;
				if ( s ) {
					index = s.lastIndexOf( _FILENAME );
					if ( index == s.length - _FILENAME.length ) { // мы себя нашли
						_root = s.substring( 0, index );
						break;
					}
				}
			}
		}
		if ( !_root ) _root = 'js/';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 * @private
		 * @constructor
		 */
		var Blooddy = new Function();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @class
		 * @final
		 * Класс содержащий характеристики браузера 
		 */
		Blooddy.prototype.Browser = Browser;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * наследует один класс от другого
		 * @param	{Function}	Child	класс-ребёнок
		 * @param	{Function}	Parent	класс-родитель
		 */
		Blooddy.prototype.extend = function(Child, Parent) {
			var Proxy = new Function();
			Proxy.prototype = Parent.prototype;
			Child.prototype = new Proxy();
			Child.prototype.constructor = Child;
			Child.superPrototype = Parent.prototype;
		}

		/**
		 * @method
		 * исполняет код вглобальной области видимости
		 * @param	{String}	source	код
		 * @return	{Object}
		 */
		Blooddy.prototype.eval = function(source) {
			if ( Browser.getMSIE() ) {
				return win.execScript( source );
			} else {
				return win.eval( source ); // FIXME: выдаёт ошибки в gecko
			}
			/*
			// альтернативный вариант не внушающий доверия
			var	script = document.createElement( 'script' );
			script.type = 'text/javascript';
			script.innerHTML = source;
			document.getElementsByTagName( 'head' )[ 0 ].appendChild( script );
			*/
		}

		/**
		 * @method
		 * синхронно получает содержание файла
		 * @param	{String}	uri		путь к файлу
		 * @return	{String}			содержание файла, или null 
		 */
		Blooddy.prototype.getFileContent = function(uri) {
			var	result = _files[ uri ];
			if ( result === undefined ) {
				if ( !_request ) return null;
				try {
					_request.open( 'GET', uri, false );
					_request.send( null );
					_files[ uri ] = result = _request.responseText || null;
				} catch ( e ) {
					_files[ uri ] = result = null;
				}
			}
			return result;
		}

		/**
		 * @method
		 * синхронно импортирует файл
		 * @param	{String}	uri		путь к файлу
		 * @throws	{Error}				uri not found
		 */
		Blooddy.prototype.include = function(uri) {
			if ( _incluedes[ uri ] ) return; // рание был добавлен
			_incluedes[ uri ] = true;
			var	content = this.getFileContent( uri );
			if ( typeof content != 'string' ) {
				throw new Error( uri + ' not fount.' );
			}
			this.eval( content );
		}

		/**
		 * @method
		 * проверяет наличие объекта.
		 * при его отсутвии пытается его загрузить.
		 * @param	{String}	name	имя класса
		 * @throws	{Error}				name not initialized
		 */
		Blooddy.prototype.require = function(name) {
			var asset = _requires[ name ];
			if ( asset === undefined ) {
				var	arr =	name.split( '.' ),
					o =		win,
					n,
					s,
					i,
					l = arr.length;
				asset = true;
				for ( i=0; i<l; i++ ) {
					n = arr[ i ];
					if ( !o[ n ] ) {
						s = arr.slice( 0, i + 1 ).join( '/' ).replace( _NOTATION, '$1_$2' ).toLowerCase() + '.js';
						this.include( _root + s );
						if ( !o[ n ] ) {
							asset = false;
							break;
						}
					}
					o = o[ n ];
				}
				_requires[ name ] = asset;
			}
			if ( !asset ) throw new Error( name + ' non initialized.' );
		}

		/**
		 * @method
		 * @param	{String}	name
		 * @return	{Object}
		 */
		Blooddy.prototype.createAbstractInstance = function(name) {

			return new ( function() {

				/**
				 * @private
				 * @constructor
				 */
				var InstanceClass = new Function();

				/**
				 * @private
				 * @static
				 * @method
				 * @return	{String}
				 */
				InstanceClass.prototype.toString = function() {
					return '[package ' + name + ']';
				}

				return InstanceClass;

			}() );
		}

		/**
		 * @return	{String}
		 */
		Blooddy.prototype.toString = function() {
			return '[package blooddy]';
		}

		return Blooddy;
	
	}() );

}