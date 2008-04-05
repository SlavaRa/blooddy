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
	import flash.errors.IllegalOperationError;

	import flash.utils.getQualifiedClassName;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @inheritDoc
	 */
	[Event(name="addedToBase", type="by.blooddy.platform.events.DataBaseEvent", deprecatedMessage="событие не используется")]

	/**
	 * @inheritDoc
	 */
	[Event(name="removedFromBase", type="by.blooddy.platform.events.DataBaseEvent", deprecatedMessage="событие не используется")]

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude(kind="property", name="name")]
	[Exclude(kind="property", name="$base")]
	[Exclude(kind="property", name="$parent")]

	[Exclude(kind="event", name="addedToBase")]
	[Exclude(kind="event", name="removedFromBase")]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					database, data
	 */
	public final class DataBase extends DataContainer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function DataBase() {
			super();
			super.$base = this;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: Data
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  id
		//----------------------------------

		/**
		 * @private
		 */
		public override function set name(value:String):void {
			throw new IllegalOperationError( ErrorsManager.getErrorMessage(2071), 2071 );
		}

		//----------------------------------
		//  base
		//----------------------------------

		[Deprecated(message="свойство не используется")]
		/**
		 * @private
		 */
		internal override function set $base(value:DataBase):void {
			throw new IllegalOperationError();
		}

		//----------------------------------
		//  parent
		//----------------------------------

		[Deprecated(message="свойство не используется")]
		/**
		 * @private
		 */
		internal override function set $parent(value:DataContainer):void {
			throw new IllegalOperationError();
		}

	}

}