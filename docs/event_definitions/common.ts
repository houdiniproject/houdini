// License: LGPL-3.0-or-later

/**
 * the main identifier for HoudiniObjects which is unique between all other HoudiniObjects with the same object value.
 * Currently just an integer but we could reevaluate later;
 */
export type IdType = number;

/**
 * an identifier for HoudiniObjects which is unique among all HoudiniObjects.
 */
export type HouID = string;

/**
 * Describes a monetary value in the minimum unit for this current. Corresponds to Money class in
 * Ruby and Typescript
 */
export type Amount = { currency: string, value_in_cents: string };

/**
 * A more flexible version of Amount. In cases where we can assume what the currency is,
 * we don't actually require you to provide it. Probably will be used most by APIs
 */
export type FlexibleAmount = Amount | string | number;

/**
 * A rule for something recurring. Used for recurring donations. Based on `ice_cube` gem format
 *
 * @example
 * // Recur once a month, for  3 times
 * { count: 3, interval: 1, type: 'monthly' }
 * @example
 * // Recur every other month, stop on June 1, 2021
 * { interval: 2, type: 'monthly', until: new Date(2021, 6, 1) }
 * @example
 * // Recur every year
 * { interval: 1, type: 'yearly' }
 */
export type RecurrenceRule = {
	/**
	 * The number of times we should run the recurrence
	 */
	count?: number;
	/**
	 * Interval of `type` for the event to recur
	 */
	interval: number;
	/**
	 * The scale of the recurrence
	 */
	type: 'monthly' | 'year';
	/**
	 * The the point after which the rule should not recur anymore.
	 */
	until?: Date;
};


/**
 * Every object controlled by the Houdini event publisher must meet this standard interface
 * and will inherit from it.
 */
export interface HoudiniObject<Id extends IdType|HouID=IdType> {
	/**
	 * An IdType which unique which uniquely identifies this object
	 * from all other similar objects
	 */
	id: Id;
	/**
	 * the type of object. Roughly corresponds to the object's class in Rails
	 */
	object: string;
}


type HoudiniObjectOfAllIds = HoudiniObject<IdType> | HoudiniObject<HouID>;
/**
 * An event published by Houdini
 *
 * Generics:
 * * EventType a snake-cased string of the format: "<object_type>.<event_name>". As an example
 * 		tag_master.created means the event fired by when a tag_master was created
 * * DataObject: the interface representing the actual object which the event occurred on. An object of that type is
 * on the 'data' attribute
 */
export interface HoudiniEvent<EventType extends string, DataObject extends HoudiniObjectOfAllIds> {
	/** data for the event. We wrap the object inside becuase we might want to provide some sort of   */
	data: {
		/** the object after the event has occurred */
		object: DataObject;
	};
	/**
	 * A HouID uniquely representing the event
	 */
	id: HouID;
	object: 'object_event';
	/** The type of event that this is */
	type: EventType;

}