// License: LGPL-3.0-or-later
import * as React from 'react';
import {IntlProvider, intlShape} from 'react-intl';
import {mount, MountRendererProps, shallow, ShallowRendererProps, ShallowWrapper} from 'enzyme';

// Create the IntlProvider to retrieve context for wrapping around.
const intlProvider = new IntlProvider({ locale: 'en'}, {});
const { intl } = intlProvider.getChildContext();

/**
 * When using React-Intl `injectIntl` on components, props.intl is required.
 */
function nodeWithIntlProp(node:any) {
  return React.cloneElement(node, { intl });
}

export function shallowWithIntl(node:any, options?:ShallowRendererProps) {
  let context = {}

  if (options ) {
    context = options.context

  }
  return shallow(
    nodeWithIntlProp(node),
    {
      ...options,
      context: (Object as any).assign({}, context, {intl})
    }
  ).dive();
}


export function mountWithIntl(node:any, options?:MountRendererProps) {
  let context = {}
  let additionalOptions:Array<any> = []
  let childContextTypes = {}

  if (options) {
    context = options.context
    childContextTypes = options.childContextTypes
  }
  return mount(
    nodeWithIntlProp(node),
    {
      ...options,
      context:(Object as any).assign({},context, {intl}),
      childContextTypes: (Object as any).assign({}, { intl: intlShape }, childContextTypes)

    }
  );
}


interface shallowUntilTargetProps {
  maxTries?: number
  shallowOptions?: ShallowRendererProps,
  _shallow?: Function
}

/* from: https://github.com/mozilla/addons-frontend/blob/18f433f2199fb3d68109ef4d0a164ba1af37520a/tests/unit/helpers.js
 * Repeatedly render a component tree using enzyme.shallow() until
 * finding and rendering TargetComponent.
 *
 * This is useful for testing a component wrapped in one or more
 * HOCs (higher order components).
 *
 * The `componentInstance` parameter is a React component instance.
 * Example: <MyComponent {...props} />
 *
 * The `TargetComponent` parameter is the React class (or function) that
 * you want to retrieve from the component tree.
 */
export function shallowUntilTarget<T>(componentInstance:React.ReactElement<any>, TargetComponent:{new(): T}, props:shallowUntilTargetProps): ShallowWrapper<T> {
  if (!componentInstance) {
    throw new Error('componentInstance parameter is required');
  }
  if (!TargetComponent) {
    throw new Error('TargetComponent parameter is required');
  }


  let maxTries = props.maxTries || 10
  let shallowOptions = props.shallowOptions || null
  let _shallow = props._shallow || shallow

  let root = _shallow(componentInstance, shallowOptions);

  if (typeof root.type() === 'string') {
    // If type() is a string then it's a DOM Node.
    // If it were wrapped, it would be a React component.
    throw new Error(
      'Cannot unwrap this component because it is not wrapped');
  }

  for (let tries = 1; tries <= maxTries; tries++) {
    if (root.is(TargetComponent)) {
      // Now that we found the target component, render it.
      return root.shallow(shallowOptions);
    }
    // Unwrap the next component in the hierarchy.
    root = root.dive();
  }

  throw new Error(`Could not find ${TargetComponent} in rendered
    instance: ${componentInstance}; gave up after ${maxTries} tries`
  );
}

export function shallowUntilTargetWithIntl(node:any, TargetComponent:any, options?:ShallowRendererProps): ShallowWrapper<any> {
  let context = {}

  if (options ) {
    context = options.context

  }
  return shallowUntilTarget(
    nodeWithIntlProp(node),
    TargetComponent,
    {
      shallowOptions: {
  ...options,
    context: (Object as any).assign({}, context, {intl})
  }})
}