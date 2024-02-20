// License: LGPL-3.0-or-later
import h from 'snabbdom/h';
import {init as amountStepInit} from './amount-step'
import {init as infoStepInit} from './info-step';
import {init as paymentStepInit} from './payment-step';
import {init as wizardInit} from 'ff-core/wizard';
import { StandardizedParams } from './types';


type InputParamsType = any;
type Donation = any;


interface InitState {
  params$:()=> StandardizedParams;
  error$:(error?:string) => string|undefined
  loader$:(loading?:boolean) => boolean|undefined
  clickLogout$:() => void;
  clickFinish$:() => void;
  hide_cover_fees_option: boolean | undefined ;
  manual_cover_fees: boolean | undefined;
  hide_anonymous: boolean| undefined;
  selected_payment$: (payment:string) => string;
  amountStep: ReturnType<typeof amountStepInit>
  donationAmount$: () => number|undefined;
  infoStep: ReturnType<typeof infoStepInit>;
  donation$: () => Donation
  paymentStep: ReturnType<typeof paymentStepInit>
  wizard: ReturnType<typeof wizardInit>;
 }


export declare function init( params$: () => InputParamsType): InitState;


export declare function view(state:InitState) : ReturnType<typeof h>;