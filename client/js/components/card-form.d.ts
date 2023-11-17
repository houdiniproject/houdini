// License: LGPL-3.0-or-later
// npm
import h from 'snabbdom/h'


type InitInput = any;
type InitState = any;


export function init(state:InitInput): InitState;

type MountInput = {elementMounted:true, element:any}| {elementMount?:false};

export function mount(state:MountInput):void;

interface ViewState extends InitState {
  error$:() => string| false |undefined;
  hideButton: boolean
}

export function view(state:ViewState): ReturnType< typeof h>;

