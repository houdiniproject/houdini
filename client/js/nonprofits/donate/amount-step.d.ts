// License: LGPL-3.0-or-later
import h from 'snabbdom/h';
import { StandardizedParams } from './types';


type InputParamsType = any;
type Donation = any;
type InputDonationDefaults = any;


interface InitState {
  params$:()=> StandardizedParams;
  evolveDonation$:(evolution?:Partial<Donation>) => Partial<Donation> | undefined;
  buttonAmountSelected$(isSelected?:boolean): boolean|undefined;
  currentStep$(step?:number): number |undefined;
 }


export declare function init( donationDefaults: InputDonationDefaults, params$: () => InputParamsType): InitState;


export declare function view(state:InitState) : ReturnType<typeof h>;