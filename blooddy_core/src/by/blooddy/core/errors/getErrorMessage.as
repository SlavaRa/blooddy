////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.errors {

	import flash.utils.getQualifiedClassName;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @param	errorID			код ршибки
	 * @param	scope			область вызова
	 * @param	property		имя свойства
	 * @param	replaces		замены
	 * 
	 * @return					Возращает текстовый вид ошибки с заменами.
	 *
 	 * @keyword					errorsmanager, error, manager
	 */
	public function getErrorMessage(errorID:int, scope:Object=null, property:String='', ...replaces):String {
		if ( errorID in messages ) {
			var message:String = messages[ errorID ] || '';
			if ( message ) {
				// определим всякие родные свойства
				if ( scope ) message = message.replace( PATTERNT_CLASS, getQualifiedClassName( scope ) );
				if ( property ) message = message.replace( PATTERNT_PROPERTY, property );
				// пройдёмся про реплэйсам
				for ( var i:uint = 0; i<replaces.length; i++ ) {
					message = message.replace( new RegExp( '%s' + i, 'g' ), replaces[i].toString() );
				}
				// попробуем заменить на массив 
				message = message.replace( /%s/g, replaces.join(", ") );
			}
		}
		return '[ ' + getQualifiedClassName( scope ) + '/' + property + '() ] ' + message;
	}

}

//--------------------------------------------------------------------------
//
//  Private class constants
//
//--------------------------------------------------------------------------

/**
 * @private
 */
internal const PATTERNT_CLASS:RegExp = /%class/g;

/**
 * @private
 */
internal const PATTERNT_PROPERTY:RegExp = /%property/g;

/**
 * @private
 * Сюда записываем коды ошибок.
 */
internal const messages:Object = {

	1034: 'Type Coercion failed: cannot convert %s0 to %s1.',
	1056: 'Cannot create property %property on %class.',
	1069: 'Property %property not found on %class and there is no default value.',

	2002: 'Operation attempted on invalid socket.',
	2003: 'Invalid socket port number specified.',
	2006: 'The supplied index is out of bounds.',
	2007: 'Parameter child must be non-null.',
	2012: '%class class cannot be instantiated.',
	2024: 'An object cannot be added as a child of itself.',
	2025: 'The supplied %class must be a child of the caller.',
	2029: 'This %class object does not have a stream opened.',
	2071: 'The %class class does not implement this property or method.',
	2124: 'Loaded file is an unknown type.',
	2150: 'An object cannot be added as a child to one of it\'s children (or children\'s children, etc.).',

	//========================
	// описанные мною ошибки
	//========================

	5100: 'Некоторые ресурсы не были возвращены в мэннеджер ресурсов.',
	5101: 'Ресурс не был создан.',

/*
	5000: '',
	5001: 'Выбран не правильный namespace для комманды: %s0.',
	5002: 'Выбрано не правильное направление для комманды: %s0',
	5003: 'Не хватает следущих аргументов: %s.',
	5004: 'Циклический массив не может содержать тип %s0.',
	5005: 'Не известное имя узла %s0.',
	5050: 'Начали читать %s1 не дочитав %s0.',
	5051: 'Не совпадают шаблоны. Шаблон комманды: %s0. Необходимый шаблон: %s1.',
	5052: 'Шаблон отсутвует.',
	5053: 'Направление шаблона и комманды разные. Направление комманды: %s0. Шаблон: %s1.',
	5054: 'Попытка использовать неизвестный тип %s0.',
	5055: 'Не совпадает длинна объекта с заданной в шаблоне. Объект: %s0. Шаблон: %s1.',
	5056: 'Не допустимый тип длинны для типа %s0.',
	5057: 'Обязательный атрибут %s1 комманды %s0 отсутвует.',
	5058: 'Начали читать элемент массива %s1 не дочитав %s0.',
	5059: 'Попытка сериализовать тип %s0 как %s1.',
	5060: 'Нарушение битов синхронизации комманды: sync=%s0, id=%s1, length=%s2.',
	5061: 'Нарушение длинны комманды: need=%s0, real=%s1.',
*/
	9999: ''

}