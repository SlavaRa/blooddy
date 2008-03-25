////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 BlooDHounD.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.database {

	import by.blooddy.platform.errors.ErrorsManager;

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude(name="$base", kind="property")]

	[Exclude(name="$getChildIndex", kind="method")]

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
		//  Overriden properties: Data
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  base
		//----------------------------------

		/**
		 * @private
		 */
		internal override function set $base(value:DataBase):void {
			if (super.$base == value) return;
			super.$base = value;
			for each (var child:Data in this._list) {
				child.$base = super.$base;
			}
		}

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
			return this.$addChild(child);
		}

		/**
		 * @private
		 */
		private function $addChild(child:Data, update:Boolean=true):Data {
			return this.$addChildAt(child, this._list.length, update);
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
			return this.$addChildAt(child, index);
		}

		/**
		 * @private
		 */
		private function $addChildAt(child:Data, index:int, update:Boolean=true):Data {
			// проверим наличие передоваемого объекта
			if (!child) throw new TypeError( ErrorsManager.getErrorMessage(2007) );
			// проверим рэндж
			if (index<0 || index>this._list.length) throw new RangeError( ErrorsManager.getErrorMessage(2006) );
			// проверим не мыли это?
			if (child === this) throw new ArgumentError( ErrorsManager.getErrorMessage(2024) );
			// если есть родитель, то надо его отуда удалить
			if (child.$parent) child.$parent.$removeChild(child, false);
			// проверим нашу пренадлежность, вдруг зацикливание
			var parent:DataContainer = this.$parent;
			while (parent) {
				if (parent == child) throw new ArgumentError( ErrorsManager.getErrorMessage(2150) );
				parent = parent.$parent;
			}
			// добавляем
			this._list.splice(index, 0, child);
			// обновляем, если надо
			if (update) {
				if (this.$base) child.$base = this.$base; // TODO: Разобраться, что за хуйня здесь происходит.
				child.$parent = this;
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
			return this.$removeChild(child);
		}

		/**
		 * @private
		 */
		private function $removeChild(child:Data, update:Boolean=true):Data {
			return this.$removeChildAt( this.$getChildIndex(child), update );
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
			return this.$removeChildAt(index);
		}

		/**
		 * @private
		 */
		private function $removeChildAt(index:int, update:Boolean=true):Data {
			// проверим рэндж
			if (index<0 || index>this._list.length) throw new RangeError( ErrorsManager.getErrorMessage(2006) );
			// удалим
			var child:Data = this._list.splice(index, 1)[0] as Data;
			// обновим, если надо
			if (update) {
				child.$base = null;
				child.$parent = null;
			}
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
			return this.$contains(child);
		}

		/**
		 * @private
		 */
		private function $contains(child:Data):Boolean {
			return (child.$parent === this);
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
			return this.$getChildAt(index);
		}

		/**
		 * @private
		 */
		private function $getChildAt(index:int):Data {
			// проверим рэндж
			if (index<0 || index>this._list.length) throw new RangeError( ErrorsManager.getErrorMessage(2006) );
			return this._list[index] as Data;
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
		 * @see						by.blooddy.platform.database.Data#id
		 */
		public function getChildByName(name:String):Data {
			return this.$getChildByName(name);
		}

		/**
		 * @private
		 */
		private function $getChildByName(name:String):Data {
			// проверяем мы ли родитель
			for each (var child:Data in this._list) {
				if (child.name === name) return child;
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
			return this.$getChildIndex(child);
		}

		/**
		 * @private
		 */
		internal function $getChildIndex(child:Data):int {
			// проверяем мы ли родитель
			if (!this.$contains(child)) throw new ArgumentError( ErrorsManager.getErrorMessage(2025) );
			// ищем
			var l:uint = this._list.length;
			for (var i:int=0; i<l; i++) {
				if (this._list[i] === child) return i;
			}
			return -1;
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
			this.$setChildIndex(child, index);
		}

		/**
		 * @private
		 */
		private function $setChildIndex(child:Data, index:int):void {
			// проверяем мы ли родитель
			if (!this.$contains(child)) throw new ArgumentError( ErrorsManager.getErrorMessage(2025) );
			this.$addChildAt(child, index, false);
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
			this.$swapChildren(child1, child2);
		}

		/**
		 * @private
		 */
		private function $swapChildren(child1:Data, child2:Data):void {
			this.$swapChildrenAt( this.$getChildIndex(child1), this.$getChildIndex(child2) );
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
			this.$swapChildrenAt(index1, index2);
		}

		/**
		 * @private
		 */
		private function $swapChildrenAt(index1:int, index2:int):void {
			var child1:Data = this.$getChildAt(index1);
			var child2:Data = this.$getChildAt(index2);
			// надо сперва поставить нижнего
			if (index1<index2) {
				this.$addChildAt(child2, index1, false);
				this.$addChildAt(child1, index2, false);
			} else {
				this.$addChildAt(child1, index2, false);
				this.$addChildAt(child2, index1, false);
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
		//  sorOn
		//----------------------------------

		/**
		 * Сортировка детей.
		 * 
		 * @see						Array#sortOn()
		 */
		public function sorOn(fieldName:Object, options:Object=null):void {
			this._list.sorOn(fieldName, options);
		}

	}

}