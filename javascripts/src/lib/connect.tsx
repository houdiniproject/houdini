import * as React from 'react'
import hoistNonReactStatics = require('hoist-non-react-statics');

export function connect<OuterProps, Context, ContextProps, ConsumerProps>(
  Comp: React.ComponentType<OuterProps & ContextProps>,
  Consumer:React.Consumer<Context>,
  GetComponentPropertyFromContext:(consumerProps:Context) => ContextProps,
  DisplayName:string
) {
  const C: React.SFC<OuterProps> = (props: OuterProps) => (
    <Consumer>
      {selectHandler => <Comp {...props} {...GetComponentPropertyFromContext(selectHandler)} />}
    </Consumer>
  );
  const componentDisplayName =
    Comp.displayName ||
    'Component';

  // Assign Comp to C.WrappedComponent so we can access the inner component in tests
  // For example, <Field.WrappedComponent /> gets us <FieldInner/>
  (C as React.SFC<OuterProps> & {
    WrappedComponent: React.ReactNode;
  }).WrappedComponent = Comp;

  C.displayName = `${DisplayName}(${componentDisplayName})`;

  return hoistNonReactStatics(
    C,
    Comp as React.ComponentClass<OuterProps & Context> // cast type to ComponentClass (even if SFC)
  );
}