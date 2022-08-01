// License: LGPL-3.0-or-later
import type {Meta} from '@storybook/react';

/**
 * Adds type safety to your default export for storybook files
 * @param args arguments for your default storybook export
 */
export function defaultStoryExport<TArgType>(args: Meta<TArgType>):  Meta<TArgType> {
	return args;
}