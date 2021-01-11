// License: LGPL-3.0-or-later

/**
 * the main identifier for HoudiniObjects which is unique between all other HoudiniObjects with the same object value.
 * Currently just an integer but we could reevaluate later;
 */
export type IdType = number;

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
 * Every object controlled by the Houdini event publisher must meet this standard interface
 * and will inherit from it.
 */
export interface HoudiniObject {
	/**
	 * An IdType which unique which uniquely identifies this object
	 * from all other similar objects
	 */
	id: IdType;
	/**
	 * the type of object. Roughly corresponds to the object's class in Rails
	 */
	object: string;
}

/**
 * An event published by Houdini
 *
 * Generics:
 * * EventType a snake-cased string of the format: "<object_type>.<event_name>". As an example
 * 		tag_master.created means the event fired by when a tag_master was created
 * * DataObject: the interface representing the actual object which the event occurred on. An object of that type is
 * on the 'data' attribute
 */
export interface HoudiniEvent<EventType extends string, DataObject extends HoudiniObject> {
	/** data for the event. We wrap the object inside becuase we might want to provide some sort of   */
	data: {
		/** the object after the event has occurred */
		object: DataObject;
	};
	/**
	 * A UUID uniquely representing the event
	 */
	id: string;
	object: 'object_event';
	/** The type of event that this is */
	type: EventType;

}