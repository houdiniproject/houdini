import h from 'snabbdom/h';
import {init as supporterFieldsInit} from '../../components/supporter-fields';
import type {DedicationData, StandardizedParams} from './types';

type Supporter = any;
type Donation = any;
type SelectedPaymentType = any;


interface ParentState {
  selectedPayment$:(payment?:string) => string | undefined;
  donationAmount$: () => number;
  params$: () => StandardizedParams;
  currentStep$: (currentStep?:number) => number;
}


type SavedSupp = any;
type SavedDedicatee = any;

interface InitState {
  donation$: () => Donation
  dedicationData$: () => DedicationData
  dedicationForm$: () => boolean;
  supporterFields: ReturnType<typeof supporterFieldsInit>
  savedSupp$: () => SavedSupp;
  savedDedicatee$: () => SavedDedicatee;
  supporter$: () => Supporter;
  currentStep$: (currentStep?:number) => number;
  params$: () => StandardizedParams;
}

export declare function init( donation$:Donation, parentState: ParentState): InitState;


export declare function view( state:InitState ) : ReturnType<typeof h>;