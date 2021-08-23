import type {DecoratorFn} from '@storybook/react';
import { StoryFn } from '@storybook/addons';


function decorator(story:StoryFn<JSX.Element>): JSX.Element {
	sessionStorage.clear();
	return story();
}

export default function decorate(): DecoratorFn {
	return decorator;
}