package by.blooddy.core.utils {

	import flash.utils.Dictionary;

	public class WeakRef {

		public function WeakRef(obj:Object) {
			super();
			//if ( !obj || obj is Number || obj is String || obj is Boolean ) throw new ArgumentError();
			this._ref[ obj ] = true;
		}

		private const _ref:Dictionary = new Dictionary ( true );

		public function get():Object {
			for ( var obj:* in this._ref ) {
				return obj;
			}
			return null;
		}

		public function valueOf():Object {
			return this.get();
		}

		public function toString():String {
			return this.get().toString();
		}

	}

}