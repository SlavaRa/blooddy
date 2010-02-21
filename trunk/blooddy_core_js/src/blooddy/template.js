/*!
 * blooddy/template.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

if ( !blooddy.template ) {

	/**
	 * @property
	 * @namespace	blooddy
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.template = new ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		var	$ =			blooddy,
			browser =	$.browser,

			msie =		browser.getMSIE(),
			gecko =		browser.getGecko(),

			g_win =		$.getTop(),

			_cache_id =		new Object(),
			_cache_url =	new Object(),
			_cache_text =	new Object(),
			_cache_js =		new Object(),

			_ZERO =			String.fromCharCode( 0 ),

			_rExp =			/<%([^\s]+)?\s+([\S\s]*?)\s*%>/g,
			_rExpPure =		/\s*<%\s+([\S\s]*?)\s*%>\s*/g,
			_rEmpty =		/^\s*$/,
			_rQuote =		/"/g,
			_rSpaces =		/\r?\n/g,
			_rSharp =		/#/g,
			_rDSharp =		/#(\d+)/g,
			_rESharp =		/\\#/g,
			_rDog =			/@/g,
			_rEDog =		/\\@/g,
			_rEDogSharp =	/\\([#@])/g,
			_rZero =		new RegExp( _ZERO, 'g' ),

			_local =		true,
			_logging =		$.isLogging(),

			SCRIPT =		'script';

		//--------------------------------------------------------------------------
		//
		//  Static
		//
		//--------------------------------------------------------------------------

		if ( !msie && g_win !== window && g_win.blooddy && g_win.blooddy !== $ ) {
			g_win.blooddy.require( 'blooddy.template' );
			_local = false;
		}

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @param	{String}	str
		 * @return	{String}
		 */
		var replaceText = function(str) {
			return str.replace( _rSpaces, '\\n' ).replace( _rQuote, '\\"' );
		};

		/**
		 * @private
		 * @param	{String}	str
		 * @return	{String}
		 */
		var replaceJScommon = function(str) {
			return	str	.replace( _rESharp, _ZERO )
						.replace( _rDSharp, '_$$[$$1]' )
						.replace( _rSharp, '_$$0' )
						.replace( _rZero, '#' );
		};

		/**
		 * @private
		 * @param	{String}	str
		 * @return	{String}
		 */
		var replaceJS = function(str) {
			return replaceJScommon( str.replace( _rEDog, '@' ) );
		};

		/**
		 * @private
		 * @param	{String}	str
		 * @return	{String}
		 */
		var replaceJSPure = function(str) {
			return replaceJScommon(
				str	.replace( _rEDog, _ZERO )
					.replace( _rDog, '$$_' )
					.replace( _rZero, '@' )
				);
		};

		/**
		 * @private
		 * @param	{String}	str
		 * @return	{String}
		 */
		var replaceJSText = function(str) {
			return str.replace( _rEDogSharp, '$1' );
		};

		/**
		 * @private
		 * @param	{String}	type
		 * @param	{String}	id
		 * @param	{String}	source
		 * @param	{Function}	result
		 */
		var log = function(type, id, source, result) {
			if ( gecko && console.dir ) {
				console.groupCollapsed( 'template %d="%d"', type, id );
					console.groupCollapsed( 'source' );
					console.log( source );
					console.groupEnd();
				console.log( result );
				console.log( String( result ) );
				console.groupEnd();
			} else {
				console.log( '==============' );
				console.log( source );
				console.log( result );
				console.log( '--------------' );
			}
		};

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 */
		var Template =			new Function(),
			TemplatePrototype =	Template.prototype;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @param	{String}		source
		 * @return	{Function}
		 */
		TemplatePrototype.parseText = function(source) {
			var result = _cache_text[ source ];
			if ( result === undefined ) {
				_rExpPure.lastIndex = 0;
				var a = _rExpPure.exec( source );
				if ( a ) {

					if ( a[0].length == source.length ) { // pureJS

						result = new Function( 'var $_,_$=arguments,_$0=_$[0];' + replaceJSPure( a[1] ) + ';return $_' );

					} else { // combo

						var body = '',
							l,
							i = 0,
							j,
							h = false;

						/**
						 * @param	{String}	js
						 */
						var appendJS = function(js) {
							body += ( h ? '+' : ';$_+=' ) + js;
							h = true;
						};
						/**
						 * @param	{String}	text
						 */
						var appendText = function(text) {
							appendJS( '"' + replaceText( text ) + '"' );
						};

						_rExp.lastIndex = 0;
						while ( a = _rExp.exec( source ) ) {
							j = _rExp.lastIndex;
							l = a[ 0 ].length;
							if ( i != j - l ) {
								appendText( source.substring( i, j - l ) );
							}
							switch ( a[1] || '' ) {

								// вставка яваскрипта
								// вставляется прям как есть
								// <% for ( var i = 0; i<l; i++ { %>
								// for ( var i = 0; i<l; i++ {
								case '':		body += ( h ? ';' : '' ) + replaceJS( a[2] ); h = false; break;

								// печать яваскрипта
								// <%= #3.property + # %>
								// result += ( arguments[3].property + arguments[0] );
								case '=':		appendJS( '(' + replaceJS( a[2] ) + ')' ); break;

								// вставка шаблона
								// <%tpl tpl_content %>
								// result += blooddy.template.getTemplate("tpl_content");
								case 'tpl':		appendJS( 'blooddy.template.getTemplate("' + replaceJSText( a[2] ) + '")' ); break;

								// загрузка шаблона
								// <%!tpl /tpl/wait.tpl %>
								// result += blooddy.template.loadTemplate("/tpl/wait.tpl");
								case '!tpl':	appendJS( 'blooddy.template.loadTemplate("' + replaceJSText( a[2] ) + '")' ); break;

								// вствка динамического яваскрипта
								// <%js alert( this ) %>
								// result += "<script type=\"text/javascript\">alert( this )</script>";
								case 'js':		appendText( '<script type="text/javascript">' + replaceJSText( a[2] ) + '</script>' ); break;

								// загрузка динамического яваскрипта
								// <%!js /js/blooddy.js %>
								// result += "<script type=\"text/javascript\" src=\"/js/blooddy.js\"></script>";
								case '!js':		appendText( '<script type="text/javascript" src="' + replaceJSText( a[2] ) + '"></script>' ); break;

								// неизвестный тэг
								default:		throw new Error( 'unknown tag: ' + a[0] ); break;

							}
							i = j;
						}
						if ( i < source.length ) {
							appendText( source.substr( i ) );
						}
						result = new Function( 'var $_="",_$=arguments,_$0=_$[0]' + body + ';return $_' );

					}

				} else { // pureText

					result = new Function( 'return "' + replaceText( source ) + '"' );

				}
				_cache_text[ source ] = result || null;
			}
			return result;
		};

		/**
		 * @method
		 * @param	{String}	str
		 * @param	{Object}	data
		 * @return	{String}
		 */
		TemplatePrototype.applyText = function(str, data) {
			var f = this.parseText( str );
			return ( f ? f( data ) : str );
		};

		/**
		 * @method
		 * @param	{String}		id
		 * @return	{Function}
		 */
		TemplatePrototype.getTemplate = function(id) {
			var result = _cache_id[ id ];
			if ( result === undefined ) {
				var	e = document.getElementById( id );
				if ( e ) {
					result = this.parseText( msie ? e.text : e.textContent );
				}
				if ( _logging && window.console ) {
					log(
						'id',
						id,
						( e ? ( msie ? e.text : e.textContent ) : null ),
						( result || null )
					);
				}
				_cache_id[ id ] = result || null;
			}
			return result;
		};

		/**
		 * @method
		 * @param	{String}	uri
		 * @return	{Function}
		 */
		TemplatePrototype.loadTemplate = function(uri) {
			var result = _cache_url[ uri ];
			if ( result === undefined ) {
				if ( _local ) {
					var	txt = $.getFileContent( uri );
					result = ( txt ? this.parseText( txt ) : null );
					if ( _logging && window.console ) {
						log(
							'uri',
							uri,
							( txt || null ),
							result
						);
					}
				} else {
					result = g_win.blooddy.template.loadTemplate( uri );
				}
				_cache_id[ uri ] = result;
			}
			return result;
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		TemplatePrototype.toString = function() {
			return '[Template object]';
		};

		return Template;

	}() );

}