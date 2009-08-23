/*!
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( 'blooddy not initialized.' );

blooddy.require( 'blooddy.utils' );
blooddy.require( 'blooddy.events.EventDispatcher' );

if ( !blooddy.utils.history ) {

	/**
	 * @property
	 * @final
	 * экзэмпляр класса History
	 * @namespace	blooddy.utils
	 * @extends		blooddy.events.EventDispatcher
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.utils.history = new ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var	Browser =	blooddy.Browser,

			gecko =		Browser.getGecko(),
			msie =		Browser.getMSIE(),
			opera =		Browser.getOpera(),

			_inited = false,
			_available = ( 
				( gecko >= 1 ) || 
				( msie >= 6 ) ||
				( opera >= 9.5 ) ||
				( Browser.getWebKit() >= 525 )
			),

			win =		top || window,
			doc =		win.document,
			loc =		win.location,
			_history =	win.history,
			
			_hash = '',
			_onChange,
			_setHash;

		//--------------------------------------------------------------------------
		//
		//  Static
		//
		//--------------------------------------------------------------------------

		if ( _available ) {

			var getHash;

			var saveHash = function(hash) {
				_hash = hash;
				_onChange();
			}

			if ( msie ) { // IE

				var	local = ( loc.protocol == 'file:' ),
					ptrn_output;

				if ( local ) {

					ptrn_output = /\?/;
					var ptrn_input = /%(25)?3F/;

					getHash = function() {
						return loc.hash.substr( 1 ).replace( ptrn_input, '?' );
					}

				}
				// у всех версий проблемы с заголовками при переходе по якорям.
				// необходимо подправлять
				var	title = doc.title;

				// метод исправляет дописанный к заголовку хэш
				var updateTitle = function() {
					var	t = doc.title;
					if ( t != title ) {
						if ( (
								t.length > title.length	&&
								t.indexOf( title ) == 0	&&
								t.charAt( title.length ) == '#'
							) || (
								t.charAt( 0 ) == '#'
							)
						) {
							doc.title = title;
						} else {
							title = doc.title;
							if ( iframe ) iframe.contentWindow.document.title = title;
	 					}
					}
				}

				if ( msie >= 8 ) { /** IE8+ */

					if ( local ) {

						// определяем главный метод
						_setHash = function(hash) {
							loc.hash = hash.replace( ptrn_output, '%3F' );
						}

					}

					// в IE8 появилсь крутое событие
					win.attachEvent(
						'onhashchange',
						function() {
							saveHash( getHash() );
						}
					);

					// каждые 50 ms проверяем заголовок
					setInterval(
						updateTitle,
						50
					);

					// при инитиализации событие onhashchange не распостраняется
					// а так же может попотиться title
					setTimeout(
						function() {
							var	hash = getHash();
							if ( hash ) {
								updateTitle();
								saveHash( hash );
							}/* else {
								loc.hash = '';
							}*/
						},
						1
					);

				} else { /** IE7- */

					// для остальных версий IE необходим хак с IFrame,
					// по которому и будет осуществляться переход
					var	id = '__history_manager_frame_' + Math.round( ( new Date() ).getTime() * Math.random() ),
						frame;

					// создём фрэйм
					// получим его позже, так как сразу он не доступен
					doc.write( '<iframe id="' + id + '" src="javascript:false;" width="0" height="0"></iframe>' );

					// определяем гланый метод
					_setHash = function(hash) {
						var fwin = iframe.contentWindow;
						if ( fwin.hash == hash ) return;
						var fdoc = fwin.document;
						fdoc.open();
						fdoc.write( '<html><head><title>' + title + '</title><script type="text/javascript">var hash = "' + hash + '";</script></head></html>' );
						fdoc.close();
					}

					// этот метод записывает во фрэйм текущий хэш
					var updateHash = function() {
						_setHash( getHash() );
					}

					// каждые 50 ms проверяем хэш на изменения
					setInterval(
						function() {
							var	hash = getHash();
							if ( _hash != hash ) {
								setTimeout( updateHash, 1 );
								saveHash( hash );
								
							}
							updateTitle();
						},
						50
					);

					// при инитиализации необходимо обновить фрэйм
					// а так же могжет попотиться title
					setTimeout(
						function() {
							// получили фрэйм
							iframe = doc.getElementById( id );
							// когда фрэйм обновляется, нам надо прочиатать из него адресс
							iframe.attachEvent(
								'onload',
								( local ?
									function() {
										loc.hash = iframe.contentWindow.hash.replace( ptrn_output, '%3F' ) || '';
									} :
									function() {
										loc.hash = iframe.contentWindow.hash || '';
									}
								)
							);
							// обновляем всякое говно
							updateHash();
							updateTitle();
						},
						1
					);
	
				}

			} else {

				if ( opera ) {
					_history.navigationMode = 'compatible';
				}
				
				if ( gecko ) {

					// bug fix: https://bugzilla.mozilla.org/show_bug.cgi?id=378962
					getHash = function() {
						var	href =	loc.href,
							i =		href.indexOf( '#' );
						return ( i >= 0 ? href.substr( i + 1 ) : '' );
					}

				}

				// каждые 50 ms проверяем хэш на изменения
				setInterval(
					function() {
						var	hash = getHash();
						if ( _hash != hash ) {
							saveHash( hash );
						}
					},
					50
				);

				/*// надо поставить решотку
				setTimeout(
					function() {
						var	hash = getHash();
						if ( !hash ) {
							var	href =	loc.href,
								i =		href.indexOf( '#' );
							if ( i < 0 ) {
								loc.replace( href + '#' );
							}
						}
					},
					1
				);*/

			}

			if ( !getHash ) {

				getHash = function() {
					return loc.hash.substr( 1 );
				}

			}

			if ( !_setHash ) {

				// определяем главный метод
				_setHash = function(hash) {
					loc.hash = hash;
				}

			}

		} else {

			// создаём пустой метод для совместимости
			_setHash = function() {
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
		 * @throws	{Error}		History - singltone
		 */
		var History = function() {
			if ( _inited ) throw new Error( 'History - singltone' );
			_inited = true;
			History.superPrototype.constructor.call( this );
			if ( _available ) {
				var	app = this;
				_onChange = function() {
					app.dispatchEvent( new blooddy.events.Event( 'change', true ) );
				}
			}
		}

		blooddy.extend( History, blooddy.events.EventDispatcher );

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @return	{Boolean}			доступна ли работа с историей
		 */
		History.prototype.isAvailable = function() {
			return _available;
		}

		/**
		 * @method
		 * возвращается по истории назад
		 */
		History.prototype.back = function() {
			_history.back();
		};

		/**
		 * @method
		 * переходит по истории вперёд
		 */
		History.prototype.forward = function() {
			_history.forward();
		};

		/**
		 * @method
		 * переходит на определённой количество состояний истории.
		 * @param	{Number}	delta	числовой здвиг относительнотекущей истории
		 */
		History.prototype.go = function(delta) {
			_history.go( delta );
		};

		/**
		 * @method
		 * переходит вверх по пути
		 * @example /game/room/play -> up -> /game/room
		 */
		History.prototype.up = function() {
			var m = _hash.match( /^(.+?)[\/\\]+[^\/\\]+[\/\\]*([\?\#]|$)/ );
			_setHash( m ? m[1] : '' );
		};

		/**
		 * @method
		 * @return	{String}			адресс
		 */
		History.prototype.getHREF = function() {
			return _hash;
		};

		/**
		 * @method
		 * @param	{String}	value	новый адресс
		 */
		History.prototype.setHREF = function(value) {
			_setHash( value );
		};

		/**
		 * @method
		 * @return	{String}			путь
		 */
		History.prototype.getPath = function() {
			return _hash.split( /[\?\#]/, 2 )[ 0 ];
		};

		/**
		 * @method
		 * @return	{String}			перменные
		 */
		History.prototype.getSearch = function() {
			var i = _hash.indexOf( '?' );
			if ( i > 0 ) {
				var j = _hash.indexOf( '#', i );
				if ( j > 0 ) {
					return _hash.substring( i+1, j );
				}
				return _hash.substr( i+1 );
			}
			return '';
		};
	
		/**
		 * @method
		 * @return	{String}			хэш
		 */
		History.prototype.getHash = function() {
			var index = _hash.indexOf( '#' );
			return ( index < 0 ? '' : _hash.substr( index + 1 ) );
		};

		/**
		 * @method
		 * @return	{String}			заголовок страницы
		 */
		History.prototype.getTitle = function() {
			return doc.title;
		};
	
		/**
		 * @method
		 * @param	{String}	title	новый заголовок страницы
		 */
		History.prototype.setTitle = function(value) {
			if ( !value ) value = '';
			doc.title = title;
		};

		/**
		 * @method
		 * @return	{String}
		 */
		History.prototype.toString = function() {
			return '[History object]';
		}

		return History;

	}() );

}