// License: LGPL-3.0-or-later
import h  from 'snabbdom/h'
import {init as infoStepInit} from './info-step';
import { StandardizedParams } from './types';

type Params = {
  offsite?: boolean | undefined;
  redirect?: boolean | undefined;
  modal?: boolean | undefined;
};

interface ViewState {
  infoStep: ReturnType<typeof infoStepInit>;
  thankyou_msg?:string | undefined;
  params$: () => StandardizedParams
  clickFinish$: () => void
}

export function view(state: ViewState): ReturnType<typeof h>;
