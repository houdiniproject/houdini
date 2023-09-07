// License: LGPL-3.0-or-later
/** This file is the beginning of a migration of code from public-activities.js to ts */

import moment from "moment";

/**
 * As described in QueryDonations.for_campaign_activities
 */
interface CampaignPageActivity {
  supporter_name: string;
  amount: string;
  recurring: boolean;
  date: string;
}

interface EventPageActivity {
  supporter_name: string;
  quantity: number;
  created_at: string;
}

interface ActivityFormatted {
  name: string;
  action: string;
  date: string;
}

export function ago(date: moment.MomentInput): string {
  return moment(date).fromNow();
}

export function formatRecurring(o: { recurring: boolean }) {
  return o.recurring
    ? `made a recurring contribution of`
    : `contributed`;
}

export function formatCampaign(r: { body: CampaignPageActivity[] }): ActivityFormatted[] {
  return r.body.map(o => (
    {
      name: o.supporter_name,
      action: formatRecurring(o) + ' ' + o.amount,
      date: ago(o.date),
    }
  ))
}

export function formatEvent(r: { body: EventPageActivity[] }): ActivityFormatted[] {
  return r.body.map(o => (
    {
      name: o.supporter_name,
      action: `got ${o.quantity} ticket${o.quantity > 1 ? 's' : ''}`,
      date: ago(o.created_at),
    }
  ))
}

export const formatResp = {
  campaign: formatCampaign,
  event: formatEvent,
}