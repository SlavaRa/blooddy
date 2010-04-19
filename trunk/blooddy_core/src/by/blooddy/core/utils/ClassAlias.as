////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.net.getClassByAlias;
	import flash.net.registerClassAlias;
	import flash.utils.getDefinitionByName;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					16.04.2010 18:04:54
	 */
	public final class ClassAlias {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _HASH:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function registerQNameAlias(name:*, c:Class):void {
			if ( name is QName ) {
				name = name.toString();
			} else if ( !( name is String ) ) {
				throw new ArgumentError();
			}
			registerClassAlias( name, c );
			_HASH[ name ] = new WeakRef( c );
		}

		public static function registerNamespaceAlias(ns:*, c:Class):void {
			if ( ns is Namespace ) {
				ns = ( ns as Namespace ).uri;
			} else if ( ns is QName ) {
				ns = ( ns as QName ).uri;
			} else if ( !( ns is String ) ) {
				throw new ArgumentError();
			}
			ns = ( ns ? ns + '::' : '' ) + ClassUtils.getClassName( c );
			registerClassAlias( ns, c );
			_HASH[ ns ] = new WeakRef( c );
		}

		public static function getClass(name:*):Class {
			if ( name is QName ) {
				name = name.toString();
			} else if ( !( name is String ) ) {
				throw new ArgumentError();
			}
			var result:Class;
			if ( name ) {
				if ( name in _HASH ) {
					result = ( _HASH[ name ] as WeakRef ).get();
					if ( !result ) {
						delete _HASH[ name ];
					}
				}
				if ( !result ) {
					try {
						result = getClassByAlias( name );
					} catch ( e:Error ) {
						try {
							result = getDefinitionByName( name ) as Class;
						} catch ( e:Error ) {
						}
					}
					if ( result ) {
						_HASH[ name ] = new WeakRef( result );
					}
				}
			}
			return result;
		}

	}
	
}

import by.blooddy.core.utils.ClassAlias;

import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;

ClassAlias.registerNamespaceAlias( AS3, Bitmap );
ClassAlias.registerNamespaceAlias( AS3, Shape );
ClassAlias.registerNamespaceAlias( AS3, Sprite );
ClassAlias.registerNamespaceAlias( AS3, TextField );