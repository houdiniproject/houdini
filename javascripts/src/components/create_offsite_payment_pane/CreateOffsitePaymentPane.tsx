// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import Modal from "../common/Modal";
import { FundraiserInfo} from "../edit_payment_pane/EditPaymentPane";
import {HoudiniForm} from "../../lib/houdini_form";
import {BasicField, CurrencyField, SelectField, TextareaField} from "../common/fields";
import ProgressableButton from "../common/ProgressableButton";
import {action, computed} from "mobx";
import {NonprofitTimezonedDates} from "../../lib/date";
import {Field, FieldDefinition} from "../../../../types/mobx-react-form";
import {createFieldDefinition} from "../../lib/mobx_utils";
import {centsToDollars, dollarsToCents} from "../../lib/format";
import {Validations} from "../../lib/vjf_rules";
import {serializeDedication} from "../../lib/dedication";
import {ApiManager} from "../../lib/api_manager";
import * as CustomAPIS from "../../lib/apis";
import {CSRFInterceptor} from "../../lib/csrf_interceptor";
import {CreateOffsiteDonation, CreateOffsiteDonationModel} from "../../lib/api/create_offsite_donation";
import blacklist = require("validator/lib/blacklist");
import * as _ from 'lodash'
import moment = require('moment');
import { castToUndefinedIfBlank } from '../../lib/utils';
import ReactInput from "../common/form/ReactInput";

export interface CreateOffsitePaymentPaneProps
{
  events: FundraiserInfo[]
  campaigns: FundraiserInfo[]
  nonprofitId: number
  supporterId:number
  nonprofitTimezone?: string
  preupdateDonationAction:() => void
  postUpdateSuccess: () => void

  //from ModalProps
  onClose: () => void
  modalActive: boolean
}

class CreateOffsitePaymentPaneForm extends HoudiniForm {

}

class CreateNewOffsitePaymentPane extends React.Component<CreateOffsitePaymentPaneProps & InjectedIntlProps, {}> {

  constructor(props: CreateOffsitePaymentPaneProps & InjectedIntlProps) {
    super(props);
    this.postOffsiteDonation = new ApiManager(CustomAPIS.APIS as Array<any>, CSRFInterceptor).get(CreateOffsiteDonation)

    this.loadFormFromData()

  }


  @computed
  get nonprofitTimezonedDates():NonprofitTimezonedDates {
    return new NonprofitTimezonedDates(this.props.nonprofitTimezone)
  }

  postOffsiteDonation : CreateOffsiteDonation

  @action.bound
  async createOffsiteDonation() {
    if (this.props.preupdateDonationAction) {
      this.props.preupdateDonationAction()
    }


    let postData:CreateOffsiteDonationModel = {
      nonprofit_id:this.props.nonprofitId,
      supporter_id:this.props.supporterId,
      amount: dollarsToCents(this.form.$('gross_amount').get('value')),
      designation: this.form.$('designation').value,
      comment: this.form.$('comment').value,
      campaign_id: this.form.$('campaign').get('value'),
      event_id: this.form.$('event').get('value'),
      date: this.form.$('date').get('value')
    }

    if (this.form.$('dedication.type').get('value') != '') {
      const nameToValueForContact = ['full_address', 'phone', 'email'].map((i) => {
        return {
          name: i, value: this.form.$(`dedication.${i}`).get('value')
        }
      });
      const contact = _.some(nameToValueForContact, (i) => i.value && i.value != "") ?
        _.reduce(nameToValueForContact, (result: any, i) => {
          result[i.name] = i.value;
          return result;
        }, {}) : undefined;

      postData.dedication = serializeDedication({
        type: this.form.$('dedication.type').get('value'),
        supporter_id: this.form.$('dedication.supporter_id').get('value'),
        name:  this.form.$('dedication.name').get('value'),
        contact: contact,
        note: this.form.$('dedication.note').get('value')
      })
    }
    else {
      postData.dedication = ""
    }

    if (this.form.has('check_number'))
    {
      postData.offsite_payment = postData.offsite_payment || {}
      postData.offsite_payment.check_number = this.form.$('check_number').value
    }


    await this.postOffsiteDonation.postDonation(postData, this.props.nonprofitId)


    if(this.props.postUpdateSuccess){
      try {
        this.props.postUpdateSuccess()
      }
      catch {}
    }

    this.props.onClose()

  }

  @action.bound
  loadFormFromData() {

    let params: {[name:string]:FieldDefinition} = {
      'event': {name: 'event', label: 'Event',
        output: (id:string) => castToUndefinedIfBlank(id)},
      'campaign':  {name: 'campaign', label: 'Campaign', 
        output: (id:string) => castToUndefinedIfBlank(id)},
      'gross_amount': createFieldDefinition({name: 'gross_amount', 
        label: 'Gross Amount',
        input: (amount:number) => centsToDollars(amount),
        output: (dollarString:string) => parseFloat(blacklist(dollarString, '$,')),
        value: 0
      }),
      // 'fee_total': createFieldDefinition({name: 'fee_total', label: 'Fees',
      //   input: (amount:number) => centsToDollars(amount),
      //   output: (dollarString:string) => parseFloat(blacklist(dollarString, '$,')),
      //   value: 0
      // }),
      'date': createFieldDefinition({name: 'date', label: 'Date',
        input: (isoTime:string) => this.nonprofitTimezonedDates.readable_date(isoTime),
        output:(date:string) =>  this.nonprofitTimezonedDates.readable_date_time_to_iso(date),
        value: moment.utc().toISOString()
      }),
      'dedication': {name: 'dedication', label: 'Dedication', fields: [
          createFieldDefinition({name:'type', label: 'Dedication Type'}),
          createFieldDefinition({name: 'supporter_id', type: 'hidden'}),
          createFieldDefinition({name:'name', label:'Person dedicated for'}),
          createFieldDefinition({name: 'full_address', label: 'Full address'}),
          createFieldDefinition({name: 'phone', label: 'Phone'}),
          createFieldDefinition({name: 'email', label: 'Email'}),
          createFieldDefinition({name: 'note', label: 'Dedication Note', type: 'textarea'})
        ]},
      'designation': {name: 'designation', label: 'Designation'},
      'comment': {name: 'comment', label: 'Note'}
    };


      params.check_number = {name: 'check_number', label: 'Check Number'}

      params.date.validators = [Validations.isDate('MM/DD/YYYY')]

      params.gross_amount.validators  = [Validations.isGreaterThanOrEqualTo(0.01)];



    return new CreateOffsitePaymentPaneForm({fields: _.values(params)}, {
      hooks: {
        onSuccess: async (e: Field) => {
          await this.createOffsiteDonation()
        }
      }
    })
  }
  @computed get form(): CreateOffsitePaymentPaneForm {
    //add this.props because we need to reload on prop change
    return this.props && this.loadFormFromData()
  }

  @computed get dateFormatter(): NonprofitTimezonedDates {
    return new NonprofitTimezonedDates(this.props.nonprofitTimezone)
  }

  render() {
    this.form.values()
    const modal =
      <Modal modalActive={this.props.modalActive} titleText={'Create Offsite Donation'} focusDialog={true}
             onClose={this.props.onClose} dialogStyle={{minWidth:'768px'}} childGenerator={() => {
        return <div className={"tw-bs"}>
          <form className='u-marginTop--20'>
          
            <CurrencyField field={this.form.$('gross_amount')} label={"Gross Amount"} currencySymbol={"$"}/>
            {/* <CurrencyField field={this.form.$('fee_total')} label={"Processing Fees"} mustBeNegative={true}/> */}

          <BasicField field={this.form.$('date')} label={"Date"} />
            <BasicField field={this.form.$('check_number')} label={"Check or Payment Number/ID"}/>
            <SelectField field={this.form.$('campaign')}
                         label={"Campaign"}
                         options={this.props.campaigns}/>


            <SelectField field={this.form.$('event')}
                         label={"Event"}
                         options={this.props.events} />



            <TextareaField field={this.form.$('designation')} label={"Designation"} rows={3} />
            <div className="panel panel-default">
              <div className="panel-heading"><label>Dedication <small> (optional)</small></label></div>
              <div className="panel-body">
                <SelectField field={this.form.$('dedication.type')} label={"Dedication Type"}
                             options={[{id: null, name: ''}, {id: 'honor', name: 'In honor of'}, {
                               id: 'memory',
                               name: 'In memory of'
                             }]}/>

                {this.form.$('dedication.type').get('value') != '' ? <div>
                    <div className={"panel panel-default"}>
                      <div className="panel-heading"><label>Dedicated to:</label></div>
                      <div className={'panel-body'}>
                        <table className='table--small u-marginBottom--10'>
                          <tbody>
                          <tr>
                            <th>Name</th>
                            <td><ReactInput field={this.form.$('dedication.name')} label={'Name'} className={"form-control"}/></td>
                          </tr>

                          <tr>
                            <th>Full Address
                            </th>
                            <td><ReactInput field={this.form.$('dedication.full_address')}  className={"form-control"}/>
                            </td>
                          </tr>
                          <tr>
                            <th>Phone Number
                            </th>
                            <td><ReactInput field={this.form.$('dedication.phone')} className={"form-control"}/>
                            </td>
                          </tr>
                          <tr>
                            <th>Email Address
                            </th>
                            <td><ReactInput field={this.form.$('dedication.email')}  className={"form-control"}/>
                            </td>
                          </tr>
                          </tbody>
                        </table>
                      </div>
                    </div>
                    <TextareaField rows={3} placeholder={"Dedication"} field={this.form.$('dedication.note')}
                                   label={"Dedication Note"}/></div>
                  : undefined}
              </div>
            </div>


            <TextareaField field={this.form.$('comment')} label={"Notes"} rows={3} />


            <ProgressableButton buttonText={'Save'}
                                buttonTextOnProgress={'Updating...'} className={'button'}
                                inProgress={this.form.submitting}
                                disabled={!this.form.isValid}
                                disableOnProgress={true} onClick={this.form.onSubmit}/>
          </form>
        </div>
        }} />
     return <div>{modal}</div>;
  }
}

export default injectIntl(observer(CreateNewOffsitePaymentPane))



