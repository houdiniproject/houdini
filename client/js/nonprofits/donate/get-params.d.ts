// License: LGPL-3.0-or-later
import { AmountButtonInput } from "./amt";
import { StandardizedParams } from "./types";

type GetParamsInputBase = {[prop:string]: any};

export type GetParamsOutput<TInput> = TInput & {
  custom_amounts:AmountButtonInput[],
  tags?:string[],
}

declare const getParams: <GetParamsInput extends GetParamsInputBase>(input:GetParamsInput) => StandardizedParams;


export default getParams;