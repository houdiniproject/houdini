import h from 'snabbdom/h';
import DonationSubmitter from './DonationSubmitter'
import {init as cardFormInit} from '../../components/card-form';
 
type Supporter = any;
type Donation = any;
type DedicationData = any;
type SelectedPaymentType = any;
type ParamsType = any;

interface InitInput {
  supporter$: (supporter?:Supporter) => Supporter;
  donation$: (donation?:Donation) => Donation;
  dedicationData$: (dedication?:DedicationData) => DedicationData;
  activePaymentTab$: (selectedPayment?:SelectedPaymentType) => SelectedPaymentType;
  params$: (params?:ParamsType) => ParamsType
}

type Progress = {hidden:boolean } | {status: string};

type SepaForm = any;
type DonationParams = any;

interface InitState extends InitInput {
  donationTotal$: (total?:number) => number| undefined;
  potentialFees$: (fees?:number) => number | undefined;
  loading$: (loading?:boolean) => boolean |undefined;
  error$: () => DonationSubmitter['error']
  progress$: () => Progress;

  onInsert: () => void;
  onRemove: () => void;
  cardForm: ReturnType< typeof cardFormInit>;
  sepaForm: SepaForm;
  donationParams$: () => DonationParams;
  paid$: () => boolean;
 }


export declare function init( input: InitInput): InitState;


export declare function view(state:InitState) : ReturnType<typeof h>;