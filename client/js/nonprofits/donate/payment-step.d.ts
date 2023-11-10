import h from 'snabbdom/h';



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

type InitOutput = any;


export declare function init( input: InitInput): InitOutput;


type ViewState = any;

export declare function view(state:ViewState) : ReturnType<typeof h>;