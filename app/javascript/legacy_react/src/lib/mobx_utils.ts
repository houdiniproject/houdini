import {FieldDefinition} from "mobx-react-form";

export function createFieldDefinition<TInOut>(fieldDef:FieldDefinition<TInOut>) : FieldDefinition<TInOut> {
  return fieldDef;
}