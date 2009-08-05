////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.database {

	import by.blooddy.core.errors.getErrorMessage;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					datacontainer, data
	 */
	public class DataContainer extends Data {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function DataContainer() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _list:Array = new Array();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  numChildren
		//----------------------------------

		/**
		 * Возвращает количество детей.
		 * 
		 * @keyword					datacontainer.numchildren, numchildren
		 */
		public function get numChildren():int {
			return this._list.length;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  addChild
		//----------------------------------

		/**
		 * Добавляет новое дитё.
		 * 
		 * @param	child			Дитё на добавление.
		 * 
		 * @return					Возвращает добавленное дитё.
		 * 
		 * @event	added			
		 * 
		 * @throw	ArgumentError	Самого сибя добавляем, или добавляем дитё, которое является нашим предком.
		 * 
		 * @keyword					datacontainer.addchild, addchild
		 */
		public function addChild(child:Data):Data {
			return this.$addChildAt( child, this._list.length );
		}

		//----------------------------------
		//  addChildAt
		//----------------------------------

		/**
		 * Добавляет новое дитё в конкретное место.
		 * 
		 * @param	child			Дитё на добавление.
		 * @param	index			Индекс элемента.
		 * 
		 * @return					Возвращает добавленное дитё.
		 * 
		 * @throw	RangeError		Куда-то не туда вставляем :(
		 * @throw	ArgumentError	Самого сибя добавляем, или добавляем дитё, которое является нашим предком.
		 * 
		 * @keyword					datacontainer.addchildat, addchildat
		 */
		public function addChildAt(child:Data, index:int):Data {
			return this.$addChildAt( child, index  );
		}

		/**
		 * @private
		 */
		private function $addChildAt(child:Data, index:int):Data {
			// проверим наличие передоваемого объекта
			if ( !child ) throw new TypeError( getErrorMessage( 2007, this, '$addChildAt', 'child' ), 2007 );
			// проверим рэндж
			if ( index < 0 || index > this._list.length ) throw new RangeError( getErrorMessage( 2006 ), 2006 );
			// проверим не мыли это?
			if ( child === this ) throw new ArgumentError( getErrorMessage( 2024 ), 2024 );
			// если есть родитель, то надо его отуда удалить
			if ( child.$parent === this ) {
				this.$setChildIndex( child, index, false );
			} else {
				var parent:DataContainer = child.$parent;
				if ( parent ) {
					parent.$removeChildAt(
						parent.$getChildIndex(
							child,
							false
						),
						false
					);
				}
				// проверим нашу пренадлежность, вдруг зацикливание
				if ( child is DataContainer && ( child as DataContainer ).$contains( this ) ) {
					throw new ArgumentError( getErrorMessage( 2150 ), 2150 );
				}
				// добавляем
				this._list.splice( index, 0, child );
				// обновляем
				this.addChild_before( child ); // вызовем событие о добавлние
				child.set$parent( this );
			}
			// возвращаем
			return child;
		}

		//----------------------------------
		//  removeChild
		//----------------------------------

		/**
		 * Удаляет дитё.
		 * 
		 * @param	child			Дитё на удаление.
		 * 
		 * @return					Возвращает удалённое дитё.
		 * 
		 * @throw	ArgumentError	Пытаемся удалить дитё не лежащие в нас.
		 * 
		 * @keyword					datacontainer.removechild, removechild
		 */
		public function removeChild(child:Data):Data {
			return this.$removeChildAt( this.$getChildIndex( child ) );
		}


		//----------------------------------
		//  removeChildAt
		//----------------------------------

		/**
		 * Удаляет дитё из конкретного места.
		 * 
		 * @param	index			Место.
		 * 
		 * @return					Возвращает удалённое дитё.
		 * 
		 * @throw	RangeError		Нету такой ячейки :(
		 * 
		 * @keyword					datacontainer.removechildat, removechildat
		 */
		public function removeChildAt(index:int):Data {
			return this.$removeChildAt( index );
		}

		/**
		 * @private
		 */
		private function $removeChildAt(index:int, strict:Boolean=true):Data {
			if ( strict ) {
				// проверим рэндж
				if ( index < 0 || index > this._list.length ) throw new RangeError( getErrorMessage( 2006 ), 2006 );
			}
			// удалим
			var child:Data = this._list.splice( index, 1 )[0] as Data;
			// обновим
			this.removeChild_before( child ); // вызовем событие о добавлние
			child.set$parent( null );
			// вернём
			return child;
		}

		//----------------------------------
		//  contains
		//----------------------------------

		/**
		 * Проверяет наличие дити.
		 * 
		 * @param	child			Дитё для проверки.
		 * 
		 * @return					Возвращает true, если нашли такое.
		 * 
		 * @keyword					datacontainer.contains, contains
		 */
		public function contains(child:Data):Boolean {
			// проверим наличие передоваемого объекта
			if ( !child ) throw new TypeError( getErrorMessage( 2007, this, '$addChildAt', 'child' ), 2007 );
			return this.$contains( child );
		}

		/**
		 * @private
		 */
		private function $contains(child:Data):Boolean {
			// проверим нашу пренадлежность, вдруг зацикливание
			do {
				if ( child === this ) return true;
			} while ( child = child.$parent );
			return false;
		}

		//----------------------------------
		//  getChildAt
		//----------------------------------

		/**
		 * Ищет дитё в конкретном месте.
		 * 
		 * @param	index			Индекс.
		 * 
		 * @return					Возвращает найденное дитё.
		 * 
		 * @throw	RangeError		Нету такой ячейки :(
		 * 
		 * @keyword					datacontainer.getchildat, getchildat
		 */
		public function getChildAt(index:int):Data {
			return this.$getChildAt( index );
		}

		/**
		 * @private
		 */
		private function $getChildAt(index:int):Data {
			// проверим рэндж
			if ( index<0 || index>this._list.length ) throw new RangeError( getErrorMessage( 2006 ), 2006 );
			return this._list[ index ] as Data;
		}

		//----------------------------------
		//  getChildByName
		//----------------------------------

		/**
		 * Ищет дитё с конкретным id.
		 * 
		 * @param	id				ID.
		 * 
		 * @return					Возвращает найденное дитё или null.
		 * 
		 * @keyword					datacontainer.getchildbyid, getchildbyid
		 * 
		 * @see						by.blooddy.core.database.Data#id
		 */
		public function getChildByName(name:String):Data {
			// проверяем мы ли родитель
			for each ( var child:Data in this._list ) {
				if ( child.name === name ) return child;
			}
			return null;
		}

		//----------------------------------
		//  getChildIndex
		//----------------------------------

		/**
		 * Возвращает index конкретного дити.
		 * 
		 * @param	child			Наше дитё.
		 * 
		 * @return					Возвращает индекс дити или -1.
		 * 
		 * @throw	ArgumentError	Не наше дитё!
		 * 
		 * @keyword					datacontainer.getchildindex, getchildindex
		 */
		public function getChildIndex(child:Data):int {
			return this.$getChildIndex( child );
		}

		/**
		 * @private
		 */
		internal function $getChildIndex(child:Data, strict:Boolean=true):int {
			if ( strict ) {
				// проверяем мы ли родитель
				if ( !child || child.$parent !== this ) throw new ArgumentError( getErrorMessage( 2025, this ), 2025 );
			}
			// ищем
			return this._list.indexOf( child );
		}

		//----------------------------------
		//  setChildIndex
		//----------------------------------

		/**
		 * Присваивает новый индекс дитю.
		 * 
		 * @param	child			Наше дитё.
		 * @param	index			Новое место.
		 * 
		 * @throw	RangeError		Нету такой ячейки :(
		 * @throw	ArgumentError	Не наше дитё!
		 * 
		 * @keyword					datacontainer.setchildindex, setchildindex
		 */
		public function setChildIndex(child:Data, index:int):void {
			this.$setChildIndex( child, index );
		}

		/**
		 * @private
		 */
		private function $setChildIndex(child:Data, index:int, strict:Boolean=true):void {
			if ( strict ) {
				if ( !child ) throw new TypeError( getErrorMessage( 2007, this, '$addChildAt', 'child' ), 2007 );
				// проверим рэндж
				if ( index < 0 || index > this._list.length ) throw new RangeError( getErrorMessage( 2006 ), 2006 );
			}
			this._list.splice( this.$getChildIndex( child, strict ), 1 );
			this._list.splice( index, 0, child );
		}

		//----------------------------------
		//  swapChildren
		//----------------------------------

		/**
		 * Меняем местами 2х дитей.
		 * 
		 * @param	child1			Первое дитё.
		 * @param	child2			Второе дитё.
		 * 
		 * @throw	ArgumentError	Один из детей не наш :(
		 * 
		 * @keyword					datacontainer.swapchildren, swapchildren
		 */
		public function swapChildren(child1:Data, child2:Data):void {
			this.$swapChildrenAt( child1, child2, this.$getChildIndex( child1 ), this.$getChildIndex( child2 ) );
		}


		//----------------------------------
		//  swapChildrenAt
		//----------------------------------

		/**
		 * Меняем местами 2х дитей по идексам.
		 * 
		 * @param	index1			Первый индекс.
		 * @param	index2			Второй индекс.
		 * 
		 * @throw	RangeError		Нету такой ячейки :(
		 * 
		 * @keyword					datacontainer.swapchildrenat, swapchildrenat
		 */
		public function swapChildrenAt(index1:int, index2:int):void {
			this.$swapChildrenAt( this.$getChildAt( index1 ), this.$getChildAt( index2 ), index1, index2 );
		}

		/**
		 * @private
		 */
		private function $swapChildrenAt(child1:Data, child2:Data, index1:int, index2:int):void {
			// надо сперва поставить того кто выше
			if ( index1 > index2 ) {
				this.$setChildIndex( child1, index2, false );
				this.$setChildIndex( child2, index1, false );
			} else {
				this.$setChildIndex( child2, index1, false );
				this.$setChildIndex( child1, index2, false );
			}
		}

		//----------------------------------
		//  sort
		//----------------------------------

		/**
		 * Сортировка детей.
		 * 
		 * @see						Array#sort()
		 */
		public function sort(...args):void {
			this._list.sort.apply(this._list, args);
		}

		//----------------------------------
		//  sortOn
		//----------------------------------

		/**
		 * Сортировка детей.
		 * 
		 * @see						Array#sortOn()
		 */
		public function sortOn(fieldName:Object, options:Object=null):void {
			this._list.sortOn( fieldName, options );
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function addChild_before(child:Data):void {
		}

		protected function removeChild_before(child:Data):void {
		}

	}

}