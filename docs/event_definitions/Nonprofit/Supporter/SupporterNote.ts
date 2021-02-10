// License: LGPL-3.0-or-later
import type { IDType, HoudiniObject, HoudiniEvent } from '../../common';
import type Nonprofit from '..';
import Supporter from '.';
import type { User } from '../../User';

export interface SupporterNote extends HoudiniObject {
  content: string;
  deleted: boolean;
  nonprofit: IDType | Nonprofit;
  object: "supporter_note";
  supporter: IDType | Supporter;
  user: IDType | User;
}

export type SupporterNoteCreated = HoudiniEvent<'supporter_note.created', SupporterNote>;
export type SupporterNoteUpdated = HoudiniEvent<'supporter_note.updated', SupporterNote>;
export type SupporterNoteDeleted = HoudiniEvent<'supporter_note.deleted', SupporterNote>;