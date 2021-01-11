// License: LGPL-3.0-or-later
import type { HoudiniObject } from '../common';

/**
 * A single nonprofit organization on Houdini.
 */
export default interface Nonprofit extends HoudiniObject {
	name: string;
	object: "nonprofit";
}
