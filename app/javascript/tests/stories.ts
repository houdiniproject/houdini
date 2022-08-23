// License: LGPL-3.0-or-later
import type {Meta, Story} from '@storybook/react';

/**
 * Adds type safety to your default export for storybook files
 * @param args arguments for your default storybook export
 */
export function defaultStoryExport<TArgType>(args: Meta<TArgType>):  Meta<TArgType> {
	return args;
}

export class StoryTemplate<TemplateArgs> {

	constructor(private readonly templateFunc:(args: TemplateArgs) => JSX.Element) {
	}

	newStory(storyDetails?:{args?: Partial<TemplateArgs>, story?: unknown}): Story<TemplateArgs> {
		const func = this.templateFunc.bind({});
		if (storyDetails?.args) {
			func.args = storyDetails.args;
		}
		if (storyDetails?.story) {
			func.story = storyDetails.story;
		}

		return func;
	}
}