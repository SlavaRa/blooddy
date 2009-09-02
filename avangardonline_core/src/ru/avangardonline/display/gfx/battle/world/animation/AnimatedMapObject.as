////////////////////////////////////////////////////////////////////////////////
//
//  © 2004—2008 TimeZero LLC.
//
////////////////////////////////////////////////////////////////////////////////

package com.timezero.game.display.gfx.animation {

	import com.timezero.game.database.animation.AnimatedMapObjectData;
	import com.timezero.game.database.animation.AnimationProperties;
	import com.timezero.game.database.character.CharacterData;
	import com.timezero.game.database.effects.GraphicsWorldEffectData;
	import com.timezero.game.database.graphics.GraphicsElementData;
	import com.timezero.game.database.ufo.UFOData;
	import com.timezero.game.database.world.WorldInteractiveObjectData;
	import com.timezero.game.display.gfx.character.Character;
	import com.timezero.game.display.gfx.effects.GraphicsWorldEffect;
	import com.timezero.game.display.gfx.gfx_internal;
	import com.timezero.game.display.gfx.ufo.UFO;
	import com.timezero.game.display.gfx.world.DynamicMapObject;
	import com.timezero.game.display.gfx.world.WorldInteractiveObject;
	import com.timezero.game.events.database.animation.AnimationDataEvent;
	import com.timezero.game.events.database.graphics.GraphicsLinkDataEvent;
	import com.timezero.game.events.database.world.MapDataEvent;
	import com.timezero.game.events.gfx.AnimatedMapObjectEvent;
	import com.timezero.game.net.GameLoaderPriority;
	import com.timezero.game.system.GameTimer;
	import com.timezero.platform.display.BitmapMovieClip;
	import com.timezero.platform.display.MovieClipCollection;
	import com.timezero.platform.display.MovieClipEquivalent;
	import com.timezero.platform.display.StageObserver;
	import com.timezero.platform.display.resource.ResourceDefinition;
	import com.timezero.platform.events.DataBaseEvent;
	import com.timezero.platform.net.ILoadable;
	import com.timezero.platform.net.LoaderDispatcher;
	import com.timezero.platform.net.LoaderPriority;
	import com.timezero.platform.utils.time.FrameTimer;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	use namespace gfx_internal;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class AnimatedMapObject extends DynamicMapObject {
		
		//--------------------------------------------------------------------------
		//
		//  Class constatns
		//
		//--------------------------------------------------------------------------

		public static const CACHE_NONE:uint = 0;

		public static const CACHE_SELF:uint = 1;

		public static const CACHE_ALL:uint = 2;

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function getBundles(data:AnimatedMapObjectData):Array {
			if ( data is CharacterData ) {
				return Character.getBundles( data as CharacterData );
			} else if ( data is WorldInteractiveObjectData ) {
				return WorldInteractiveObject.getBundles( data as WorldInteractiveObjectData );
			} else if ( data is UFOData ) {
				return UFO.getBundles( data as UFOData );
			} else if ( data is GraphicsWorldEffectData ) {
				return GraphicsWorldEffect.getBundles( data as GraphicsWorldEffectData );
			}
			return new Array();
		}

		public static function clearCachedAnimation(hash:String):void {
			var anim:Object = _HASH[hash];
			
			if (anim) {
				for each (var o:Object in anim) {
					if (o is BitmapMovieClip) (o as BitmapMovieClip).dispose();
				}				
			}
			
			delete _HASH[hash];
		}

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

		public function AnimatedMapObject(data:AnimatedMapObjectData, cache:uint=CACHE_ALL, free:Boolean=false) {
			super( data, free );
			this._cache = cache;
			this._data = data;
			this._timer.addEventListener(TimerEvent.TIMER, this.renderFrame);
			
			if ( !super.free ) {
				var observer:StageObserver = new StageObserver( this );
				observer.registerEventListener( this._data, AnimationDataEvent.ANIMATION_CHANGED, this.handler_animationChanged );
				observer.registerEventListener( this._data, MapDataEvent.MAP_OBJECT_CHANGE, this.renderAnimation );
				observer.registerEventListener( this._data, DataBaseEvent.ADDED, this.handler_changed );
				observer.registerEventListener( this._data, DataBaseEvent.REMOVED, this.handler_changed );
				observer.registerEventListener( this._data, GraphicsLinkDataEvent.GRAPHICS_CHANGE, this.handler_changed );
			}

			super.addEventListener( Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MAX_VALUE );
			super.$container.addChild(this.$animation);
			//super.addEventListener(Event.REMOVED_FROM_STAGE, this.handler_removedFromStage, false);

		}

		gfx_internal override function destructor():void {
			super.removeEventListener( Event.ADDED_TO_STAGE, this.handler_addedToStage );
			this._timer.stop();
			this._timer.removeEventListener(TimerEvent.TIMER, this.renderFrame); // походу не всегда отписывается почему-то
			this.properties = null;
			this._data = null;
			super.gfx_internal::destructor();
		}

		//--------------------------------------------------------------------------
		//
		//  Includes
		//
		//--------------------------------------------------------------------------

//		include "../../../../includes/override_EventDispatcher.as";
//		include "../../../../includes/override_DisplayObject.as";
//		include "../../../../includes/override_InteractiveObject.as";
//		include "../../../../includes/override_DisplayObjectContainer.as";

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _cache:uint;

		/**
		 * @private
		 */
		protected var properties:AnimationProperties;
		
		/**
		 * @private
		 */
		protected var speedSensitive:Boolean = true;
		
		/**
		 * @private
		 */
		protected const $animation:Sprite = new Sprite();

		/**
		 * @private
		 */
		private var _data:AnimatedMapObjectData;

		/**
		 * @private
		 */
		private var _currentAnim:MovieClipEquivalent;

		/**
		 * @private
		 */
		private var _currentAnim_count:uint = 0;

		/**
		 * @private
		 */
		private var _loader:LoaderDispatcher;

		/**
		 * @private
		 */
		private const _animHash:Object = new Object();
		
		/**
		 * @private
		 */
		private const _lockHash:Object = new Object();

		/**
		 * @private
		 */
		private const _timer:FrameTimer = new FrameTimer( 100 );

		/**
		 * @private
		 */
		private var _startTime:Number;
		
		/**
		 * @private
		 */
		private var _preloader:DisplayObject;

		/**
		 * @private
		 */
		private var _preloaderResource:ResourceDefinition;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function setAnimation(properties:AnimationProperties, startTime:Number):void {
			if ( !properties ) properties = this._data.defaultAnimation;
			if ( this.properties && this.properties.id == properties.id ) {
				if ( ( this.properties.repeatCount == 0 ) == ( properties.repeatCount == 0 )  || this._data.animationStartTime == startTime ) {
					return;
				}
			}
			this.properties = properties;
			this._startTime = ( !startTime ? GameTimer.global.getRelativeTime() : startTime );
			//if ( this._loaded )	this.renderAnimation();
			/*else*/				this.render();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private const _hash_mc:Dictionary = new Dictionary();
		

		/**
		 * @private
		 */
		private var _loaded:Boolean = false;

		protected override function render(event:Event=null):Boolean {

			this._loaded = false;

			if ( !super.render( event ) || !this.properties ) {
				this.clear( event );
				return false;
			}

			var hash:String;
			var hashID:String;
			if ( this._cache > CACHE_NONE ) {
				hashID = this.getHashID();
			}

			if ( this._cache == CACHE_NONE || !this._animHash[ hashID] || !_HASH[ hash = this.getHash() ] || !_HASH[ hash ][ hashID ] ) {

				this._timer.stop();
	
				var resources:Array = this.getResourceList();
				var resource:AnimationResource;
	
				var loader:ILoadable;
	
				// cмотрим, что нам надо загрузить. если чего-то не хватает грузим
				for each ( resource in resources ) {
					loader = super.loadResourceBundle( resource.bundleName, GameLoaderPriority.GFX_ANIMATION_GRAPHICS );
					if ( !loader.loaded ) {
						if ( !this._loader ) this._loader = new LoaderDispatcher();
						this._loader.addLoaderListener( loader );
					}
					// пробуем загрузить вспомогательные XML
					var key:String = resource.bundleHashID + "_" + this.properties.id + "_" + this.rotation;

					if ( resource.bundleNameXML && !SortingAnimation.DEPTHS[ key ]) { //загрузим наши точечки
						loader = super.loadResourceBundle( resource.bundleNameXML, GameLoaderPriority.GFX_ANIMATION_XML );
	
						if ( !loader.loaded ) {
							if ( !this._loader ) this._loader = new LoaderDispatcher();
							this._loader.addLoaderListener( loader );
						}
					}
				}

			};
			
			// все загружено
			if ( !this._loader || this._loader.loaded ) {
				this.clearPreloader();
				if ( this._loader ) {
					this._loader.removeEventListener( Event.COMPLETE, this.render );
					this._loader.removeEventListener( ProgressEvent.PROGRESS, this.updatePreloader );
					this._loader.removeEventListener( IOErrorEvent.IO_ERROR, this.handler_error );
					this._loader = null;
				}
				this._loaded = true;
				// TODO: Возможно, послать событие со списком бандлов
				return this.renderAnimation( event );

			} else {
				this._loader.addEventListener( Event.COMPLETE, this.render );
				this._loader.addEventListener( IOErrorEvent.IO_ERROR, this.handler_error );
				
				var loaderResource:ResourceDefinition = this.getLoaderResource();
				if ( !this._preloaderResource || this._preloaderResource.equals( loaderResource ) ) {
					this.clearPreloader();

					if ( loaderResource ) {
						if ( !this._loader ) this._loader = new LoaderDispatcher();
						loader = super.loadResourceBundle( loaderResource.bundleName, LoaderPriority.PRELOADER );

						if ( !loader.loaded ) {
							loader.addEventListener( Event.COMPLETE, this.handler_preloader );
							loader.addEventListener( IOErrorEvent.IO_ERROR, this.handler_preloader );
						} else {
							this._preloader = super.getDisplayObject( loaderResource.bundleName, loaderResource.resourceName );

							if ( this._preloader ) {
								this.updatePreloader();
								this._preloaderResource = loaderResource;
								this.$animation.addChild( this._preloader );
								this._loader.addEventListener( ProgressEvent.PROGRESS, this.updatePreloader ); // есть прелоадер - можно повесить
							}
						}
					}
				}

				return false;
			}
		}
		
		/**
		 * @private
		 */
		/*private static var _useCache:Object = new Object();
		
		private function updateUsage(bundleName:String, resourceName:String):void {
			var item:ResourceItemUsage;
			
			if (bundleName in _useCache) {
				item = _useCache[bundleName] as ResourceItemUsage;
			} else {
				item = new ResourceItemUsage();
				_useCache[bundleName] = item;
			}

			item.lastAccessTime = getTimer();
			item.resourcesUsed++;	
		}
		
		private function unload():void {
			var item:ResourceItemUsage;
			var time:uint = getTimer();
			
			for (var bundleName:String in _useCache) {
				item = _useCache[bundleName] as ResourceItemUsage;
				
				if (item.resourcesUsed <= 0 && time - item.lastAccessTime > 10e3) {
					trace('unload', bundleName);
					super.unloadResourceBundle(bundleName);
					delete _useCache[bundleName];
				}
			}
		}
		
		private var _unloadInterval:uint;*/
		
		/**
		 * @private
		 */
		private static const PARSED_ANIMATION_HASH:Object = new Object();

		/**
		 * @private
		 * используется, если либы уже загружены
		 */
		private function renderAnimation(event:Event=null):Boolean {
			if (!super.stage || !this.properties || !this._loaded) return false;

			this._timer.stop();

			var hashID:String = this.getHashID();

			var anim:MovieClipEquivalent = this._animHash[ hashID ] as MovieClipEquivalent;
			
			var hash:String;
			var staticAnimHash:Object;
			if ( !anim && this._cache > CACHE_NONE ) { // нету анимации, он кэшируемый
				hash = this.getHash();
				staticAnimHash = _HASH[ hash ];
				if ( staticAnimHash ) { // опа. чё-то там есть
					anim = staticAnimHash[ hashID ] as BitmapMovieClip;
					if ( anim ) {
						this._animHash[ hashID ] =
						anim = ( anim as BitmapMovieClip ).clone();
						super.dispatchEvent(new AnimatedMapObjectEvent(AnimatedMapObjectEvent.GET_ANIMATION, true, false, hash, hashID));
					}
				}
			}

			if ( !anim ) {

				var resources:Array = this.getResourceList();
				var resource:AnimationResource;

				var xml:XML;
				var xmlList:XMLList;
				var slot:uint;
				var action:uint;
				var index:int;
				var points:Array;
				var mc:DisplayObject;

				var animationID:uint = this.properties.id;
				var rotation:Number = this.rotation;

				var anim2:SortingAnimation = new SortingAnimation();

				anim2.characterAction = animationID;
				anim2.characterRotation = rotation;

				for each (resource in resources) {
					mc = super.getDisplayObject( resource.bundleName, resource.resourceName );

					if ( mc ) {
						if (this._cache == CACHE_SELF) {
							if (!(resource.bundleName in this._lockHash)) {
								this._lockHash[resource.bundleName] = true;
								super.lockResourceBundle(resource.bundleName);
							}
						}

						//this.updateUsage(resource.bundleName, resource.resourceName);
						this._hash_mc[ mc ] = resource;
						
						anim2.addChild( mc );
						mc.name = resource.bundleHashID;

						resource.filters.apply( mc );

						if ( !SortingAnimation.DEPTHS[ resource.bundleHashID + "_" + animationID + "_" + rotation ] ) {
							var parseHash:Array = PARSED_ANIMATION_HASH[resource.bundleNameXML];
							
							if (!parseHash) {
								parseHash = new Array();
								
								if ( super.hasResource( resource.bundleNameXML, "" ) ) {
									var data:String = super.getResource( resource.bundleNameXML, "" ) as String;
									xml = new XML( data ); 
									xmlList = xml.animation[0].action;
									
									for each ( var a:XML in xmlList ) {
										points = [];
										action = parseInt(a.@actionID, 16);
										
										for each(var b:XML in a.children()) {
											points.push(new Vector3D(parseFloat(b.@x), parseFloat(b.@y), parseFloat(b.@z)));
										}

										parseHash[action] = points;
									}
									
									if (!(resource.bundleNameXML in this._lockHash)) {
										this._lockHash[resource.bundleNameXML] = true;
										super.lockResourceBundle(resource.bundleNameXML);
									}

									super.trashResource(data);
								} else {
									points = [new Vector3D(0,0,Number.POSITIVE_INFINITY)]
									parseHash[animationID] = points;
								}
								
								PARSED_ANIMATION_HASH[resource.bundleNameXML] = parseHash;
							}
							
							if (parseHash[animationID] is Array) anim2.addDepthsRaitingsToHash(resource.bundleHashID, animationID, rotation, parseHash[animationID]);
						}

						mc = null;
					}
				}

				if ( this._cache > CACHE_NONE ) {
					var anim3:BitmapMovieClip = new BitmapMovieClip( PixelSnapping.ALWAYS );
	
					//anim2.sort();
					var totalFrames:int = anim2.totalFrames;
					for ( var i:uint = 1; i<=totalFrames; i++ ) {
						anim2.gotoAndStop( i );
						anim3.addBitmap( anim2 );
					}				
					
					this.clearAnimation( anim2 );
					
					if (this._cache == CACHE_ALL) {
						if ( !_HASH[ hash ] ) _HASH[ hash ] = staticAnimHash = new Object();	
						staticAnimHash[ hashID ] = anim3;
						super.dispatchEvent(new AnimatedMapObjectEvent(AnimatedMapObjectEvent.GET_ANIMATION, true, false, hash, hashID));
					}
					
					anim = anim3;
				} else {
					anim = anim2;
				}
				this._animHash[ hashID ] = anim;

			}
			
			var timer:GameTimer = GameTimer.global;
			
			if ( anim.totalFrames > 1 ) {
				if ( this.speedSensitive && this._data.animationSpeed > 0 ) {
					this._timer.delay = this.properties.length * timer.getRoundTime() / this._data.animationSpeed 	/ anim.totalFrames * 0.7;
				} else {
					this._timer.delay = this.properties.length * timer.getRoundTime() / 1 						 	/ anim.totalFrames * 0.7;
				}
				this._timer.start();
				this.renderFrame();
			} else {
				if ( this._currentAnim && this._currentAnim !== anim ) {
					this._currentAnim.gotoAndStop( 1 );
					this.$animation.removeChild( this._currentAnim );
					this._currentAnim = null;
				}
				if ( !this._currentAnim ) {
					this._currentAnim = anim;
					this._currentAnim.gotoAndStop( 1 );
					this.$animation.addChild( this._currentAnim );
//					if ( this._currentAnim is SortingAnimation ) {
//						( this._currentAnim as SortingAnimation ).sort();
//					}
				}
			}

			return true;
		}

		[ArrayElementType("CharacterResource")]
		protected virtual function getResourceList():Array {
			throw new ReferenceError();
		}

		[ArrayElementType("CharacterLoaderResource")]
		protected virtual function getLoaderResource():ResourceDefinition {
			return null;
		}

		protected override function clear(event:Event=null):Boolean {
			if ( !super.clear( event ) ) return false;

			this._timer.stop();
			if ( this._currentAnim ) {
				if ( this._currentAnim.parent ) {
					this._currentAnim.parent.removeChild( this._currentAnim );
				}
				
				this._currentAnim = null;
			}
			
			var hash:String = this._data ? this._data.getHash() : null;
			var anim:MovieClipEquivalent;

			for ( var key:String in this._animHash ) {
				anim = this._animHash[ key ] as MovieClipEquivalent;
				if ( anim is MovieClipCollection ) {
					this.clearAnimation( anim as MovieClipCollection );
				} else if (this._cache == CACHE_SELF && anim is BitmapMovieClip) {
					(anim as BitmapMovieClip).dispose(); 
				}
				delete this._animHash[key];
				if (hash && anim is BitmapMovieClip && hash in _HASH) super.dispatchEvent(new AnimatedMapObjectEvent(AnimatedMapObjectEvent.TRASH_ANIMATION, true, false, hash, key));
			}
			
			for (var bundleName:String in this._lockHash) {
				delete this._lockHash[bundleName];
				super.unlockResourceBundle(bundleName);
			}
			this.clearPreloader();	
			return true;
		}

		protected function renderFrame(event:Event=null):Boolean {
			if (!super.stage || !this.properties) return false;
			var i:uint = this.$animation.numChildren;
			var anim:MovieClipEquivalent = this._animHash[ this.getHashID() ] as MovieClipEquivalent;

			if ( !anim ) {
				this.renderAnimation( event );
				if (!super.stage || !this.properties) return false;
				anim = this._animHash[ this.getHashID() ] as MovieClipEquivalent;
			}

			if ( !anim ) return false;
			
			var timer:GameTimer = GameTimer.global;
			var totalFrames:int = anim.totalFrames;
			var time:Number = this.properties.length * timer.getRoundTime();
			
			if ( this.speedSensitive ) time /= this._data.animationSpeed;
			
			var currentTime:Number = timer.getRelativeTime();
			if ( currentTime < this._startTime ) this._startTime = currentTime;
			
			var timesCount:Number = ( currentTime - this._startTime ) / time;
			var currentFrame:uint = Math.round( timesCount * ( totalFrames - 1 ) ) % totalFrames + 1;
			
			if ( this._currentAnim && this._currentAnim !== anim ) {
				this._currentAnim.gotoAndStop( 1 );
				this.$animation.removeChild( this._currentAnim );
				this._currentAnim = null;
			}
			if ( !this._currentAnim ) {
				this._currentAnim = anim;
				this.$animation.addChild( this._currentAnim );
			}

			this._currentAnim_count = timesCount;

			this._currentAnim.gotoAndStop( currentFrame );

			//если текущая анимация закончилась
			if ( this.properties.repeatCount>0 && this._currentAnim_count >= this.properties.repeatCount ) {
				this._currentAnim_count = 0;
				this._timer.stop();
				if ( this.properties.stopOnEnd ) {
					this._currentAnim.gotoAndStop( this._currentAnim.totalFrames );
				} else {
					this.setAnimation( null, timer.getRelativeTime() );
				}
				this.animationComplete( event );
			}			
			return true;
		}

		protected function animationComplete(event:Event=null):void {
		}

		protected virtual function getHashID():String {
			return String.fromCharCode( this.properties.id, this.rotation );
		}

		protected function getHash():String {
			return this._data.getHash();
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function clearAnimation(anim:MovieClipCollection):void {
			var mc:DisplayObject;
			var resource:ResourceDefinition;
			var time:uint = getTimer();
			
			while ( anim.numChildren ) {
				mc = anim.removeChildAt( 0 );
				
				if ( mc in this._hash_mc ) {
					resource = this._hash_mc[ mc ] as ResourceDefinition;
/*					var item:ResourceItemUsage = _useCache[resource.bundleName] as ResourceItemUsage;
					
					if (item) {
						item.resourcesUsed--;
						
						if (item.resourcesUsed <= 0 && time - item.lastAccessTime > 10e3) {
							delete _useCache[resource.bundleName];
							trace('unload on clear', resource.bundleName);
							super.unloadResourceBundle(resource.bundleName);
							continue;
						}
					} */

					super.trashResource( mc, 30*1E3 );
				}
			}
		}

		/**
		 * @private
		 */
		private function clearPreloader():void {
			if ( this._preloader ) {
				super.trashResource( this._preloader, 60*1E3 );
				this._preloaderResource = null;
				this._preloader = null;
			}
		}

		/**
		 * @private
		 */
		private function updatePreloader(event:Event=null):void {
			if ( this._preloader ) {
				var mc:MovieClip = this._preloader as MovieClip;
				if ( mc ) mc.gotoAndStop( Math.round( this._loader.bytesLoaded / this._loader.bytesTotal * mc.totalFrames ) + 1 );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_error(event:ErrorEvent):void {
			if ( this._loader ) {
				this._loader.removeLoaderListener( event.target as ILoadable );
			}
		}

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {
			var prop:AnimationProperties;
			var startTime:Number;
			if ( !super.free ) {
				prop = this._data.animation;
				startTime = this._data.animationStartTime;
			} else {
				prop = this._data.defaultAnimation;
				startTime = GameTimer.global.getRelativeTime();
			}
			this.setAnimation( prop, startTime );
			//this._unloadInterval = setInterval(this.unload, 20E3);
		}

		/**
		 * @private
		 */
		/*
		private function handler_removedFromStage(event:Event):void {
			clearInterval(this._unloadInterval);	
		}*/

		/**
		 * @private
		 */
		private function handler_animationChanged(event:Event):void {
			this.setAnimation( this._data.animation, this._data.animationStartTime );
		}

		/**
		 * @private
		 */
		private function handler_preloader(event:Event):void {
			( event.target as ILoadable ).removeEventListener( Event.COMPLETE, this.handler_preloader );
			( event.target as ILoadable ).removeEventListener( IOErrorEvent.IO_ERROR, this.handler_preloader );
			if ( event is ErrorEvent )	this.handler_error( event as ErrorEvent );
			else						this.render( event );
		}

		private function handler_changed(event:DataBaseEvent):void {
			if ( event.target is GraphicsElementData ) {
				this.clear( event );
				this.render( event );
			}
		}

	}

}
/*
internal class ResourceItemUsage {
	
	public var lastAccessTime:uint;
	
	public var resourcesUsed:uint;
	
	public function ResourceItemUsage() {
		super();
	}	
}*/