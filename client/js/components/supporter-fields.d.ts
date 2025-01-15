// License: LGPL-3.0-or-later
import h from 'snabbdom/h';

type InitState = any;
type InputState =any;
type Params = () => any;
type OutputState = any;

export function init(state:InitState, params$:Params):OutputState;

type ViewState = any

export function view(state:ViewState) : ReturnType<typeof h>;
