import { action, computed } from 'mobx';
import { HoudiniForm, HoudiniField } from '../../lib/houdini_form';
import { initializationDefinition } from 'mobx-react-form';
import * as _  from 'lodash';
import { ValidationErrorsException, TimeoutError, ValidationError, ValidationErrors } from '../../../api';

export interface FormOutput {
  address?: string
  city?: string
  state_code?: string
  zip_code?: string
  country?: string
}

export interface ServerErrorInput {
  address?: Array<string>
  city?: Array<string>
  state_code?: Array<string>
  zip_code?: Array<string>
  country?: Array<string>
}


export class AddressPaneForm extends HoudiniForm {
  submissionFunction: (serializedValues:FormOutput) => void;
  

  constructor(definition: initializationDefinition, options?: any & {submissionFunction:(serializedValues:FormOutput) => void}) {
    super(definition, _.omit(options, ['submissionFunction']));
    this.submissionFunction = options.submissionFunction;
  }

  @computed
  get serializedValues(): FormOutput {
    return {
      address: this.$('address').value,
      city: this.$('city').value,
      state_code: this.$('state_code').value,
      zip_code: this.$('zip_code').value,
      country: this.$('country').value
    };
  }
  
  hooks() {
    return {
      onSuccess: async () => {
        await this.tryToSubmitForm()
      }
    };
  }

  convertValidationErrorToServerErrorInput(errors:ValidationErrorsException|ValidationErrors|Array<ValidationError>) : ServerErrorInput {
    let errorArray:Array<ValidationError>
    if (errors instanceof ValidationErrorsException)
    {
      errorArray = errors.item.errors
    }
    else if (errors instanceof Array)
    {
      errorArray = errors
    }
    else {
      errorArray = errors.errors
    }

    let output:ServerErrorInput = {}
    errorArray.forEach(error => {
      error.params.forEach(p => {
        if(!_.has(output, p))
        {
          _.set(output, p, new Array<string>())
        }
        error.messages.forEach(m => {
          (_.get(output, p) as string[]).push(m)
        })
      })
      
    });

    return output;

  }


  @action.bound
  assignServerErrors(e: ServerErrorInput) {
    //reset our server status
    this.each((i: HoudiniField) => { i.resetServerValidation(); });
    _.forOwn(e, (i, key) => {
      const errors = i.join(", ");
      (this.$(key) as HoudiniField).invalidateFromServer(errors);
    });
  }

  @action.bound
  async tryToSubmitForm() {
    let input = this.serializedValues

    try {
      await this.submissionFunction(input)
      
    }
    catch (e) {
      if (e instanceof TimeoutError) {
        this.invalidateFromServer("The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds.")
      }
      else {
        if (e instanceof ValidationErrorsException) {
          this.assignServerErrors(this.convertValidationErrorToServerErrorInput(e))
        }

        this.invalidateFromServer(e['error'])
      }
    }
  }
}
