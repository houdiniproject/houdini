// License: LGPL-3.0-or-later
import { computed } from "mobx";
import { PutSupporter, ValidationErrorsException } from "../../../api";
import _ = require("lodash");
import { HoudiniForm, StaticFormToErrorAndBackConverter } from "../../lib/houdini_form";
import { initializationDefinition } from "mobx-react-form";
import { SupporterAddressStore } from "./supporter_address_store";

export class EditSupporterForm extends HoudiniForm {
  converter: StaticFormToErrorAndBackConverter<PutSupporter>

  onSubmitSuccessful:Function

  constructor(private updateSupporter:Function, definition: initializationDefinition, options?: any & {onSubmitSuccess?:Function}, ) {
    super(definition, _.omit(options, ['onSubmitSuccess']))
    this.onSubmitSuccessful = options && options.onSubmitSuccess;
    this.converter = new StaticFormToErrorAndBackConverter<PutSupporter>(this.inputToForm, this)
  }

  inputToForm = {
    'name': 'supporter.name',
    'email': 'supporter.email',
    'organization': 'supporter.organization',
    'phone': 'supporter.phone',
    'defaultAddressId': 'supporter.default_address.id'
  }



  @computed
  get serializeValues(): { name: string, email: string, organization: string, phone: string, default_address: { id: number } } {
    return {
      name: this.$('name').value,
      email: this.$('email').value,
      organization: this.$('organization').value,
      phone: this.$('phone').value,
      default_address: {
        id: this.$('defaultAddressId').value
      }
    }
  }

  hooks() {
    return {
      onSuccess: async () => {
        await this.tryToSubmitForm()
      }
    };
  }

  async tryToSubmitForm() {
    try {
      await this.updateSupporter(this.serializeValues)
      this.onSubmitSuccessful();
    }
    catch (e) {
      if (e instanceof ValidationErrorsException) {
        this.converter.convertErrorToForm(e)
      }
      else {
        this.invalidateFromServer(e['error'])
      }
    }
  }




}
