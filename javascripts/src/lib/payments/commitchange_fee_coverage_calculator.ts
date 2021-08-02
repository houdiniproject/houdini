// License: LGPL-3.0-or-later
import { centsToDollars } from "../format";
import Money from "../money";
import { CommitchangeStripeFeeStructure } from "./commitchange_stripe_fee_structure";
import { FeeStructure } from "./fee_structure";

interface CFCCConstructorArgs  {
    flatFee:number;
    percentageFee:number;
    feeCovering?: boolean;
    currency: string;
}

export class CommitchangeFeeCoverageCalculator {
  readonly feeStructure: CommitchangeStripeFeeStructure;
  readonly feeCovering: boolean|null;
  readonly currency: string;
  constructor(args:CFCCConstructorArgs) {
    this.feeStructure = new CommitchangeStripeFeeStructure(args);
    this.feeCovering = args.feeCovering;
    this.currency = args.currency;
    Object.bind(this.calc);
    Object.bind(this.calcFromNet);
    Object.freeze(this);
  }
  
  calc(gross:Money|number|null|undefined) : CommitchangeFeeCoverageCalculator.ReverseCalcResult {
    gross = this.retypeToMoney(gross);
    const calculation = this.feeStructure.calc(gross);
    
    return {
      estimatedFees: {
        gross: calculation.gross,
        grossAsNumber: calculation.gross.amountInCents.toNumber(),
        fee: calculation.fee,
        feeAsNumber: calculation.fee.amountInCents.toNumber(),
        net: calculation.net,
        netAsNumber: calculation.net.amountInCents.toNumber()
      }
      
    }
  }

  calcFromNet(net:Money|number|null): CommitchangeFeeCoverageCalculator.Result {
    net = this.retypeToMoney(net);
    const calculation = this.feeStructure.calcFromNet(net)
    const actualTotal = this.feeCovering ? calculation.gross : net;
    return {
      actualTotal,
      actualTotalAsNumber: actualTotal.amountInCents.toNumber(),
      actualTotalAsString: "$" + centsToDollars(actualTotal.amountInCents.toNumber()),
      estimatedFees: {
        ...calculation,
        feeAsNumber: calculation.fee.amountInCents.toNumber(),
        feeAsString: "$" + centsToDollars(calculation.fee.amountInCents.toNumber()),
        grossAsNumber: calculation.gross.amountInCents.toNumber(),
        netAsNumber: calculation.net.amountInCents.toNumber(),
      },
    }
  }

  private retypeToMoney(amount:Money|number|null|undefined):Money {
    if (amount === null || amount === undefined) {
      amount = 0;
    }
    
    if (typeof amount === 'number') {
      return Money.fromCents(amount, this.currency);
    }
    return amount;
  }
  
  
}

namespace CommitchangeFeeCoverageCalculator {
  export interface Result  {
    estimatedFees: FeeStructure.CalculationResult & {
      feeAsNumber: number;
      netAsNumber: number;
      grossAsNumber: number;
      feeAsString: string;
    }

    actualTotal: Money;
    actualTotalAsNumber: number;
    actualTotalAsString: string;
  }

  export interface ReverseCalcResult {
    estimatedFees: {
      gross:Money;
      grossAsNumber: number;
      fee:Money;
      feeAsNumber: number;
      net:Money;
      netAsNumber: number;
    }
  }
}