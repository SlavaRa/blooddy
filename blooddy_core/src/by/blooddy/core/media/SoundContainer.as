package by.blooddy.core.media {

	import by.blooddy.core.events.net.LoaderEvent;
	import by.blooddy.core.managers.IResourceManagerOwner;
	import by.blooddy.core.managers.ResourceManager;
	import by.blooddy.core.net.ILoadable;
	
	import flash.events.EventDispatcher;
	import flash.media.Sound;

	public class SoundContainer extends EventDispatcher implements IResourceManagerOwner {

		private static const _TRASH:Object = new Object();

		public function SoundContainer() {
			super();
		}

		public function get resourceManager():ResourceManager {
			return ResourceManager.manager;
		}

		public final function loadResourceBundle(bundleName:String, priority:int=0.0):ILoadable {
			var loader:ILoadable = ResourceManager.manager.loadResourceBundle( bundleName, priority );
			// диспатчим событие о том что началась загрузка
			if ( !loader.loaded ) super.dispatchEvent( new LoaderEvent(LoaderEvent.LOADER_INIT, true, true, loader) );
			return loader;
		}

		public final function hasResource(bundleName:String, resourceName:String):Boolean {
			if ( bundleName + "_" + resourceName in _TRASH ) return true;
			return ResourceManager.manager.hasResource( bundleName, resourceName );
		}

		public final function getResource(bundleName:String, resourceName:String):Sound {
			var key:String = bundleName + "_" + resourceName;
			if ( key in _TRASH ) {
				return _TRASH[ key ] as Sound;
			} else {
				if ( ResourceManager.manager.hasResource( bundleName, resourceName ) ) {
					var resource:Object = ResourceManager.manager.getResource( bundleName, resourceName ) as Object;
					if (resource is Sound) return resource as Sound;
					var resourceClass:Class = resource as Class;

					if ( resourceClass && Sound.prototype.isPrototypeOf(resourceClass.prototype) ) {
						_TRASH[ key ] = new resourceClass() as Sound;
						return _TRASH[ key ] as Sound;
					}
				}
			}
			return null;
		}

	}

}