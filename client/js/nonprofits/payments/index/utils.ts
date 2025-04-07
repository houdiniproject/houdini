// License: LGPL-3.0-or-later

import { readableKind } from "../../../../../javascripts/src/lib/format";

export function kindIconClass(kind:string) : string {
	if(kind === "Donation") return "fa-heart"
	if(kind === "OffsitePayment") return "fa-money"
	if(kind === "RecurringDonation") return "fa-refresh"
	if(kind === "Ticket") return "fa-ticket"
	if(kind === "Refund") return "fa-rotate-left"
	if(kind === "ManualAdjustment") return "fa-plus"

  //should never happen but make TS happy:

  return "";
}


export {readableKind};