////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 group company TimeZero.
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.platform.managers {

	import flash.display.DisplayObject;

	/**
	 * Сборщик всякого дерьма из ресурс манагера.
	 * Что бы не создавать дополнительные экземпляры классов, если те часто удаляются и добавляются.
	 *  
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @see						platform.managers.ResourceManager
	 * @see						platform.managers.ResourceBundle
	 * 
	 * @keyword					resourcebundletrash, trash, resourcebundle, resource, bundle, resourcemanager, manager
	 */
	public class ResourceBundleTrash {

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
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function ResourceBundleTrash() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @param	bundleName		
		 * @param	resourceName	
		 * @param	resource		
		 */
		public function takeIn(bundleName:String, resourceName:String, resource:*):void {
			if (resource == null) return;
			var bundle:Object = _HASH[bundleName]; 
			if (!bundle) _HASH[bundleName] = bundle = new Object();
			var resources:Array = bundle[resourceName] as Array;
			if (!resources) bundle[resourceName] = resources = new Array();
			if (resources.indexOf(resource)>=0) return;
			resources.push(resource);
		}

		/**
		 * @param	bundleName		
		 * @param	resourceName	
		 * 
		 * @return					
		 */
		public function has(bundleName:String, resourceName:String):Boolean {
			if (!_HASH[bundleName]) return false;
			if (!_HASH[bundleName][resourceName]) return false;
			return true;
		}

		/**
		 * @param	bundleName		
		 * @param	resourceName	
		 * 
		 * @return					
		 */
		public function takeOut(bundleName:String, resourceName:String):* {
			var bundle:Object = _HASH[bundleName] as Object;
			if (!bundle) return null;
			var resources:Array = bundle[resourceName] as Array;
			if (!resources) return null;
			var resource:* = resources.pop();
			if (!resources.length) delete bundle[resourceName];
			return resource;
		}

		/**
		 */
		public function clear():void {
			for (var bundleName:String in _HASH) {
				delete _HASH[bundleName];
			}
		} 
/*
		public function toString():String {
			var count:uint = 0;
			var elements:Array = new Array();
			
			for (var name:String in _HASH) {
				var b:Object = _HASH[name];
				
				for (var n:String in b) {
					var a:Array = b[n];
					count += a.length;
					elements.push(a.toString());
				}
			} 
			
			return 'trash has '+count+' elements: '+elements.join('\n')+'\n-------'; 
		}*/
	}

}