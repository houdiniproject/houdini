// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import {BasicField, CurrencyField, SelectField} from "../common/fields";
import {action, autorun, computed, observable, reaction} from "mobx";
import {FieldDefinition} from "mobx-react-form";
import {createFieldDefinition} from "../../lib/mobx_utils";
import {centsToDollars, dollarsToCents} from "../../lib/format";
import {HoudiniForm} from "../../lib/houdini_form";
import blacklist = require("validator/lib/blacklist");
import * as _ from 'lodash';

export interface CampaignGoalSelectorProps extends CampaignGoalSelectorReturnProperties
{
  onChange: (results:CampaignGoalSelectorReturnProperties) => void
}


enum GoalTypes {
  IN_CENTS = "IN_CENTS",
  IN_SUPPORTERS = "IN_SUPPORTERS"
}

export interface CampaignGoalSelectorReturnProperties {
  goalIsInSupporters:boolean
  goal:number
  startingPoint:number
}

class CampaignGoalSelectorForm extends HoudiniForm {

}

class CampaignGoalSelector extends React.Component<CampaignGoalSelectorProps & InjectedIntlProps, {}> {


  @action.bound
  loadFormFromData() {

    let params: { [name: string]: FieldDefinition } = {
      'goal_in_cents': createFieldDefinition({
        name: 'goal_in_cents', label: 'Goal Amount', value: !this.props.goalIsInSupporters ? this.props.goal : undefined,
        input: (amount: number) => centsToDollars(amount),
        output: (dollarString: string) => parseFloat(blacklist(dollarString, '$,'))
      }),

      'starting_point_cents' : createFieldDefinition({
        name: 'starting_point_cents', label: 'Starting Point ', value: !this.props.goalIsInSupporters ? this.props.startingPoint: 0,
        input: (amount: number) => centsToDollars(amount),
        output: (dollarString: string) => parseFloat(blacklist(dollarString, '$,'))
      }),

      'goal_in_supporters': createFieldDefinition<number>({
        name: 'goal_in_supporters', label: 'Number of donors', value: this.props.goalIsInSupporters ? this.props.goal : 0
      }),

      'starting_point_supporters' : createFieldDefinition<number>({
        name: 'starting_point_supporters', label: 'Starting Point ', value: this.props.goalIsInSupporters ? this.props.startingPoint : 0
      }),

      'goal_is_in_supporters': createFieldDefinition({
        name:'goal_is_in_supporters', value: this.props.goalIsInSupporters ? GoalTypes.IN_SUPPORTERS : GoalTypes.IN_CENTS,
        output: (value:string) => GoalTypes[value as keyof typeof GoalTypes],
        input: (goalType:GoalTypes) => goalType as string,
      })

    };

    const result = new CampaignGoalSelectorForm({fields: _.values(params)})

    reaction(() => this.form.values(), () => {this.props.onChange(this.calculateOutput())});
    return result
  }

  @action.bound
  calculateOutput(): CampaignGoalSelectorReturnProperties
  {
    const goalIsInSupporters = this.form.$('goal_is_in_supporters').get('value')
    const output:CampaignGoalSelectorReturnProperties = {
      goalIsInSupporters: goalIsInSupporters === GoalTypes.IN_SUPPORTERS,
      goal: goalIsInSupporters  === GoalTypes.IN_CENTS ? dollarsToCents(this.form.$('goal_in_cents').get('value')) : this.form.$('goal_in_supporters').get('value'),
      startingPoint: goalIsInSupporters === GoalTypes.IN_CENTS ? dollarsToCents(this.form.$('starting_point_cents').get('value')) : this.form.$('starting_point_supporters').get('value')
    }
    return output
  }


  @computed get form(): CampaignGoalSelectorForm {
    //add this.props because we need to reload on prop change
    return this.props && this.loadFormFromData()
  }

  render() {
    return <div className={'tw-bs'}>

      <SelectField field={this.form.$('goal_is_in_supporters')} options={[{id: GoalTypes.IN_CENTS, name: "Goal in dollars"}, {id: GoalTypes.IN_SUPPORTERS, name: "Goal as supporters"}]} label={"Goals"} style={{marginBottom: 0}}/>


        {this.form.$('goal_is_in_supporters').get('value') === GoalTypes.IN_CENTS ?
          <div>
            <CurrencyField label={"Goal Amount"} field={this.form.$('goal_in_cents')} style={{marginBottom: 0}}/>


            <CurrencyField label={"Starting point (optional)"} field={this.form.$('starting_point_cents')} style={{marginBottom: 0}}/>
          </div>
          : <div>
            <BasicField label={"Number of donors"} field={this.form.$('goal_in_supporters')}  style={{marginBottom: '12px'}} prefixInputAddon={
              <span className="glyphicon glyphicon-user"/>}/>


            <BasicField label={"Starting point (optional)"} field={this.form.$('starting_point_supporters')}  style={{marginBottom: '12px'}} prefixInputAddon={
              <span className="glyphicon glyphicon-user"/>}/>
          </div>
        }
   </div>;
  }
}

export default injectIntl(observer(CampaignGoalSelector))



