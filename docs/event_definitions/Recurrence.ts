// License: LGPL-3.0-or-later
import type { Amount, HoudiniEvent, HoudiniObject, HouID, IDType } from "./common";
import type Nonprofit from './Nonprofit';
import type { RecurrenceRule } from "./common";
import type Supporter from "./Nonprofit/Supporter";
import type { CreateTrxAssignment } from "./Nonprofit/Transaction";

export interface InvoiceTemplate {
  amount: Amount;
  payment_method: {
    /** will be added in future but not yet. */
    id: never;
    type: 'stripe';
  };
  supporter: IDType;

  /**
   * The assignments created if the invoice succeeds. For now, we can only create new donations.
   */
  trx_assignments: CreateTrxAssignment[];
}


export interface Recurrence extends HoudiniObject<HouID> {
	nonprofit: IDType | Nonprofit;
  object: 'recurrence';
  recurrences: RecurrenceRule[];
  start_date: number;
  supporter: IDType | Supporter;
  template: InvoiceTemplate;
}

export type RecurrenceCreated = HoudiniEvent<'recurrence.created', Recurrence>;
export type RecurrenceUpdated = HoudiniEvent<'recurrence.updated', Recurrence>;
export type RecurrenceDeleted = HoudiniEvent<'recurrence.deleted', Recurrence>;
