// License: LGPL-3.0-or-later
import h  from 'snabbdom/h'
import {init as infoStepInit} from './info-step';

type Params = {
  offsite?: boolean | undefined;
  redirect?: boolean | undefined;
  modal?: boolean | undefined;
};

interface ViewState {
  infoStep: ReturnType<typeof infoStepInit>;
  thankyou_msg?:string | undefined;
  params$: () => Params
  clickFinish$: () => void
}

export function view(state: ViewState): ReturnType<typeof h>;
